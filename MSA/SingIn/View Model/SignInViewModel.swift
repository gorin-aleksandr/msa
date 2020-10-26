//
//  SignInViewModel.swift
//  MSA
//
//  Created by Nik on 03.09.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit
import Firebase
import CoreData

enum SignInDataControllerType {
  case name
  case city
}

enum SignUpFlowType {
  case new
  case update
}

class SignInViewModel {
  
  var userName = ""
  var userLastName = ""
  var userCity = ""
  var userMail = ""
  var userType = ""
  var userPassword = ""
  var flowType: SignUpFlowType = .new
  var signInDataControllerType: SignInDataControllerType?
  var cities: [String] = []
  private let auth: AuthModule = AuthModule()
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  let presenter = SignUpPresenter(signUp: UserDataManager())
  
  init() {
    if let js = loadJson(filename: "cities") {
      cities = js.map { $0.name }
    }
  }
  
  func updateName(value: String) {
    userName = value
  }
  
  func updateCity(value: String) {
    userCity = value
  }
  
  func updateLastName(value: String) {
    userLastName = value
  }
  
  func updateMail(value: String) {
    userMail = value
  }
  
  func updatePassword(value: String) {
    userPassword = value
  }
  
  func updateUserType(value: String) {
    userType = value
  }
  
  func loginUserWithEmail(success: @escaping () -> (), failure: @escaping (_ error: String) -> ()) {
    guard InternetReachability.isConnectedToNetwork()  else {
      failure("")
      return
    }
    AuthModule.facebookAuth = false
    auth.loginUser(email: userMail, pass: userPassword) { (user, error) in
      if error == nil && user != nil {
        let user = UserVO(id: user?.id, email: user?.email, firstName: user?.firstName, lastName: user?.lastName, avatar: user?.avatar, level: user?.level, age: user?.age, sex: user?.sex, height: user?.height, heightType: user?.heightType, weight: user?.weight,weightType: user?.weightType, type: user?.type, purpose: user?.purpose, gallery: user?.gallery, friends: user?.friends, trainerId: user?.trainerId, sportsmen: user?.sportsmen, requests: user?.requests, city: user?.city)
        self.setUser(user: user)
        UserDataManager().getUser(callback: { (user, error) in
          if let user = user {
            AnalyticsSender.shared.logEvent(eventName: "log_in")
            self.setUser(user: user)
            success()
          } else {
            failure("Ошибка авторизации")
          }
        })
        return
      } else {
        if let error = error {
          let nsError = error as NSError
          if nsError.code == 17006 {
            failure("Учетные записи электронной почты и пароли не включены")
          } else if nsError.code == 17008 {
            failure("Адрес электронной почты неверный")
          } else if nsError.code == 17005 {
            failure("Учетная запись пользователя отключена")
          } else if nsError.code == 17009 {
            failure("Неверный пароль")
          } else {
            failure("Ошибка авторизации")
          }
        }
      }
    }
  }
  
