//
//  SignInViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 2/17/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

class SignInViewController: UIViewController {
   
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var fbButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    @IBAction func securePasswordViewButton(_ sender: Any) {

    }
    @IBAction func forgotPasswordButtonAction(_ sender: Any) {
    }
    
    @IBAction func loginWithEmail(_ sender: Any) {
        if emailTextField.text == "" || passwordTextField.text == nil {
            // введіть поля
        } else {
//            AppAuth.loginUser(email: emailTextField.text!, pass: passwordTextField.text!)
        }
        
    }
    @IBAction func loginWithFacebook(_ sender: Any) {
       AppAuth.loginFaceBook()
    }
    
}
