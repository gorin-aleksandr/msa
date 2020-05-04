//
//  AuthFirebase.swift
//  MSA
//
//  Created by Pavlo Kharambura on 2/19/18.
//  Copyright © 2018 easyapps.solutions. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import FBSDKCoreKit
import FBSDKLoginKit

enum AuthErrors: String {
    case noRegistratedUser = "There is no user record corresponding to this identifier. The user may have been deleted."
    case wrongPassword = "The password is invalid or the user does not have a password."
    case userExist = "The email address is already in use by another account."
    case badEmailFormat = "The email address is badly formatted."
    case shortPassword = "The password must be 6 characters long or more."
    case anotherError = ""
}

class AuthModule {
    
    static var isLastUserCurrent: Bool = true
    static var currUser = UserVO()
    static var userAvatar: UIImage?
    static var pass = String()
    static var facebookAuth = false
    static var appleAuth = false

    static func sendRecoverPasswordRequest(email: String, callback: @escaping (_ error: Error?)->()) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: callback)
    }
    
    func registerUser(email: String, pass: String, callback: @escaping (_ user: UserVO?, _ error: Error?)->()) {
        Auth.auth().createUser(withEmail: email, password: pass) { (user, error) in
            if error == nil && user != nil {
              let user = UserVO(id: user?.user.uid, email: user?.user.email, firstName: nil, lastName: nil, avatar: nil, level: nil, age: nil, sex: nil, height: nil, heightType: nil, weight: nil,weightType: nil, type: nil, purpose: nil, gallery: nil, friends: nil, trainerId: nil, sportsmen: nil, requests: nil, city: nil)
                callback(user, nil)
            } else {
                callback(nil, error)
            }
        }
    }
    
    func loginUser(email: String, pass: String, callback: @escaping (_ user: UserVO?, _ error: Error?)->()) {
        Auth.auth().signIn(withEmail: email, password: pass) { (user, error) in
            if error == nil && user != nil {
                let user = UserVO(id: user?.user.uid, email: user?.user.email, firstName: nil, lastName: nil, avatar: nil, level: nil, age: nil, sex: nil, height: nil, heightType: nil, weight: nil,weightType: nil, type: nil, purpose: nil, gallery: nil, friends: nil, trainerId: nil, sportsmen: nil, requests: nil, city: nil)
                callback(user, nil)
            } else {
                callback(nil, error)
            }
        }
    }
    
    func loginFacebook(callback: @escaping (_ user: UserVO?, _ error: Error?)->()) {
      let fbLoginManager : LoginManager = LoginManager()
      fbLoginManager.logIn(permissions: ["public_profile","email"], from: SignInViewController()) { (result, error) -> Void in
            if (error == nil) {
              let fbloginresult : LoginManagerLoginResult = result!
              guard let accessToken = AccessToken.current else {
                    print("Failed to get access token")
                    callback(nil, error)
                    return
                }
                if (result?.isCancelled)!{
                    print("Canselled")
                    callback(nil, error)
                    return
                }
                if (fbloginresult.grantedPermissions.contains("email")) {
                    let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
                  let req = GraphRequest(graphPath: "me", parameters: ["fields":"email,name"], tokenString: accessToken.tokenString, version: nil, httpMethod: HTTPMethod(rawValue: "GET"))
                  req.start(completionHandler: { (connection, result, error) in
                        if(error == nil)
                        {
                            do {
                                let data = try JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:Any]
                                let name = json["name"] as? String
                                let email = json["email"] as? String
                                let nameArray = name?.components(separatedBy: " ")
                                AuthModule.currUser.email = email
                                AuthModule.currUser.firstName = nameArray?.first
                                AuthModule.currUser.lastName = nameArray?.last
                            } catch {
                                callback(nil, error)
                            }
                        } else {
                            callback(nil, error)
                        }
                    })
                    Auth.auth().signIn(with: credential, completion: { (user, error) in
                        if error == nil && user != nil {
                            let user = UserVO(id: user?.user.uid, email: AuthModule.currUser.email, firstName: AuthModule.currUser.firstName, lastName: AuthModule.currUser.lastName, avatar: nil, level: nil, age: nil, sex: nil, height: nil, heightType: nil, weight: nil,weightType: nil, type: nil, purpose: nil, gallery: nil, friends: nil, trainerId: nil, sportsmen: nil, requests: nil, city: nil)
                            callback(user, nil)
                        } else {
                            callback(nil, error)
                        }
                    })
                }
            } else {
                callback(nil, error)
            }
        }
    }
    
  func loginAppleId(credential: AuthCredential,callback: @escaping (_ user: UserVO?, _ error: Error?)->()) {
    
    Auth.auth().signIn(with: credential, completion: { (user, error) in
        if error == nil && user != nil {
          let user = UserVO(id: user?.user.uid, email: user?.user.email, firstName: AuthModule.currUser.firstName, lastName: AuthModule.currUser.lastName, avatar: nil, level: nil, age: nil, sex: nil, height: nil, heightType: nil, weight: nil,weightType: nil, type: nil, purpose: nil, gallery: nil, friends: nil, trainerId: nil, sportsmen: nil, requests: nil, city: nil)
            callback(user, nil)
        } else {
            callback(nil, error)
        }
    })
  
  }
    
  
  
    
}
