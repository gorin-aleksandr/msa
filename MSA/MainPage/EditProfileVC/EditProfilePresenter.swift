//
//  EditProfilePresenter.swift
//  MSA
//
//  Created by Pavlo Kharambura on 4/17/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Firebase
import RealmSwift

class EditProfilePresenter {
    
    private let profile: UserDataManager
    private weak var view: EditProfileProtocol?


    init(profile: UserDataManager) {
        self.profile = profile
    }
    
    func attachView(view: EditProfileProtocol){
        self.view = view
    }
    
    func deleteTrainer(_ trainerId: String, deleted: ()->(), error: ()->()) {
        let myId = AuthModule.currUser.id ?? ""
        let dispatch = DispatchGroup()
        var failureList = [Error]()
        
        if !InternetReachability.isConnectedToNetwork() {
            error()
        } else {
            dispatch.enter()
            profile.removeTrainer(with: trainerId, from: myId) { (success, error) in
                if let error = error  {
                    failureList.append(error)
                    dispatch.leave()
                } else {
                    dispatch.leave()
                }
            }
            dispatch.enter()
            profile.removeFromSportsmen(idToRemove: myId, userId: trainerId, callback: { (_, error) in
                if let error = error {
                    failureList.append(error)
                    dispatch.leave()
                } else {
                    dispatch.leave()
                }
            })
            if failureList.isEmpty {
                AuthModule.currUser.trainerId = nil
                deleted()
            } else {
                error()
            }
        }
    }
    
    func getTrainerInfo(trainer id: String, success: @escaping (_ trainer: UserVO)->()) {
        Database.database().reference().child("Users").child(id).observeSingleEvent(of: .value) { (s) in
            guard let id = s.childSnapshot(forPath: "id").value as? String else {return}
            var trainer = UserVO()
            trainer.id = id
            trainer.avatar = s.childSnapshot(forPath: "userPhoto").value as? String
            trainer.firstName = s.childSnapshot(forPath: "name").value as? String
            trainer.lastName = s.childSnapshot(forPath: "surname").value as? String

            success(trainer)
        }
    }
    
    func updateUserAvatar(_ image: UIImage) {
        if let id = AuthModule.currUser.id {
            self.view?.startLoading()
            if let data = UIImageJPEGRepresentation(image, 0.5) {
                // Create a reference to the file you want to upload
                let avatarUpdateRef = profile.storageRef.child("\(id)/avatar.jpg")
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                // Upload the file to the path "images/rivers.jpg"
                avatarUpdateRef.putData(data, metadata: metadata) { (metadata, error) in
                    guard let metadata = metadata else {
                        self.view?.finishLoading()
                        if let error = error?.localizedDescription {
                            self.view?.errorOcurred(error)
                        }
                        return
                    }
                    if let downloadURL = metadata.downloadURL()?.absoluteString {
                        self.profile.userRef.child(id).updateChildValues(["userPhoto": downloadURL], withCompletionBlock: { (error, ref) in
                            AuthModule.currUser.avatar = downloadURL
                            self.getImage()
                        })
                    }
                }
            }
            
        }
    }

    func getImage() {
        if let id = AuthModule.currUser.id {
            profile.userRef.child(id).observe(.value, with: { (snapshot) in
                // check if user has photo
                if snapshot.hasChild("userPhoto"){
                    // set image locatin
                    let filePath = "\(id)/avatar.jpg"
                    // Assuming a < 10MB file, though you can change that
                    self.profile.storageRef.child(filePath).getData(maxSize: 10*1024*1024, completion: { (data, error) in
                        self.view?.finishLoading()
                        if let data = data {
                            if let userPhoto = UIImage(data: data) {
                                self.view?.setAvatar(image: userPhoto)
                            }
                        } else {
                            if let error = error?.localizedDescription {
                                self.view?.errorOcurred(error)
                            }
                        }
                    })
                }
            })
        }
    }
    
