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

        passTF.delegate = self
        passConfirmFT.delegate = self
        emailTF.delegate = self
        
        presenter.attachView(view: self)
        
        // Do any additional setup after loading the view.
    }
    @IBAction func secure(_ sender: Any) {
        if let button = sender as? UIButton {
            if button.tag == 2 {
                passTF.isSecureTextEntry = !passTF.isSecureTextEntry
            } else if button.tag == 3 {
                passConfirmFT.isSecureTextEntry = !passConfirmFT.isSecureTextEntry
            }
        }
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

extension EmailPasswordViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField.tag {
        case 2,3:
            if string == "" {
                textField.text = ""
            }
            return true
        default:
            return true
        }
    }
}

extension EmailPasswordViewController: SignUpViewProtocol {
    func notUpdated() {}
    func next() {}
    func startLoading() {}
    func finishLoading() {}
    func setUser(user: UserVO) {}
    func userCreated() {}
    func userNotCreated() {}
}


