//
//  LocationSyncManager.swift
//  FRATELLI
//
//  Created by Sakshi on 20/03/25.
//

import Foundation
import Network

class LocationSyncManager {
    let webRequest = BaseWebService()
    let locationTable = LocationTable()
    let endPoint = EndPoints()
    let customDateFormatter = CustomDateFormatter()
    let monitor = NWPathMonitor()
    let queue = DispatchQueue.global(qos: .background)
    
    
    init() {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("📡 Internet is back! Starting background sync...")
                if Defaults.isTrackingStart ?? false {
                    self.syncOfflineLocationsToServer()
                }
            } else {
                print("❌ No internet, saving locations to DB.")
            }
        }
        monitor.start(queue: queue)
    }
    
    private func isInternetAvailable() -> Bool {
        return monitor.currentPath.status == .satisfied
    }
    
    // Syncs stored locations when online
    func syncOfflineLocationsToServer() {
        let locations = locationTable.getLocations()
        
        if locations.isEmpty {
            print("⚠ No locations found in DB to sync")
            return
        }
        
        print("📡 Syncing \(locations.count) locations to the server.")
        for location in locations {
            sendLocationToServer(location) { success in
                if success {
                    print("✅ Location synced successfully. Deleting from DB.")
                    self.locationTable.deleteLocationById(id: location.id ?? 0 ) { _, _ in }
                } else {
                    print("❌ Failed to sync location \(location.id ?? 0)")
                }
            }
        }
    }
    
    func sendLocationToServer(_ location: LocationModel, completion: @escaping (Bool) -> Void) {
        guard let latitude = location.latitude, let longitude = location.longitude,
              latitude != 0.0, longitude != 0.0 else {
            print("❌ Skipping request: Invalid location data")
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
            "DeviceModel": location.deviceModel ?? "Unknown Device"
        ]
        
        let payload: [String: Any] = ["records": [locationPayload]]
        
        print("📡 Sending location payload: \(payload)")
        
        webRequest.processRequestUsingPostMethod(url: "https://location.fieldblaze.com/user/tracking/create", parameters: payload, showLoader: true, contentType: .json) { error, val, result, statusCode in
            if let error = error {
                print("❌ Error sending location: \(error)")
                completion(false)
                return
            }
            
            print("📡 Response from server: \(result ?? "No Response")")
            completion(true)
        }
    }
    
}
