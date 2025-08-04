//
//  UploadFileToServer.swift
//  FRATELLI
//
//  Created by Sakshi on 19/06/25.
//

import Foundation
import UIKit

class UploadFileToServer {
    let webRequest = BaseWebService()
    let endPoint = EndPoints()
    
    func uploadFileToServer(userId: String, fileData: Data, fileName: String, mimeType: String, completion: @escaping (Bool, String?) -> Void) {
        let url = URL(string: "https://location.fieldblaze.com/user/tracking/upload-file")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("xK8pQ3rT9sF2yL5", forHTTPHeaderField: "Auth-Id")

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // user_id
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"user_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(userId)\r\n".data(using: .utf8)!)

        // file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)

        // Close boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let task = URLSession.shared.dataTask(with: request) { responseData, response, error in
            if let error = error {
                print("❌ Upload error: \(error.localizedDescription)")
                completion(false, error.localizedDescription)
                return
            }

            guard let responseData = responseData else {
                completion(false, "No response data")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
                    if let status = json["status"] as? String, status == "success" {
                        print("✅ Upload Success: \(json["url"] ?? "")")
                        completion(true, json["url"] as? String)
                    } else {
                        print("❌ Upload Failed: \(json["message"] ?? "Unknown error")")
                        completion(false, json["message"] as? String)
                    }
                }
            } catch {
                print("❌ JSON parse error: \(error)")
                completion(false, error.localizedDescription)
            }
        }
        task.resume()
    }
}
