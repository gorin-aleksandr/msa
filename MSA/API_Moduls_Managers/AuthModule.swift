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
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

enum AuthErrors: String {
    case noRegistratedUser = "There is no user record corresponding to this identifier. The user may have been deleted."
    case noSuchUser = "The password is invalid or the user does not have a password."
    case userExist = "The email address is already in use by another account."
    case badEmailFormat = "The email address is badly formatted."
    case shortPassword = "The password must be 6 characters long or more."
    case anotherError = ""
}

class AuthModule {
    
    static var currUser = UserVO()
    static var userAvatar: UIImage?
    static var pass = String()
    static var facebookAuth = false
    
    func registerUser(email: String, pass: String, callback: @escaping (_ user: UserVO?, _ error: Error?)->()) {
        Auth.auth().createUser(withEmail: email, password: pass) { (user, error) in
            if error == nil && user != nil {
                let user = UserVO(id: user?.uid, email: user?.email, firstName: nil, lastName: nil, avatar: nil, level: nil, age: nil, sex: nil, height: nil, heightType: nil, weight: nil,weightType: nil, type: nil, purpose: nil, gallery: nil, friends: nil, trainerId: nil, sportsmen: nil, requests: nil, city: nil)
                callback(user, nil)
            } else {
                callback(nil, error)
            }
        }
    }
    
    func loginUser(email: String, pass: String, callback: @escaping (_ user: UserVO?, _ error: Error?)->()) {
        Auth.auth().signIn(withEmail: email, password: pass) { (user, error) in
            if error == nil && user != nil {
                let user = UserVO(id: user?.uid, email: user?.email, firstName: nil, lastName: nil, avatar: nil, level: nil, age: nil, sex: nil, height: nil, heightType: nil, weight: nil,weightType: nil, type: nil, purpose: nil, gallery: nil, friends: nil, trainerId: nil, sportsmen: nil, requests: nil, city: nil)
                callback(user, nil)
            } else {
                callback(nil, error)
            }
        }
    }
    
    func loginFacebook(callback: @escaping (_ user: UserVO?, _ error: Error?)->()) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile","email"], from: SignInViewController()) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                guard let accessToken = FBSDKAccessToken.current() else {
                    print("Failed to get access token")
                    return
                }
                if (result?.isCancelled)!{
                    print("Canselled")
                    return
                }
                if (fbloginresult.grantedPermissions.contains("email")) {
                    let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
                    let req = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,name"], tokenString: accessToken.tokenString, version: nil, httpMethod: "GET")
                    req?.start(completionHandler: { (connection, result, error) in
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
                            } catch {}
                        }
                        else
                        { }
                    })
                    Auth.auth().signIn(with: credential, completion: { (user, error) in
                        if error == nil && user != nil {
                            let user = UserVO(id: user?.uid, email: AuthModule.currUser.email, firstName: AuthModule.currUser.firstName, lastName: AuthModule.currUser.lastName, avatar: nil, level: nil, age: nil, sex: nil, height: nil, heightType: nil, weight: nil,weightType: nil, type: nil, purpose: nil, gallery: nil, friends: nil, trainerId: nil, sportsmen: nil, requests: nil, city: nil)
                            callback(user, nil)
                        } else {
                            callback(nil, error)
                        }
                    })
                }
            }
        }
    }
    
    
    
}
