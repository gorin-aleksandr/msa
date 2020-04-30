//
//  SignInPresenter.swift
//  MSA
//
//  Created by Pavlo Kharambura on 2/20/18.
//  Copyright © 2018 easyapps.solutions. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Firebase

class UserSignInPresenter {
    
    private let auth: AuthModule
    private weak var view: SignInViewProtocol?
    
    init(auth: AuthModule) {
        self.auth = auth
    }
    
    func attachView(view: SignInViewProtocol){
        self.view = view
    }
    
    func loginUserWithEmail(email: String, password: String) {
        guard InternetReachability.isConnectedToNetwork()  else {
            self.view?.notLogged(resp: "")
            return
        }
        AuthModule.facebookAuth = false
        self.view?.startLoading()
        auth.loginUser(email: email, pass: password) { (user, error) in
            self.view?.finishLoading()
            if error == nil && user != nil {
                let user = UserVO(id: user?.id, email: user?.email, firstName: user?.firstName, lastName: user?.lastName, avatar: user?.avatar, level: user?.level, age: user?.age, sex: user?.sex, height: user?.height, heightType: user?.heightType, weight: user?.weight,weightType: user?.weightType, type: user?.type, purpose: user?.purpose, gallery: user?.gallery, friends: user?.friends, trainerId: user?.trainerId, sportsmen: user?.sportsmen, requests: user?.requests, city: user?.city)
                    self.view?.setUser(user: user)
                    UserDataManager().getUser(callback: { (user, error) in
                        if let user = user {
                            Analytics.logEvent("log_in", parameters: nil)
                            self.view?.setUser(user: user)
                            self.view?.logged()
                            self.view?.finishLoading()
                        } else {
                            self.view?.finishLoading()
                            self.view?.notLogged(resp: "Ошибка авторизации")
                        }
                    })
                    return
            } else {
//                if error?.localizedDescription == AuthErrors.wrongPassword.rawValue {
//                    self.view?.finishLoading()
//                    self.view?.notLogged(resp: "Неверный формат пароль.")
//                } else if error?.localizedDescription == AuthErrors.noRegistratedUser.rawValue {
//                    self.view?.finishLoading()
//                    self.view?.notLogged(resp: "Пользователь не зарегистрирован.")
//                } else if error?.localizedDescription == AuthErrors.badEmailFormat.rawValue {
//                    self.view?.finishLoading()
//                    self.view?.notLogged(resp: "Неверный формат email.")
//                } else {
//                    self.view?.finishLoading()
//                    self.view?.notLogged(resp: "Повторите позже.")
//                }

                if let error = error {
                    let nsError = error as NSError
                    if nsError.code == 17006 {
                        self.view?.notLogged(resp: "Учетные записи электронной почты и пароли не включены")
                    } else if nsError.code == 17008 {
                        self.view?.notLogged(resp: "Адрес электронной почты неверный")
                    } else if nsError.code == 17005 {
                        self.view?.notLogged(resp: "Учетная запись пользователя отключена")
                    } else if nsError.code == 17009 {
                        self.view?.notLogged(resp: "Неверный пароль")
                    } else {
                        self.view?.notLogged(resp: "Ошибка авторизации")
                    }
                }
            }
        }
    }
    
    func registerUser(email: String, password: String) {
        self.view?.startLoading()
        auth.registerUser(email: email, pass: password) { (user, error) in
            if error == nil && user != nil {
                let user = UserVO(id: user?.id, email: user?.email, firstName: AuthModule.currUser.firstName, lastName: AuthModule.currUser.lastName, avatar: nil, level: AuthModule.currUser.level, age: AuthModule.currUser.age, sex: AuthModule.currUser.sex, height: AuthModule.currUser.height, heightType: nil, weight: AuthModule.currUser.weight,weightType: nil, type: AuthModule.currUser.type, purpose: user?.purpose, gallery: nil, friends: nil, trainerId: nil, sportsmen: nil, requests: nil, city: AuthModule.currUser.city)
                self.view?.setUser(user: user)
                self.view?.registrated()
                self.view?.finishLoading()
            } else if error?.localizedDescription == AuthErrors.badEmailFormat.rawValue {
                self.view?.finishLoading()
                    self.view?.notRegistrated(resp: "Формат email неверный")
            } else if error?.localizedDescription == AuthErrors.userExist.rawValue {
                self.view?.finishLoading()
                    self.view?.notRegistrated(resp: "Пользователь с таким email уже зарегистрирован")
            } else if error?.localizedDescription == AuthErrors.shortPassword.rawValue {
                self.view?.finishLoading()
                    self.view?.notRegistrated(resp: "Пароль слишком короткий")
            } else {
                self.view?.finishLoading()
                    self.view?.notRegistrated(resp: "Ошибка регистрации")
            }
        }
    }
    
