//
//  User.swift
//  MSA
//
//  Created by Pavlo Kharambura on 2/20/18.
//  Copyright © 2018 easyapps.solutions. All rights reserved.
//

import Foundation

struct UserVO {
    var id: String?
    var email: String?
    var firstName: String?
    var lastname: String?
    var level: String?
    var age: Int?
    var sex: String?
    var height: Int?
    var heightType: String?
    var weight: Int?
    var weightType: String?
    var type: String?
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

