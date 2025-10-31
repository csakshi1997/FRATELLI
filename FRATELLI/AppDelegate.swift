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
    var locationManager = CLLocationManager()
    let monitor = NWPathMonitor()
    let monitorQueue = DispatchQueue(label: "Monitor")
    var isInternetReachable: Bool = false
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
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.isInternetReachable = true
            } else {
                self.isInternetReachable = false
            }
        }
        monitor.start(queue: monitorQueue)
        if Defaults.isTrackingStart ?? false {
            startLocationTracking()
        }
        Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            LocationSyncManager.shared.syncOfflineLocationsToServer()
        }
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if (Defaults.isTrackingStart ?? false) {
            DispatchQueue.main.async {
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    
    func startLocationTracking() {
        DispatchQueue.main.async {
            if CLLocationManager.authorizationStatus() == .notDetermined {
                self.locationManager.requestAlwaysAuthorization()
            }
        }
        DispatchQueue.global(qos: .background).async {
            self.locationManager.allowsBackgroundLocationUpdates = true
            self.locationManager.pausesLocationUpdatesAutomatically = false
            self.locationManager.startUpdatingLocation()
            self.locationManager.delegate = self
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.distanceFilter = 5
            self.locationManager.requestAlwaysAuthorization()
            self.scheduleBackgroundLocationSync()
        }
        scheduleAutoStopTracking()
    }
    
    func stopLocationTracking() {
        UserDefaults.standard.removeObject(forKey: "lastSavedLocation")
        locationManager.stopUpdatingLocation()
        Defaults.isTrackingStart = false
    }
    
    func scheduleAutoStopTracking() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
            let currentHour = Calendar.current.component(.hour, from: Date())
            
            if (currentHour >= 22 && currentHour <= 24) || (currentHour >= 0 && currentHour <= 7) {
                self.stopLocationTracking()
                timer.invalidate()
            }
        }
    }
    
    func scheduleBackgroundLocationSync() {
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
        scheduleBackgroundLocationSync()
        if Defaults.isTrackingStart ?? false {
            task.setTaskCompleted(success: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var mockLocationValue = Int()
        guard let newLocation = locations.last else { return }
  
        let isMockLocation = newLocation.horizontalAccuracy > 20
        if isMockLocation {
            mockLocationValue = 1
        } else {
            mockLocationValue = 0
        }
        
        DispatchQueue.global(qos: .background).async {
            if Defaults.isTrackingStart ?? false {
                LocationSyncManager.shared.saveLocationToDatabase(newLocation, isMockLocation: mockLocationValue, lastLocation: nil)
            }
        }
    }
    
    private func isInternetAvailable() -> Bool {
        return isInternetReachable
    }
}
