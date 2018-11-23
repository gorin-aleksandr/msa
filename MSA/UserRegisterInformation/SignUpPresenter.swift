//
//  SignUpPresenter.swift
//  MSA
//
//  Created by Pavlo Kharambura on 2/22/18.
//  Copyright © 2018 easyapps.solutions. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol SignUpViewProtocol: class {
    func startLoading()
    func finishLoading()
    func next()
    func notUpdated()
    func setUser(user: UserVO)
    func userCreated()
    func userNotCreated()
}

class SignUpPresenter {
    
    private let signUpManager: UserDataManager
    private weak var view: SignUpViewProtocol?
    
    init(signUp: UserDataManager) {
        self.signUpManager = signUp
    }
    
    func attachView(view: SignUpViewProtocol){
        self.view = view
    }
    
    func setEmailAndPass(email: String, pass: String) {
        AuthModule.currUser.email = email
        AuthModule.pass = pass
        view?.next()
    }
    
    func createNewUser(newUser: UserVO) {
        self.view?.startLoading()
        signUpManager.createUser(user: newUser) { (created) in
            self.view?.finishLoading()
            if created {
                self.view?.userCreated()
                self.view?.setUser(user: newUser)
            } else {
                self.view?.userNotCreated()
            }
        }
    }
    
    func addProfileInfo(user: UserVO) {
        self.view?.startLoading()
        signUpManager.createUser(user: user) { (yes) in
            self.view?.finishLoading()
            if yes {
                self.view?.setUser(user: user)
                self.view?.next()
            } else {
                self.view?.notUpdated()
            }
        }
    }
    
    func saveUser(context: NSManagedObjectContext, user: UserVO) {
        let task = User(context: context)
        task.id = user.id
        task.email = user.email
        task.name = user.firstName
        task.surname = user.lastName
        task.type = user.type
        task.level = user.level
        task.sex = user.sex
        task.heightType = user.heightType
        task.weightType = user.weightType
        if let age = user.age {
            task.age = Int64(age)
        }
        if let height = user.height {
            task.height = Int64(height)
        }
        if let weight = user.weight {
            task.height = Int64(weight)
        }
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func loadLevels() {
        
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
    func setCity(city: String) {
        AuthModule.currUser.city = city
    }
    func setType(type: MSA_User_Type) {
        AuthModule.currUser.type = type.rawValue
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
    
}
