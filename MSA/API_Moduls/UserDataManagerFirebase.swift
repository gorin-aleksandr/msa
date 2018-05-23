//
//  File.swift
//  MSA
//
//  Created by Pavlo Kharambura on 2/21/18.
//  Copyright © 2018 easyapps.solutions. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class UserDataManager {

    var userRef = Database.database().reference().child("Users")

    func createUser(user: UserVO, callback: @escaping (_ created: Bool)->()) {
        let key = AuthModule.currUser.id
        let newUser = [
            "id": key,
            "email": user.email,
            "name": user.firstName,
            "surname": user.lastname,
            "level": user.level,
            "age": user.age,
            "sex": user.sex,
            "height": user.height,
            "heightType": user.heightType,
            "weight": user.weight,
            "weightType": user.weightType,
            "type": user.type
        ] as [String:Any]
        
        userRef.child(key!).setValue(newUser) { (error, ref) in
            if error == nil {
                callback(true)
            } else {
                callback(false)
            }
        }
    }
    
    func getUser(callback: @escaping (_ user: UserVO?)->()) {
        
        let userId = AuthModule.currUser.id
        userRef.child(userId!).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            var user: UserVO?
            if value != nil {
                user = UserVO(id: value!["id"] as? String,
                                  email: value!["email"] as? String,
                                  firstName: value!["name"] as? String,
                                  lastname: value!["surname"] as? String,
                                  level: value!["level"] as? String,
                                  age: value!["age"] as? Int,
                                  sex: value!["sex"] as? String,
                                  height: value!["height"] as? Int,
                                  heightType: value!["heightType"] as? String,
                                  weight: value!["weight"] as? Int,
                                  weightType: value!["weightType"] as? String,
                                  type: value!["type"] as? String)
            }
            callback(user)
        }) { (error) in
            print(error.localizedDescription)
            callback(nil)
        }
    }
    
}
