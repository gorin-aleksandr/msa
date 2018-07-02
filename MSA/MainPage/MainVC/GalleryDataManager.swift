//
//  GalleryDataManager.swift
//  MSA
//
//  Created by Pavlo Kharambura on 4/17/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import Foundation
import UIKit

class GalleryDataManager {
    
    static var GalleryItems = [GalleryItemVO]()
    
    static func addItem(item: GalleryItemVO) {
        GalleryItems.insert(item, at: 0)
    }
    
    static let instance = GalleryDataManager()

    var currentItem = GalleryItemVO()
    
    func setCurrItemUrl(url: String) {
        currentItem.imageUrl = url
    }
    func setCurrItemVideoUrl(url: String) {
        currentItem.video_url = url
    }
    func setCurrItemVideoPath(path: String) {
        currentItem.videoPaht = path
    }
    func clear() {
        currentItem = GalleryItemVO()
    }
    func uploadPhoto(chosenImage: UIImage, returnedData: @escaping (_ data:Data?,_ error: Error?)->()) {
        var request  = URLRequest(url: URL(string: "https://api.imgur.com/3/image")!)
        request.httpMethod = "POST"
        let boundary = "\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Client-ID f241bc10bf2f4af", forHTTPHeaderField: "Authorization")
        request.httpBody = createBody(boundary: boundary,
                                      data: UIImageJPEGRepresentation(chosenImage,0.5)!,
                                      mimeType: "image/*")
        
        print(request)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                // check for fundamental networking error
                print("error=\(String(describing: error))")
                returnedData(nil, error)
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
                returnedData(nil, error)
            }
            if let response = String(data: data, encoding: .utf8) {
                print("Response = \(String(describing: response))")
                returnedData(data, nil)
            }
        }
        task.resume()
    }
    
    func createBody(boundary: String,
                    data: Data,
                    mimeType: String) -> Data {
        let body = NSMutableData()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n")
        body.appendString("Content-Type: \(mimeType)\r\n\r\n")
        body.append(data)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))
        return body as Data
    }
    
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: false)
        append(data!)
    }
}