  func setUser(user: UserVO) {
    AuthModule.currUser = user
    if let gallery = AuthModule.currUser.gallery {
      GalleryDataManager.GalleryItems = gallery
    }
    saveUser(context: self.context, user: user)
  }
  func setNoUser() {
    AuthModule.currUser = UserVO()
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
  
  func loginWithFacebook(success: @escaping (Bool) -> (), failure: @escaping (_ error: String) -> ()) {
    AuthModule.facebookAuth = true
    auth.loginFacebook { (user, error) in
      if error == nil && user != nil {
        let user = UserVO(id: user?.id, email: user?.email, firstName: self.userName != "" ? self.userName : user?.firstName, lastName:  self.userLastName != "" ? self.userLastName : user?.lastName, avatar: user?.avatar, level: nil, age: nil, sex: nil, height: nil, heightType: nil, weight: nil,weightType: nil, type: self.userType != "" ? self.userType : nil, purpose: nil, gallery: nil, friends: nil, trainerId: nil, sportsmen: nil, requests: nil, city: self.userCity != "" ? self.userCity : nil )
        self.setUser(user: user)
        UserDataManager().getUser(callback: { (user, error) in
          if let user = user {
            AnalyticsSender.shared.logEvent(eventName: "log_in")
            self.setUser(user: user)
            success(true)
          } else {
            if AuthModule.currUser.type != nil {
              self.presenter.createNewUser(newUser: AuthModule.currUser, success: {
                AnalyticsSender.shared.logEvent(eventName: "sign_up")
                AnalyticsSender.shared.logEvent(eventName: "user_city_registration", params: ["city": AuthModule.currUser.city ?? ""])
                switch AuthModule.currUser.userType {
                  case .sportsman:
                    AnalyticsSender.shared.logEvent(eventName: "sign_up_sportsman")
                  case .trainer:
                    AnalyticsSender.shared.logEvent(eventName: "sign_up_coach")
                }
                success(true)
              }) { (error) in
                failure(error)
              }
            } else {
              success(false)
            }
          }
        })
      } else {
        if let error = error {
          let error = error as NSError
          if error.code == 17004 {
            failure("Предоставленные учетные данные недействительны")
          } else if error.code == 17008 {
            failure("Адрес электронной почты искажен")
          } else if error.code == 17006 {
            failure("Учетные записи с поставщиком удостоверений, представленным учетными данными, не включены")
          } else if error.code == 17007 {
            failure("Учетные записи с поставщиком удостоверений, представленным учетными данными, не включены")
          } else if error.code == 17005 {
            failure("Учетная запись пользователя отключена")
          } else if error.code == 17009 {
            failure("Неверный пароль")
          } else if error.code == 17012 {
            failure("Пользователь с таким e-mail уже зарегестрирован")
          } else {
            failure("Ошибка авторизации")
          }
        } else {
          failure("FBCancel")
        }
      }
    }
  }
  
  func loginWithAppleId(credential: AuthCredential,success: @escaping (Bool) -> (), failure: @escaping (_ error: String) -> ()) {
    AuthModule.appleAuth = true
    auth.loginAppleId(credential: credential) { (user, error) in
      if error == nil && user != nil {
        let user = UserVO(id: user?.id, email: user?.email, firstName: self.userName != "" ? self.userName : user?.firstName, lastName:  self.userLastName != "" ? self.userLastName : user?.lastName, avatar: user?.avatar, level: nil, age: nil, sex: nil, height: nil, heightType: nil, weight: nil,weightType: nil, type: self.userType != "" ? self.userType : nil, purpose: nil, gallery: nil, friends: nil, trainerId: nil, sportsmen: nil, requests: nil, city: self.userCity != "" ? self.userCity : nil )
        self.setUser(user: user)
        UserDataManager().getUser(callback: { (user, error) in
          if let user = user {
            AnalyticsSender.shared.logEvent(eventName: "log_in")
            self.setUser(user: user)
            success(true)
          } else {
            if AuthModule.currUser.type != nil {
              self.presenter.createNewUser(newUser: AuthModule.currUser, success: {
                AnalyticsSender.shared.logEvent(eventName: "sign_up")
                AnalyticsSender.shared.logEvent(eventName: "user_city_registration", params: ["city": AuthModule.currUser.city ?? ""])
                switch AuthModule.currUser.userType {
                  case .sportsman:
                    AnalyticsSender.shared.logEvent(eventName: "sign_up_sportsman")
                  case .trainer:
                    AnalyticsSender.shared.logEvent(eventName: "sign_up_coach")
                }
                success(true)
              }) { (error) in
                failure(error)
              }
            } else {
              success(false)
            }
          }
        })
      } else {
        if let error = error {
          failure(error.localizedDescription)
        } else {
          failure("Ошибка авторизации")
          //self.view?.notLogged(resp: "FBCancel")
        }
      }
    }
  }
}
