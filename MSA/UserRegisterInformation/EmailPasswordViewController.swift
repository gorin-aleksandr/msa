//
//  RegFirstViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 2/22/18.
//  Copyright © 2018 easyapps.solutions. All rights reserved.
//

import UIKit

class EmailPasswordViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {didSet{activityIndicator.stopAnimating()}}
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    @IBOutlet weak var passConfirmFT: UITextField!

    private let presenter = UserSignInPresenter(auth: AuthModule())

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.attachView(view: self)
        
        // Do any additional setup after loading the view.
    }
    @IBAction func secure(_ sender: Any) {
        passTF.isSecureTextEntry = !passTF.isSecureTextEntry
        passConfirmFT.isSecureTextEntry = !passConfirmFT.isSecureTextEntry
    }
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func confirm(_ sender: Any) {
        if emailTF.text != "" && passTF.text != "" && passTF.text == passConfirmFT.text {
            if AuthModule.currUser.email != emailTF.text {
                presenter.registerUser(email: emailTF.text!, password: passTF.text!)
            } else {
                registrated()
            }
        } else {
            AlertDialog.showAlert("Ошибка", message: "Невалидный email, короткий пароль или пароли не совпадают", viewController: self)
        }
    }
    
}

extension EmailPasswordViewController: SignInViewProtocol {
    
    func setNoUser() {  }
    
    func notRegistrated(resp: String) {
        AlertDialog.showAlert("Ошибка регистрации", message: resp, viewController: self)
    }
    
    func notLogged(resp: String) { }
    
    func loggedWithFacebook() { }
    
    func logged() { }
    
    func registrated() {
        DispatchQueue.main.async {
            let storyBoard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "regSecond") as! NameSurnameViewController
            self.show(nextViewController, sender: nil)
        }
    }
    
    func startLoading() {
        activityIndicator.startAnimating()
    }
    
    func finishLoading() {
        activityIndicator.stopAnimating()
    }
    
    func setUser(user: UserVO) {
        AuthModule.currUser = user
    }
    
    func userCreated() {
    }
    
    func userNotCreated() {
        AlertDialog.showAlert("Error", message: "Ошибка создания юзера", viewController: self)
    }
    
    
}


