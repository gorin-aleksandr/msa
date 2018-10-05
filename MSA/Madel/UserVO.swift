//
//  User.swift
//  MSA
//
//  Created by Pavlo Kharambura on 2/20/18.
//  Copyright © 2018 easyapps.solutions. All rights reserved.
//

import Foundation
import UIKit

enum UserType {
    case sportsman
    case trainer
}

struct UserVO {
    var id: String?
    var email: String?
    var firstName: String?
    var lastName: String?
    var avatar: String?
    var level: String?
    var age: Int?
    var sex: String?
    var height: Int?
    var heightType: String?
    var weight: Int?
    var weightType: String?
    var type: String?
    var purpose: String?
    var gallery: [GalleryItemVO]?
    var friends: [String]?
    var trainerId: String?
    var sportsmen: [String]?
    var requests: [String]?
    // FIXME: Change default value after testing
    var city: String? = "Киев"
    var userType: UserType {
        switch  type  {
        case "ТРЕНЕР":
            return .trainer
        default:
            return .sportsman
        }
    }
    
    func getFullName() -> String {
        guard let name = firstName else {
            if let surname = lastName {
                return surname
            } else {
                return ""
            }
        }
        guard let surname = lastName else {
            return name
        }
        return name + " " + surname
    }
    
}

enum Sex: String {
    case male = "male"
    case famale = "famale"
}

enum HeightType: String {
    case sm = "sm"
    case ft = "ft"
}

enum WeightType: String {
    case kg = "kg"
    case pd = "pd"
}

struct UserLevel {

}

