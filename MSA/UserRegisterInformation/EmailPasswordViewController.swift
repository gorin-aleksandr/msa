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

    private let presenter = SignUpPresenter(signUp: UserDataManager())

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
        if let email = emailTF.text, let pass = passTF.text, passTF.text == passConfirmFT.text {
                presenter.setEmailAndPass(email: email, pass: pass)
        } else {
            AlertDialog.showAlert("Ошибка", message: "Невалидный email, короткий пароль или пароли не совпадают", viewController: self)
        }
    }
    
}

extension EmailPasswordViewController: SignUpViewProtocol {
 
    func notUpdated() {
    }
    func next() {
    }
    func startLoading() {
    }
    
    func finishLoading() {
        
    }
    
    func setUser(user: UserVO) {
        
    }
    
    func userCreated() {
        
    }
    
    func userNotCreated() {
        
    }
    
}


