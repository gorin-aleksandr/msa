//
//  Errors.swift
//  MSA
//
//  Created by Andrey Krit on 12/7/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import Foundation

struct Errors {
    
    static func handleError(_ error: Error?, completion: (_ massage: String) -> ()) {
        var errorMessage = NSLocalizedString("Ошибка", comment: "")
        if let backendError = error as?  MSAError {
            
            switch backendError {
            case .network(let error):
                if (error as NSError).code == -1009 {
                    errorMessage = NSLocalizedString("error.label.internet_info", comment: "")
                }
            case .jsonSerialization(let error):
                errorMessage = error.localizedDescription
            case .customError(let error):
                errorMessage = error.localizedMessage()
            case .unknown:
                print("unknown error")
            }
        }
        completion(errorMessage)
    }
    
}

enum MSAError: Error {
    
    case network(error: Error)
    case jsonSerialization(error: Error)
    case customError(error: CustomError)
    case unknown
    
    init(base: Error, statusCode: Int, responseData: Data?) {
        if 200 ..< 300 ~= statusCode {
            self = .jsonSerialization(error: base)
        } else if let data = responseData,
            let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let errorDictionary = json as? [String: Any], let errorCode = errorDictionary["code"] as? String, let errorMessage = errorDictionary["message"] as? String {
            self = .customError(error: MSAError.CustomError(code: errorCode, message: errorMessage))
        } else {
            self = .network(error: base)
        }
    }
    
    struct CustomError {
        var code: String!
        var message: String!
        
        init(code: String, message: String) {
            self.code = code
            self.message = message
        }
        
        func localizedMessage() -> String {
            switch code {
            case "FIRAuthErrorCodeNetworkError":
                return NSLocalizedString("Ошибка соединения", comment: "")
            case "NoConnection":
                return NSLocalizedString("Отсутствует связь с сервером :(Пожалуйста, проверьте ваше подключение к интернету.", comment: "")
            default:
                return NSLocalizedString("Ошибка", comment: "")
            }
        }
    }
    
}
