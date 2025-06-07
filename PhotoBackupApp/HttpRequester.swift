//
//  HttpRequester.swift
//  PhotosPickerDemo
//
//  Created by Ty Janik on 4/27/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import Foundation
import SwiftUI


struct ResponseObj: Codable {
    var testKey: String
}

// TODO: request internet access before app runs to fix bug

struct PhotoServerApi {
    let serverUrl = URL(string: "http://192.168.1.173:8000/media/hi")!
//    let serverUrl = URL(string: "http://172.20.10.3:8000/media/hi")!  // IP when using hotspot
    
    
    func uploadImages(images: [ImageWrapper], statusUpdateHandler: @escaping (String) -> Void) {
        
        // generate boundary string using a unique per-app string
        let boundary = UUID().uuidString
        let session = URLSession.shared
        
        // TODO: see if there is a way to dynamically determine the original file's type - would also need to change call to .pngData() below

        // Set the URLRequest to POST and to the specified URL
        var urlRequest = URLRequest(url: serverUrl)
        urlRequest.httpMethod = "POST"

        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
        // And the boundary is also set here
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        
        // Using this method for now since I don't think UIImage / iPhone will have filename we can use
        var counter = 0
        var tmpName = "tmpFilename" + String(counter) + ".png"
        
        for image in images {
            // Add the image data to the raw http request data
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(tmpName)\"; filename=\"\(tmpName)\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
            data.append(image.img!.pngData()!)
            data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            
            counter += 1
            tmpName = "tmpFilename" + String(counter) + ".png"
        }
        
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        print("REQUEST SENT HERE -----------")
        statusUpdateHandler("Sending request")

        // Send a POST request to the URL, with the data we created earlier
        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
            if error == nil {
                print("GOT RESPONSE")
                statusUpdateHandler("Got successful response from server")
                
                let jsonData = try? JSONSerialization.jsonObject(with: responseData!, options: .allowFragments)
                if let json = jsonData as? [String: Any] {
                    print(json)
                }
            } else {
                statusUpdateHandler("Got error response")
                print("GOT ERROR:")
                print(error!)
            }
        }).resume()
    }
    
    func uploadImage(paramName: String, fileName: String, image: UIImage) {
        // generate boundary string using a unique per-app string
        let boundary = UUID().uuidString
        let session = URLSession.shared
        
        // TODO: see if there is a way to dynamically determine the original file's type - would also need to change call to .pngData() below
        let filenameWithExtension = fileName + ".png"

        // Set the URLRequest to POST and to the specified URL
        var urlRequest = URLRequest(url: serverUrl)
        urlRequest.httpMethod = "POST"

        // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
        // And the boundary is also set here
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var data = Data()

        // Add the image data to the raw http request data
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(filenameWithExtension)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(image.pngData()!)

        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        print("REQUEST SENT HERE -----------")

        // Send a POST request to the URL, with the data we created earlier
        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
            if error == nil {
                print("GOT RESPONSE")
                let jsonData = try? JSONSerialization.jsonObject(with: responseData!, options: .allowFragments)
                if let json = jsonData as? [String: Any] {
                    print(json)
                }
            } else {
                print("GOT ERROR:")
                print(error!)
            }
        }).resume()
    }
    
    func getRequest(completion:@escaping (ResponseObj) -> ()) {
        URLSession.shared.dataTask(with:serverUrl) { (data, response, error) in
              if error != nil {
                  print("ERROR")
                print(error!)
              } else {
                  print("no error to be found")
                if let returnData = String(data: data!, encoding: .utf8) {
                    print(type(of: data!))
                    print("got some returnData")
                    print("it is " + returnData)
                    print(type(of: returnData))
                    
                    let response = try! JSONDecoder().decode(ResponseObj.self, from: data!)
                    print(response)
                    print("got response from get request")
                    completion(response)
                } else {
                  print("unable to parse response")
                }
              }
            }.resume()
    }
}
