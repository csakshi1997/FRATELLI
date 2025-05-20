//
//  ProductsTable.swift
//  FRATELLI
//
//  Created by Sakshi on 23/10/24.
//

import Foundation
import SQLite3

class ProductsTable: Database {
    let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    var statement: OpaquePointer? = nil
    
    func createProductsTable() {
        let createTableQuery = """
            CREATE TABLE IF NOT EXISTS ProductsTable (
                localId INTEGER PRIMARY KEY AUTOINCREMENT,
                abbreviation TEXT,
                bottleCan TEXT,
                bottleSize TEXT,
                brandCode TEXT,
                category TEXT,
                conversionRatio INTEGER,
                createdDate TEXT,
                gst TEXT,
                id TEXT UNIQUE,
                isDeleted INTEGER,
                itemType TEXT,
                name TEXT,
                ownerId TEXT,
                priority INTEGER,
                productCategory TEXT,
                productCode TEXT,
                productFamily TEXT,
                productId TEXT,
                productType TEXT,
                sizeCode TEXT,
                sizeInMl INTEGER,
                type TEXT,
                attributesType TEXT,
                attributesUrl TEXT,
                isSync TEXT
            );
        """
        if sqlite3_exec(Database.databaseConnection, createTableQuery, nil, nil, nil) != SQLITE_OK {
            print("Error creating ProductsTable")
        }
    }
    
    // Insert data into ProductsTable
    func saveProduct(product: Product, completion: @escaping (Bool, String?) -> Void) {
        var statement: OpaquePointer?
        let insertQuery = """
            INSERT INTO ProductsTable (
                abbreviation, bottleCan, bottleSize, brandCode,
                category, conversionRatio, createdDate, gst,
                id, isDeleted, itemType, name,
                ownerId, priority, productCategory, productCode,
                productFamily, productId, productType, sizeCode,
                sizeInMl, type, attributesType, attributesUrl, isSync
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """

        if sqlite3_prepare_v2(Database.databaseConnection, insertQuery, -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_text(statement, 1, product.abbreviation, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 2, product.bottleCan ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 3, product.bottleSize ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 4, product.brandCode, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 5, product.category, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 6, Int32(product.conversionRatio))
            sqlite3_bind_text(statement, 7, product.createdDate, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 8, product.gst ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 9, product.id, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 10, product.isDeleted ? 1 : 0)
            sqlite3_bind_text(statement, 11, product.itemType, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 12, product.name, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 13, product.ownerId, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 14, Int32(product.priority))
            sqlite3_bind_text(statement, 15, product.productCategory ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 16, product.productCode ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 17, product.productFamily ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 18, product.productId, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 19, product.productType ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 20, product.sizeCode, -1, SQLITE_TRANSIENT)
            sqlite3_bind_int(statement, 21, Int32(product.sizeInMl))
            sqlite3_bind_text(statement, 22, product.type, -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 23, product.attributes?.type ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 24, product.attributes?.url ?? "", -1, SQLITE_TRANSIENT)
            sqlite3_bind_text(statement, 25, product.isSync ?? "", -1, SQLITE_TRANSIENT)

            if sqlite3_step(statement) != SQLITE_DONE {
                let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
                print("Error inserting product: \(errorMsg)")
                completion(false, errorMsg) // Call completion with failure
            } else {
                print("Product inserted successfully")
                completion(true, nil) // Call completion with success
            }
        } else {
            let errorMsg = String(cString: sqlite3_errmsg(Database.databaseConnection))
            print("Error preparing statement: \(errorMsg)")
            completion(false, errorMsg) // Call completion with failure
        }

        sqlite3_finalize(statement)
    }
    
    func getProducts() -> [Product] {
        var resultArray = [Product]()
        var statement: OpaquePointer?
        let query = "SELECT * FROM ProductsTable"
        
        if sqlite3_prepare_v2(Database.databaseConnection, query, -1, &statement, nil) == SQLITE_OK {
            while sqlite3_step(statement) == SQLITE_ROW {
                let abbreviation = String(cString: sqlite3_column_text(statement, 1))
                let bottleCan = sqlite3_column_text(statement, 2) != nil ? String(cString: sqlite3_column_text(statement, 2)) : nil
                let bottleSize = sqlite3_column_text(statement, 3) != nil ? String(cString: sqlite3_column_text(statement, 3)) : nil
                let brandCode = String(cString: sqlite3_column_text(statement, 4))
                let category = String(cString: sqlite3_column_text(statement, 5))
                let conversionRatio = Int(sqlite3_column_int(statement, 6))
                let createdDate = String(cString: sqlite3_column_text(statement, 7))
                let gst = sqlite3_column_text(statement, 8) != nil ? String(cString: sqlite3_column_text(statement, 8)) : nil
                let id = String(cString: sqlite3_column_text(statement, 9))
                let isDeleted = sqlite3_column_int(statement, 10) != 0
                let itemType = String(cString: sqlite3_column_text(statement, 11))
                let name = String(cString: sqlite3_column_text(statement, 12))
                let ownerId = String(cString: sqlite3_column_text(statement, 13))
                let priority = Int(sqlite3_column_int(statement, 14))
                let productCategory = sqlite3_column_text(statement, 15) != nil ? String(cString: sqlite3_column_text(statement, 15)) : nil
                let productCode = sqlite3_column_text(statement, 16) != nil ? String(cString: sqlite3_column_text(statement, 16)) : nil
                let productFamily = sqlite3_column_text(statement, 17) != nil ? String(cString: sqlite3_column_text(statement, 17)) : nil
                let productId = String(cString: sqlite3_column_text(statement, 18))
                let productType = sqlite3_column_text(statement, 19) != nil ? String(cString: sqlite3_column_text(statement, 19)) : nil
                let sizeCode = String(cString: sqlite3_column_text(statement, 20))
                let sizeInMl = Int(sqlite3_column_int(statement, 21))
                let type = String(cString: sqlite3_column_text(statement, 22))
                
                // Attributes
                let attributes = Product.Attributes(
                    type: String(cString: sqlite3_column_text(statement, 23)),
                    url: String(cString: sqlite3_column_text(statement, 24))
                )
                let isSync = String(cString: sqlite3_column_text(statement, 25))
                
                let product = Product(
                    abbreviation: abbreviation,
                    bottleCan: bottleCan,
                    bottleSize: bottleSize,
                    brandCode: brandCode,
                    category: category,
                    conversionRatio: conversionRatio,
                    createdDate: createdDate,
                    gst: gst,
                    id: id,
                    isDeleted: isDeleted,
                    itemType: itemType,
                    name: name,
                    ownerId: ownerId,
                    priority: priority,
                    productCategory: productCategory,
                    productCode: productCode,
                    productFamily: productFamily,
                    productId: productId,
                    productType: productType,
                    sizeCode: sizeCode,
                    sizeInMl: sizeInMl,
                    type: type,
                    attributes: attributes,
                    isSync: isSync
                )
                
                resultArray.append(product)
            }
            sqlite3_finalize(statement)
        } else {
            print("Failed to prepare statement for fetching products.")
        }
        
        return resultArray
    }


}

