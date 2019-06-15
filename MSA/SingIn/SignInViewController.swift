//
//  SignInViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 2/17/18.
//  Copyright © 2018 easyapps.solutions. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

protocol SignInViewProtocol: class {
    func startLoading()
    func finishLoading()
    func setUser(user: UserVO)
    func setNoUser()
    func notRegistrated(resp: String)
    func notLogged(resp: String)
    func loggedWithFacebook()
    func logged()
    func registrated()
}

class SignInViewController: BasicViewController, UIGestureRecognizerDelegate {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {didSet{activityIndicator.stopAnimating()}}
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var logInButton: UIButton! { didSet { logInButton.layer.cornerRadius = 10 } }
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    private let presenter = UserSignInPresenter(auth: AuthModule())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.attachView(view: self)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        presenter.fetchUser(context: context)
        AuthModule.currUser = UserVO()
    }
    
    @IBAction func securePasswordViewButton(_ sender: Any) {
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
    }
    @IBAction func forgotPasswordButtonAction(_ sender: Any) {
        DispatchQueue.main.async {
            let storyBoard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "passwordRecover") as! PasswordRecoveryViewController
            self.show(nextViewController, sender: nil)
        }
    }
    @IBAction func login(_ sender: Any) {
        presenter.loginUserWithEmail(email: emailTextField.text!, password: passwordTextField.text!)
    }
    @IBAction func loginWithFacebook(_ sender: Any) {
        presenter.loginWithFacebook()
    }

}

extension SignInViewController: SignInViewProtocol {
    
    func goToMain() {
        DispatchQueue.main.async {
            let storyBoard = UIStoryboard(name: "Profile", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarVC") as! UITabBarController
            self.show(nextViewController, sender: nil)
            self.view.isUserInteractionEnabled = true
        }
    }
    
    func loggedWithFacebook() {
        UserDataManager().getUser { (user, error) in
            if user == nil {
                DispatchQueue.main.async {
                    let storyBoard = UIStoryboard(name: "Main", bundle:nil)
                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "regSecond") as! NameSurnameViewController
                    self.show(nextViewController, sender: nil)
                }
            } else {
                self.setUser(user: user!)
                self.logged()
            }
        }
    }
    
    func logged() {
        goToMain()
    }
    
    func registrated() {
        goToMain()
    }
    
    func notRegistrated(resp: String) {
        self.view.isUserInteractionEnabled = true
        AlertDialog.showAlert("Ошибка регистрации", message: resp, viewController: self)
    }
    
    func notLogged(resp: String) {
        self.view.isUserInteractionEnabled = true
        if resp == "" {
            AlertDialog.showAlert("Нет подключения к интернету.", message: "Проверьте соединение и повторите попытку позже.", viewController: self)
        } else {
            if resp != "FBCancel" {
                AlertDialog.showAlert("Ошибка авторизации", message: resp, viewController: self)
            }
        }
    }
    
    func startLoading() {
        self.view.isUserInteractionEnabled = false
        blurView.alpha = 0.3
        activityIndicator.startAnimating()
    }
    
    func finishLoading() {
        blurView.alpha = 0
        activityIndicator.stopAnimating()
    }
    
    func setUser(user: UserVO) {
        presenter.setUser(user: user, context: context)
    }
    
    func setNoUser() {
        presenter.setNoUser()
    }
    
}

extension SignInViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            emailTextField.becomeFirstResponder()
        }
        return true
    }
}
