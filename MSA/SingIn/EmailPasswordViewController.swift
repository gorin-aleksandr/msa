//
//  RegFirstViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 2/22/18.
//  Copyright © 2018 easyapps.solutions. All rights reserved.
//

import UIKit

class EmailPasswordViewController: UIViewController {
  
  //    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {didSet{activityIndicator.stopAnimating()}}
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var passwordConfirmTextField: UITextField!
  @IBOutlet weak var signUpButton: UIButton!
  @IBOutlet weak var privacyLabel: UILabel!
  
  private let presenter = SignUpPresenter(signUp: UserDataManager())
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    
    presenter.attachView(view: self)
  }
  
  func setupUI() {
    emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 0.70)])
    emailTextField.backgroundColor = UIColor.emailPasswordTextFieldGrey
    emailTextField.textColor = .white
    emailTextField.roundCorners(.allCorners, radius: 16)
    emailTextField.font = UIFont(name: Fonts.SFProDisplayRegular, size: 16)
    if let myImage = UIImage(named: "Clear Icon"){
      emailTextField.withImage(direction: .Right, image: myImage, colorSeparator: UIColor.orange, colorBorder: UIColor.clear)
    }
    let emailClearTap = UITapGestureRecognizer(target: self, action: #selector(self.emailClearAction(_:)))
    emailTextField.rightView!.addGestureRecognizer(emailClearTap)
    emailTextField.rightView!.isUserInteractionEnabled = true
    emailTextField.rightViewMode = .whileEditing
    emailTextField.delegate = self

    passwordTextField.attributedPlaceholder = NSAttributedString(string: "Пароль", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 0.70)])
    passwordTextField.backgroundColor = UIColor.emailPasswordTextFieldGrey
    passwordTextField.textColor = .white
    passwordTextField.roundCorners(.allCorners, radius: 16)
    passwordTextField.font = UIFont(name: Fonts.SFProDisplayRegular, size: 16)
    if let myImage = UIImage(named: "eye"){
      passwordTextField.withImage(direction: .Right, image: myImage, colorSeparator: UIColor.orange, colorBorder: UIColor.clear)
    }
    let showHidePasswordTap = UITapGestureRecognizer(target: self, action: #selector(self.showHidePasswordAction(_:)))
    passwordTextField.rightView!.addGestureRecognizer(showHidePasswordTap)
    passwordTextField.rightView!.isUserInteractionEnabled = true
    passwordTextField.rightViewMode = .whileEditing
    passwordTextField.delegate = self

    
    passwordConfirmTextField.attributedPlaceholder = NSAttributedString(string: "Пароль повторно", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 0.70)])
    passwordConfirmTextField.backgroundColor = UIColor.emailPasswordTextFieldGrey
    passwordConfirmTextField.textColor = .white
    passwordConfirmTextField.roundCorners(.allCorners, radius: 16)
    passwordConfirmTextField.font = UIFont(name: Fonts.SFProDisplayRegular, size: 16)
    passwordConfirmTextField.delegate = self
    
    signUpButton.setTitle("Создать аккаунт", for: .normal)
    signUpButton.titleLabel?.font = UIFont(name: Fonts.SFProDisplayBold, size: 16)
    signUpButton.setTitleColor(.white, for: .normal)
    signUpButton.setBackgroundColor(color: UIColor.newBlue, forState: .normal)
    signUpButton.setImage(nil, for: .normal)
    signUpButton.roundCorners(.allCorners, radius: 12)
    signUpButton.addTarget(self, action: #selector(signUpAction(_:)), for: .touchUpInside)
    
    privacyLabel.font = UIFont.systemFont(ofSize: 13)
    privacyLabel.textColor = UIColor.textGrey
    privacyLabel.text = "Продолжая, вы соглашаетесь с Политикой конфедициальности и Условиями пользования."
    
    
  }
  
  @objc func emailClearAction(_ sender: UITapGestureRecognizer) {
    emailTextField.text = ""
  }
  
  @objc func showHidePasswordAction(_ sender: UITapGestureRecognizer) {
    passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
  }
  
  @objc func signUpAction(_ sender: UIButton) {
    if sender.isSelected {
      //let nextViewController = signInStoryboard.instantiateViewController(withIdentifier: "OnboardingNameViewController") as! OnboardingNameViewController
      //self.navigationController?.pushViewController(nextViewController, animated: true)
    }
  }
  
  @IBAction func secure(_ sender: Any) {
    if let button = sender as? UIButton {
      if button.tag == 2 {
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
      } else if button.tag == 3 {
        passwordConfirmTextField.isSecureTextEntry = !passwordConfirmTextField.isSecureTextEntry
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
    if let email = emailTextField.text, let pass = passwordTextField.text, let passConf = passwordConfirmTextField.text, email != "", pass != "", passConf != "" {
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
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    if textField == emailTextField {
      passwordTextField.becomeFirstResponder()
    } else if textField == passwordTextField {
      passwordConfirmTextField.becomeFirstResponder()
    } else {
      emailTextField.becomeFirstResponder()
    }
    return true
  }
  
}

extension EmailPasswordViewController: SignUpViewProtocol {
  func notUpdated() {}
  func next() {}
  func startLoading() {
    //        activityIndicator.startAnimating()
  }
  func finishLoading() {
    //      activityIndicator.stopAnimating()
  }
  func setUser(user: UserVO) {}
  func userCreated() {}
  func userNotCreated() {}
}

