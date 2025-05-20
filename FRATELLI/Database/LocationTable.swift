//
//  LocationTable.swift
//  FRATELLI
//
//  Created by Sakshi on 20/03/25.
//

import Foundation
import SQLite3

class LocationTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var statement: OpaquePointer? = nil
    
    func createLocationTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS LocationTable (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                isOfflineRecord INTEGER,
                latitude REAL,
                longitude REAL,
                address TEXT,
                isMockLocation INTEGER,
                dateTime TEXT,
                batteryPercentage INTEGER,
                deviceModel TEXT,
                deviceManufacturer TEXT
            );
        """
        if sqlite3_exec(Database.databaseConnection, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating LocationTable")
        }
    }
    
    func saveLocation(location: LocationModel, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let insertQuery = """
            INSERT INTO LocationTable (isOfflineRecord, latitude, longitude, address, isMockLocation, dateTime, batteryPercentage, deviceModel, deviceManufacturer) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """
        
        if sqlite3_prepare_v2(Database.databaseConnection, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, location.isOfflineRecord ?? false ? 1 : 0)
            sqlite3_bind_double(statement, 2, location.latitude ?? 0)
            sqlite3_bind_double(statement, 3, location.longitude ?? 0.0)
            sqlite3_bind_text(statement, 4, location.address, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 5, Int32(location.isMockLocation ?? 0))
            sqlite3_bind_text(statement, 6, location.dateTime, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 7, Int32(location.batteryPercentage ?? 0))
            sqlite3_bind_text(statement, 8, location.deviceModel, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 9, location.deviceManufacturer, -1, SQLITE_TRANSIENT)
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error inserting location: \(errorMsg)")
                completion(false, errorMsg)
            } else {
                print("Location inserted successfully")
                completion(true, nil)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        
        sqlite3_finalize(statement)
    }
    
    func getLocations() -> [LocationModel] {
        var resultArray = [LocationModel]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM LocationTable"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let location = LocationModel(
                    id: Int(sqlite3_column_int(statement, 0)),
                    isOfflineRecord: sqlite3_column_int(statement, 1) == 1,
                    latitude: sqlite3_column_double(statement, 2),
                    longitude: sqlite3_column_double(statement, 3),
                    address: String(cString: sqlite3_column_text(statement, 4)),
                    isMockLocation: Int(sqlite3_column_int(statement, 5)),
                    dateTime: String(cString: sqlite3_column_text(statement, 6)),
                    batteryPercentage: Int(sqlite3_column_int(statement, 7)),
                    deviceModel: String(cString: sqlite3_column_text(statement, 8)),
                    deviceManufacturer: String(cString: sqlite3_column_text(statement, 9))
                )
                resultArray.append(location)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching locations.")
        }
        
        return resultArray
    }
    
    func deleteLocationById(id: Int, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let deleteQuery = "DELETE FROM LocationTable WHERE id = ?"
        
        if sqlite3_prepare_v2(Database.databaseConnection, deleteQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(id))
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Location deleted successfully")
                completion(true, nil)
            } else {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error deleting location: \(errorMsg)")
                completion(false, errorMsg)
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing delete statement: \(errorMsg)")
            completion(false, errorMsg)
        }
        
        sqlite3_finalize(statement)
    }
}
