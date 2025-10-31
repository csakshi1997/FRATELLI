//
//  LocationSyncManager.swift
//  FRATELLI
//
//  Created by Sakshi on 20/03/25.
//

import Foundation
import Network
import UIKit
import CoreLocation

class LocationSyncManager {
    let webRequest = BaseWebService()
    let locationTable = LocationTable()
    let endPoint = EndPoints()
    let customDateFormatter = CustomDateFormatter()
    let monitor = NWPathMonitor()
    let queue = DispatchQueue.global(qos: .background)
    static let shared = LocationSyncManager()
    var isAPIRunning: Bool = false
    
    func syncOfflineLocationsToServer() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            if appDelegate.isInternetReachable {
                let location = locationTable.getLocation()
                if let locationId = location.id {
                    if !isAPIRunning {
                        isAPIRunning = true
                        sendLocationToServer(location) { success in
                            if success {
                                self.locationTable.deleteLocationById(id: location.id ?? 0 ) { _, _ in }
                            } else {
                                print("Failed to sync location \(location.id ?? 0)")
                            }
                            self.isAPIRunning = false
                        }
                    }
                }
            }
        }
    }
    
    func sendLocationToServer(_ location: LocationModel, completion: @escaping (Bool) -> Void) {
        guard let latitude = location.latitude, let longitude = location.longitude,
              latitude != 0.0, longitude != 0.0 else {
            completion(false)
            return
        }
        
        let locationPayload: [String: Any] = [
            "DeviceManufacturer": location.deviceManufacturer ?? "Unknown Manufacturer",
            "UserId": Defaults.userId ?? "",
            "IsOfflineRecord": location.isOfflineRecord ?? false,
            "DateTime": location.dateTime ?? CustomDateFormatter.getCurrentDateTime(),
            "Longitude": longitude,
            "Latitude": latitude,
            "IsFakeLocation": location.isMockLocation ?? false,
            "BatteryPercentage": location.batteryPercentage ?? 20,
            "Address": location.address ?? "Unknown Address",
            "DeviceModel": location.deviceModel ?? "Unknown Device",
            "MobileDistanceKm": String(format: "%.2f", location.diffrenceBetweenCurrentAndLastLatLong ?? 0.0)
        ]
        
        let payload: [String: Any] = ["records": [locationPayload]]
        webRequest.processRequestUsingPostMethod(url: "https://location.fieldblaze.com/user/tracking/create", parameters: payload, showLoader: false, contentType: .json) { error, val, result, statusCode in
            if let error = error {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func saveLocationToDatabase(_ location: CLLocation, isMockLocation: Int, lastLocation: CLLocation?) {
        var distance: Double = 0.0
        if let lastLocation = getLastLocation() {
            distance = lastLocation.distance(from: location)
            if distance < 50.0  {
                return
            }
        }
        saveLastLocation(location)
        let batteryLevel = max(20, Int(UIDevice.current.batteryLevel * 100))
        let deviceModel = UIDevice.current.model
        let deviceManufacturer = "Apple"
        
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
                diffrenceBetweenCurrentAndLastLatLong: distance,
                address: address,
                isMockLocation: isMockLocation,
                dateTime: CustomDateFormatter.getCurrentDateTime(),
                batteryPercentage: batteryLevel,
                deviceModel: deviceModel,
                deviceManufacturer: deviceManufacturer
            )
            self.locationTable.saveLocation(location: locationModel) { success, _ in
            }
        }
    }
    
    func saveLastLocation(_ location: CLLocation) {
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        let data: [String: Double] = ["lat": lat, "lon": lon]
        
        UserDefaults.standard.set(data, forKey: "lastSavedLocation")
        UserDefaults.standard.synchronize()
    }
    
    func getLastLocation() -> CLLocation? {
        if let data = UserDefaults.standard.dictionary(forKey: "lastSavedLocation") as? [String: Double],
           let lat = data["lat"],
           let lon = data["lon"] {
            return CLLocation(latitude: lat, longitude: lon)
        }
        return nil
    }
}
