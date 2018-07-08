//
//  File.swift
//  MSA
//
//  Created by Pavlo Kharambura on 2/21/18.
//  Copyright © 2018 easyapps.solutions. All rights reserved.
//

import Foundation
import Firebase

class UserDataManager {
    
    init() {
        print("init")
    }
    
    var userRef = Database.database().reference().child("Users")
    var storageRef = Storage.storage().reference()
    var levelsRef = Database.database().reference().child("Levels")
    
    func addInfo(user: UserVO, callback: @escaping (_ created: Bool)->()) {
        if let key = AuthModule.currUser.id {
            let newInfo = [
                "level": user.level,
                "age": user.age,
                "sex": user.sex,
                "height": user.height,
                "heightType": user.heightType,
                "weight": user.weight,
                "weightType": user.weightType
                ] as [String:Any]
            
            userRef.child(key).setValue(newInfo) { (error, ref) in
                if error == nil {
                    callback(true)
                } else {
                    callback(false)
                }
            }
        }
    }
    
    func createUser(user: UserVO, callback: @escaping (_ created: Bool)->()) {
        if let key = AuthModule.currUser.id {
            let newUser = [
                "id": key,
                "email": user.email,
                "name": user.firstName,
                "surname": user.lastName,
                "level": user.level,
                "age": user.age,
                "sex": user.sex,
                "height": user.height,
                "heightType": user.heightType,
                "weight": user.weight,
                "weightType": user.weightType,
                "type": user.type
                ] as [String:Any]
            userRef.child(key).setValue(newUser) { (error, ref) in
                if error == nil {
                    callback(true)
                } else {
                    callback(false)
                }
            }
        }
    }
    
    func getLevels() {
        levelsRef.observeSingleEvent(of: .value) { (snapchot) in
            print(snapchot)
        }
    }
    
    func getUser(callback: @escaping (_ user: UserVO?)->()) {
        if let userId = AuthModule.currUser.id {
            userRef.child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let value = snapshot.value as? [String : Any]
                let user = self.makeUser(from: value)
                callback(user)
            }) { (error) in
                print(error.localizedDescription)
                callback(nil)
            }
        }
    }
    
    func loadAllUsers(callback: @escaping (_ community: [UserVO]) -> ()) {
        userRef.observeSingleEvent(of: .value) { (snapshot) in
            guard let data = snapshot.value as? [String : [String : Any]] else {
                print(snapshot.value)
                print("Error occured while parsing community for key from database")
                return
            }
            
            let values = Array(data.values)
            
            var community: [UserVO] = []
                for value in values {
                    if let user = self.makeUser(from: value) {
                        community.append(user)
                    }
                }
            callback(community)
        }
    }
    
    private func makeUser(from value: [String : Any]?) -> UserVO? {
        var user: UserVO?
        var gallery = [GalleryItemVO]()
        if let value = value {
            if let array = value["gallery"] as? [[String:Any]] {
                for gal in array {
                    var item = GalleryItemVO()
                    if let image = gal["imageData"] as? String {
                        item.imageUrl = image
                    }
                    if let video = gal["videoPath"] as? String {
                        item.videoPaht = video
                    }
                    if let videoImage = gal["videoUrl"] as? String {
                        item.video_url = videoImage
                    }
                    gallery.append(item)
                }
            }
            user = UserVO(id: value["id"] as? String,
                          email: value["email"] as? String,
                          firstName: value["name"] as? String,
                          lastName: value["surname"] as? String,
                          avatar: value["userPhoto"] as? String,
                          level: value["level"] as? String,
                          age: value["age"] as? Int,
                          sex: value["sex"] as? String,
                          height: value["height"] as? Int,
                          heightType: value["heightType"] as? String,
                          weight: value["weight"] as? Int,
                          weightType: value["weightType"] as? String,
                          type: value["type"] as? String,
                          purpose: value["purpose"] as? String,
                          gallery: gallery,
                          city: "Киев")
        }
        return user
    }
    
    func updateProfile(_ user: UserVO, callback: @escaping (_ created: Bool,_ err: Error?)->()) {
        if let key = AuthModule.currUser.id {
            let update = [
                "id": key,
                "email": user.email,
                "name": user.firstName,
                "surname": user.lastName,
                "level": user.level,
                "age": user.age,
                "sex": user.sex,
                "height": user.height,
                "heightType": user.heightType,
                "weight": user.weight,
                "weightType": user.weightType,
                "type": user.type
                ] as [String:Any]
            userRef.child(key).updateChildValues(update, withCompletionBlock: { (error, ref) in
                if error == nil {
                    callback(true,error)
                } else {
                    callback(false,error)
                }
            })
        }
    }
    
    
    deinit {
        print("UserDatDeinited")
    }
}
