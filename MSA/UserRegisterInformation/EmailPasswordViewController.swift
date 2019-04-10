//
//  RegFirstViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 2/22/18.
//  Copyright © 2018 easyapps.solutions. All rights reserved.
//

import UIKit

class EmailPasswordViewController: UIViewController {

    @IBOutlet weak var blurView: UIVisualEffectView!
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
    
    private func showTermsOfUse() {
        guard let url = URL(string: "https://telegra.ph/Privacy-Police-and-Terms-Of-Use-03-12") else {
            return
        }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    @IBAction func showTermsOfUseAction(_ sender: Any) {
        showTermsOfUse()
    }
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func confirm(_ sender: Any) {
        if let email = emailTF.text, let pass = passTF.text, let passConf = passConfirmFT.text, email != "", pass != "", passConf != "" {
            if pass != passConf {
                AlertDialog.showAlert("Ошибка", message: "Пароли не совпадают!", viewController: self)
                return
            }
            if pass.count < 6 {
                AlertDialog.showAlert("Ошибка", message: "Пароль должен быть мимимум 6 символов!", viewController: self)
                return
            }
            if !email.isValidEmail {
                AlertDialog.showAlert("Ошибка", message: "Невалидная почта!", viewController: self)
                return
            }
            if !pass.isValidPassword {
                AlertDialog.showAlert("Ошибка", message: "Невалидный пароль!\nТолько 0-9 и a-Z", viewController: self)
                return
            }
            
            presenter.isAnyUserWith(userEmail: email) { (success, error) in
                if success {
                    self.presenter.setEmailAndPass(email: email, pass: pass)
                    self.performSegue(withIdentifier: "reg2", sender: nil)
                } else {
                    if let customError = error as? MSAError {
                        switch customError {
                        case .customError(let error):
                            let mess = error.message
                            AlertDialog.showAlert("Ошибка", message: mess ?? "Пользователь с таким именем уже зарегистрирован!", viewController: self)
                        default:
                            AlertDialog.showAlert("Ошибка", message: error?.localizedDescription ?? "Пользователь с таким именем уже зарегистрирован!", viewController: self)
                        }
                    }
                    AlertDialog.showAlert("Ошибка", message: error?.localizedDescription ?? "Пользователь с таким именем уже зарегистрирован!", viewController: self)
                }
            }
        } else {
            AlertDialog.showAlert("Ошибка", message: "Заполните все поля!", viewController: self)
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
    func startLoading() {
        blurView.alpha = 0.3
        activityIndicator.startAnimating()
    }
    func finishLoading() {
        blurView.alpha = 0
        activityIndicator.stopAnimating()
    }
    func setUser(user: UserVO) {}
    func userCreated() {}
    func userNotCreated() {}
}