    func loginWithFacebook() {
        self.view?.startLoading()
        AuthModule.facebookAuth = true
        auth.loginFacebook { (user, error) in
            self.view?.finishLoading()
            if error == nil && user != nil {
                let user = UserVO(id: user?.id, email: user?.email, firstName: user?.firstName, lastName: user?.lastName, avatar: user?.avatar, level: nil, age: nil, sex: nil, height: nil, heightType: nil, weight: nil,weightType: nil, type: nil, purpose: nil, gallery: nil, friends: nil, trainerId: nil, sportsmen: nil, requests: nil, city: nil)
                self.view?.setUser(user: user)
                self.view?.loggedWithFacebook()
                return
            } else {
                if let error = error {
                    let error = error as NSError
                    if error.code == 17004 {
                        self.view?.notLogged(resp: "Предоставленные учетные данные недействительны")
                    } else if error.code == 17008 {
                        self.view?.notLogged(resp: "Адрес электронной почты искажен")
                    } else if error.code == 17006 {
                        self.view?.notLogged(resp: "Учетные записи с поставщиком удостоверений, представленным учетными данными, не включены")
                    } else if error.code == 17007 {
                        self.view?.notLogged(resp: "Электронная почта, указанная в учетных данных, уже используется существующей учетной записью")
                    } else if error.code == 17005 {
                        self.view?.notLogged(resp: "Учетная запись пользователя отключена")
                    } else if error.code == 17009 {
                        self.view?.notLogged(resp: "Неверный пароль")
                    } else if error.code == 17012 {
                        self.view?.notLogged(resp: "Пользователь с таким e-mail уже зарегестрирован")
                    } else {
                        self.view?.notLogged(resp: "Ошибка авторизации")
                    }
                } else {
                    self.view?.notLogged(resp: "FBCancel")
                }
            }
        }
    }
    
    func loginWithAppleId(credential: AuthCredential) {
          self.view?.startLoading()
          AuthModule.appleAuth = true
          auth.loginAppleId(credential: credential) { (user, error) in
            self.view?.finishLoading()
            if error == nil && user != nil {
                let user = UserVO(id: user?.id, email: user?.email, firstName: user?.firstName, lastName: user?.lastName, avatar: user?.avatar, level: nil, age: nil, sex: nil, height: nil, heightType: nil, weight: nil,weightType: nil, type: nil, purpose: nil, gallery: nil, friends: nil, trainerId: nil, sportsmen: nil, requests: nil, city: nil)
                self.view?.setUser(user: user)
                self.view?.loggedWithFacebook()
                return
            } else {
                if let error = error {
                } else {
                    self.view?.notLogged(resp: "FBCancel")
                }
            }
          }
    }
      
  
    func saveUser(context: NSManagedObjectContext, user: UserVO) {
        deleteUserBlock(context: context)
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
        task.trainerId = user.trainerId
        task.city = user.city
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
    
    func deleteUserBlock(context: NSManagedObjectContext) {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            let _ = try context.execute(request)
        } catch {
            
        }
    }
    
    func fetchUser(context: NSManagedObjectContext)  {
        var loggedUser = UserVO()
        do {
            let user: [User] = try context.fetch(User.fetchRequest())
            loggedUser.id = user.first?.id
            loggedUser.avatar = user.first?.avatar
            loggedUser.email = user.first?.email
            loggedUser.firstName = user.first?.name
            loggedUser.lastName = user.first?.surname
            loggedUser.level = user.first?.level
            loggedUser.type = user.first?.type
            loggedUser.sex = user.first?.sex
            loggedUser.weightType = user.first?.weightType
            loggedUser.heightType = user.first?.heightType
            loggedUser.avatar = user.first?.avatar
            loggedUser.purpose = user.first?.purpose
            loggedUser.trainerId = user.first?.trainerId
            loggedUser.city = user.first?.city
            
            if let age = user.first?.age {
                loggedUser.age = Int(age)
            }
            if let height = user.first?.height {
                loggedUser.height = Int(height)
            }
            if let weight = user.first?.weight {
                loggedUser.weight = Int(weight)
            }
            if let _ = loggedUser.id {
                AuthModule.currUser = loggedUser
            }
            if let _ = AuthModule.currUser.id {
                self.view?.logged()
            }
        } catch {
            print("Fetching Failed")
        }
    }

    func setUser(user: UserVO, context: NSManagedObjectContext) {
        AuthModule.currUser = user
        if let gallery = AuthModule.currUser.gallery {
            GalleryDataManager.GalleryItems = gallery
        }
        saveUser(context: context, user: user)
    }
    func setNoUser() {
        AuthModule.currUser = UserVO()
    }
}
