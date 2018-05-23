//
//  SignUpPresenter.swift
//  MSA
//
//  Created by Pavlo Kharambura on 2/22/18.
//  Copyright © 2018 easyapps.solutions. All rights reserved.
//

import Foundation
import UIKit

protocol SignUpView {
    func startLoading()
    func finishLoading()
    func setUser(user: UserVO)
    func userCreated()
    func userNotCreated()
    func openPicker(picker: UIPickerView)
}


class SignUpPresenter {
    
    private let signUpManager: UserDataManager
    private var view: SignUpView?
    
    init(signUp: UserDataManager) {
        self.signUpManager = signUp
    }
    
    func attachView(view: SignUpView){
        self.view = view
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
    
}
