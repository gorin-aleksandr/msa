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
import Firebase

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
  var userRef = Database.database().reference().child("Users")
  
  private let signUpManager: UserDataManager
  private weak var view: SignUpViewProtocol?
  
  init(signUp: UserDataManager) {
    self.signUpManager = signUp
  }
  
  func attachView(view: SignUpViewProtocol){
    self.view = view
  }
  
  func isAnyUserWith(userEmail: String, callback: @escaping (_ success: Bool,_ error: Error?) -> ()) {
    guard InternetReachability.isConnectedToNetwork()  else {
      let connectionError = MSAError.customError(error: MSAError.CustomError(code: "NoConnection", message: "Нету соединения!"))
      callback(false, connectionError)
      return
    }
    view?.startLoading()
    userRef.observeSingleEvent(of: .value, with: { (snapshot) in
      self.view?.finishLoading()
      guard let data = snapshot.value as? [String : [String : Any]] else {
        callback(false, MSAError.customError(error: MSAError.CustomError(code: "", message: "")))
        return
      }
      var emails = [String]()
      for value in Array(data.values) {
        if let email = self.getEmail(from: value) {
          emails.append(email)
        }
      }
      if emails.contains(userEmail) {
        callback(false, MSAError.customError(error: MSAError.CustomError(code: "User exist", message: "Пользователь с такой почтой уже зарегистрирован!")))
      } else {
        callback(true, nil)
      }
    }) { (error) in
      print(error.localizedDescription)
      callback(false, error)
    }
  }
  
  
  private func getEmail(from value: [String : Any]?) -> String? {
    if let value = value {
      let email = value["email"] as? String
      return email
    }
    return nil
  }
  
  func setEmailAndPass(email: String, pass: String, name: String, lastName: String, city: String, userType: String) {
    AuthModule.currUser.email = email
    AuthModule.currUser.firstName = name
    AuthModule.currUser.lastName = lastName
    AuthModule.currUser.city = city
    AuthModule.currUser.type = userType
    AuthModule.pass = pass
    view?.next()
  }
  
  func createNewUser(newUser: UserVO, success: @escaping () -> (), failure: @escaping (_ error: String) -> ()) {
    signUpManager.createUser(user: newUser) { (created) in
      if created {
        self.view?.userCreated()
        self.view?.setUser(user: newUser)
        success()
      } else {
        self.view?.userNotCreated()
        failure("Ошибка создания пользователя")
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
    return ["женский", "мужской"]
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