    func setPurpose(purpose: String) {
        if let id = AuthModule.currUser.id {
            self.view?.startLoading()
            profile.userRef.child(id).updateChildValues(["purpose": purpose], withCompletionBlock: { (error, ref) in
                self.view?.finishLoading()
                if let err = error?.localizedDescription {
                    self.view?.errorOcurred(err)
                } else {
                    AuthModule.currUser.purpose = purpose
                    self.view?.purposeSetted()
                }
            })
        }
    }
    
    func updateUserProfile(_ profile: UserVO) {
        view?.startLoading()
        self.profile.updateProfile(profile) { (updated,error) in
            self.view?.finishLoading()
            if updated {
                self.view?.setUser(user: AuthModule.currUser)
            } else {
                if let err = error?.localizedDescription {
                    self.view?.errorOcurred(err)
                }
            }
        }
    }
    
    func saveUser(context: NSManagedObjectContext, user: UserVO) {
        deleteUserBlock(context: context, callback: {_ in })
        let task = User(context: context)
        task.avatar = user.avatar
        task.id = user.id
        task.email = user.email
        task.name = user.firstName
        task.surname = user.lastName
        task.type = user.type
        task.level = user.level
        task.sex = user.sex
        task.heightType = user.heightType
        task.weightType = user.weightType
        task.purpose = user.purpose
        if let age = user.age {
            task.age = Int64(age)
        }
        if let height = user.height {
            task.height = Int64(height)
        }
        if let weight = user.weight {
            task.weight = Int64(weight)
        }
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func deleteUserBlock(context: NSManagedObjectContext, callback: @escaping (_ logouted: Bool)->()) {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            let _ = try context.execute(request)
            callback(true)
        } catch {
            callback(false)
        }
    }
    
    func clearRealm() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    func setUser(user: UserVO, context: NSManagedObjectContext) {
        AuthModule.currUser = user
        saveUser(context: context, user: user)
    }

    func setNoUser() {
        AuthModule.currUser = UserVO()
    }
    
    func getlevels() -> [String] {
        return ["Новичок", "Любитель", "Продвинутый", "Профессионал"]
    }
    func getSexes() -> [String] {
        return [Sex.famale.rawValue, Sex.male.rawValue]
    }
    func getAges() -> [Int] {
        var ages = [Int]()
        for i in 4...99 {
            ages.append(i)
        }
        return ages
    }
    func getWeight() -> [Int] {
        var weight = [Int]()
        for i in 30...200 {
            weight.append(i)
        }
        return weight
    }
    func getHeight() -> [Int] {
        var height = [Int]()
        for i in 40...220 {
            height.append(i)
        }
        return height
    }
    
    func setName(name: String) {
        AuthModule.currUser.firstName = name
    }
    func setSurname(surname: String) {
        AuthModule.currUser.lastName = surname
    }
    func setType(type: MSA_User_Type) {
        AuthModule.currUser.type = type.rawValue
    }
    func setEmail(email: String) {
        AuthModule.currUser.email = email
    }
    func setCity(city: String) {
        AuthModule.currUser.city = city
    }
    func setAge(age: Int) {
        AuthModule.currUser.age = age
    }
    func setHeight(height: Int) {
        AuthModule.currUser.height = height
    }
    func setWeight(weight: Int) {
        AuthModule.currUser.weight = weight
    }
    func setSex(sex: String) {
        AuthModule.currUser.sex = sex
    }
    func setLevel(level: String) {
        AuthModule.currUser.level = level
    }
    func setHeightType(type: HeightType) {
        AuthModule.currUser.heightType = type.rawValue
    }
    func setWeightType(type: WeightType) {
        AuthModule.currUser.weightType = type.rawValue
    }
    
    deinit {
        print("deinit")
    }
    
    func clearDB() {
        let realm = try! Realm()
        let trainings = realm.objects(Training.self)
        let exercises = realm.objects(Exercise.self)
        try! realm.write {
            realm.delete(trainings)
            realm.delete(exercises)
        }
    }
    
    
}
