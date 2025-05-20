//
//  AppDelegate.swift
//  FRATELLI
//
//  Created by Sakshi on 18/10/24.
//

import UIKit
import IQKeyboardManagerSwift
import BackgroundTasks
import CoreLocation
import Network

@main
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var locationSyncManager = LocationSyncManager()
    var locationManager = CLLocationManager()
    var lastSavedLocation: CLLocation?
    var locationTable = LocationTable()
    let monitor = NWPathMonitor()
    var customDateFormatter = CustomDateFormatter()
    let queue = DispatchQueue.global(qos: .background)
    func getFormattedDateTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: Date())
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.fratelli.syncLocations", using: nil) { task in
            guard let task = task as? BGAppRefreshTask else { return }
            self.handleBackgroundTask(task: task)
        }
        IQKeyboardManager.shared.isEnabled = true
        Database.createDatabase()
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("App moved to background. Forcing location updates.")
        if (Defaults.isTrackingStart ?? false) {
            locationSyncManager.syncOfflineLocationsToServer()
            DispatchQueue.main.async {
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    
    func startLocationTracking() {
        print("📍 Starting location tracking from home screen button...")
        DispatchQueue.main.async {
            if CLLocationManager.authorizationStatus() == .notDetermined {
                self.locationManager.requestAlwaysAuthorization()
            }
        }
        DispatchQueue.global(qos: .background).async {
            self.locationManager.allowsBackgroundLocationUpdates = true
            self.locationManager.pausesLocationUpdatesAutomatically = false
            self.locationManager.startUpdatingLocation()
            self.scheduleBackgroundLocationSync()
        }
        scheduleAutoStopTracking()
    }
    
    func stopLocationTracking() {
        print("Stopping location tracking...")
        locationManager.stopUpdatingLocation()
    }
    
    func scheduleAutoStopTracking() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
            let currentHour = Calendar.current.component(.hour, from: Date())
            let currentMinute = Calendar.current.component(.minute, from: Date())
            
            if currentHour == 22 && currentMinute == 0 {
                self.stopLocationTracking()
                timer.invalidate()
                print("🛑 Location tracking automatically stopped at 10:00 PM")
            }
        }
    }
    
    func scheduleBackgroundLocationSync() {
        print("Scheduling background task...")
        let request = BGAppRefreshTaskRequest(identifier: "com.fratelli.syncLocations")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60)
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background task scheduled")
        } catch {
            print("Failed to schedule background task: \(error.localizedDescription)")
        }
    }
    
    func handleBackgroundTask(task: BGAppRefreshTask) {
        print("Background task started")
        scheduleBackgroundLocationSync()
        if Defaults.isTrackingStart ?? false {
            locationSyncManager.syncOfflineLocationsToServer()
            task.setTaskCompleted(success: true)
            print("Background task completed")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var mockLocationValue = Int()
        guard let newLocation = locations.last else { return }
        
        // Ensure accuracy is within an acceptable range
        guard newLocation.horizontalAccuracy > 0, newLocation.horizontalAccuracy < 50 else {
            print("🚫 Unreliable location accuracy: \(newLocation.horizontalAccuracy)")
            return
        }
        
        let isMockLocation = newLocation.horizontalAccuracy > 20
        if isMockLocation {
            mockLocationValue = 1
        } else {
            mockLocationValue = 0
        }
        
        // **Ensure the first location is always saved**
        if lastSavedLocation == nil {
            print("📍 First location update received. Saving immediately.")
            lastSavedLocation = newLocation
            DispatchQueue.global(qos: .background).async {
                if Defaults.isTrackingStart ?? false {
                    self.saveLocationToDatabase(newLocation, isMockLocation: mockLocationValue, lastLocation: nil)
                }
            }
            return
        }
        
        // **Check if user has moved at least 80 meters**
        if let lastLocation = lastSavedLocation {
            let distance = lastLocation.distance(from: newLocation)
            print("📏 Distance from last saved location: \(distance) meters")
            
            if distance < Double(Location_Proximity__c)  {
                print("🚫 User has not moved significantly (\(distance)m). Skipping location save.")
                return
            }
        }
        
        // **Update lastSavedLocation and save the new location**
        lastSavedLocation = newLocation
        print("✅ User moved \(lastSavedLocation?.distance(from: newLocation) ?? 0)m, saving location.")
        
        DispatchQueue.global(qos: .background).async {
            if Defaults.isTrackingStart ?? false {
                self.saveLocationToDatabase(newLocation, isMockLocation: mockLocationValue, lastLocation: nil)
            }
        }
    }
    
    func saveLocationToDatabase(_ location: CLLocation, isMockLocation: Int, lastLocation: CLLocation?) {
        // Ensure minimum 20% battery
        let batteryLevel = max(20, Int(UIDevice.current.batteryLevel * 100))
        let deviceModel = UIDevice.current.model
        let deviceManufacturer = "Apple"
        
        if let lastLoc = lastLocation, location.distance(from: lastLoc) < Double(Location_Proximity__c) {
            print("⚠ Distance < \(Double(Location_Proximity__c)) m. Skipping save.")
            return
        }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            var address = "Unknown"
            if let placemark = placemarks?.first {
                address = [
                    placemark.name,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.country
                ].compactMap { $0 }.joined(separator: ", ")
            }
            
            let locationModel = LocationModel(
                id: nil,
                isOfflineRecord: true,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                address: address,
                isMockLocation: isMockLocation,
                dateTime: CustomDateFormatter.getCurrentDateTime(),
                batteryPercentage: batteryLevel,
                deviceModel: deviceModel,
                deviceManufacturer: deviceManufacturer
            )
            print("💾 Saving location to DB...")
            self.locationTable.saveLocation(location: locationModel) { success, _ in
                if success {
                    print("✅ Location saved. Checking internet for sync...")
                    if self.isInternetAvailable() {
                        DispatchQueue.main.async {
                            self.locationSyncManager.syncOfflineLocationsToServer()
                        }
                    }
                }
            }
        }
    }
    
    private func isInternetAvailable() -> Bool {
        return monitor.currentPath.status == .satisfied
    }
}
