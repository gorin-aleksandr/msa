//
//  RegFirstViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 2/22/18.
//  Copyright © 2018 easyapps.solutions. All rights reserved.
//

import UIKit
import SVProgressHUD

class EmailPasswordViewController: UIViewController {
  
  //    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {didSet{activityIndicator.stopAnimating()}}
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var passwordConfirmTextField: UITextField!
  @IBOutlet weak var signUpButton: UIButton!
  @IBOutlet weak var privacyLabel: UILabel!
  @IBOutlet weak var logoImageView: UIImageView!
  
  private let presenter = SignUpPresenter(signUp: UserDataManager())
  private let signInpresenter = UserSignInPresenter(auth: AuthModule())

  var viewModel: SignInViewModel?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Регистрация"
    setupUI()
    presenter.attachView(view: self)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    navigationController?.setNavigationBarHidden(false, animated: false)
    navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationController?.navigationBar.shadowImage = UIImage()
    navigationController?.navigationBar.isTranslucent = true
    let backButton = UIBarButtonItem(image: UIImage(named: "backIcon"), style: .plain, target: self, action: #selector(self.backAction))
    self.navigationItem.leftBarButtonItem = backButton
    self.navigationController?.navigationBar.tintColor = .white
    self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    navigationController?.setNavigationBarHidden(true, animated: false)
    navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
    navigationController?.navigationBar.shadowImage = nil
    navigationItem.leftBarButtonItem?.tintColor = .newBlack
    self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
  }
  
  @objc func backAction() {
    self.navigationController?.popViewController(animated: true)
  }
  
  func setupUI() {
    setupConstraints()
    emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 0.70)])
    emailTextField.backgroundColor = UIColor.emailPasswordTextFieldGrey
    emailTextField.textColor = .white
    emailTextField.font = NewFonts.SFProDisplayRegular16
    if let myImage = UIImage(named: "Clear Icon"){
      emailTextField.withImage(direction: .Right, image: myImage, colorSeparator: UIColor.orange, colorBorder: UIColor.clear)
    }
    let emailClearTap = UITapGestureRecognizer(target: self, action: #selector(self.emailClearAction(_:)))
    emailTextField.rightView!.addGestureRecognizer(emailClearTap)
    emailTextField.rightView!.isUserInteractionEnabled = true
    emailTextField.rightViewMode = .whileEditing
    emailTextField.delegate = self
    emailTextField.cornerRadius = screenSize.height * (16/iPhoneXHeight)
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.emailTextField.frame.height))
    emailTextField.leftView = paddingView
    emailTextField.leftViewMode = .always
    
    passwordTextField.attributedPlaceholder = NSAttributedString(string: "Пароль", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 0.70)])
    passwordTextField.backgroundColor = UIColor.emailPasswordTextFieldGrey
    passwordTextField.textColor = .white
    passwordTextField.font = NewFonts.SFProDisplayRegular16
    if let myImage = UIImage(named: "eye"){
      passwordTextField.withImage(direction: .Right, image: myImage, colorSeparator: UIColor.orange, colorBorder: UIColor.clear)
    }
    let showHidePasswordTap = UITapGestureRecognizer(target: self, action: #selector(self.showHidePasswordAction(_:)))
    passwordTextField.rightView!.addGestureRecognizer(showHidePasswordTap)
    passwordTextField.rightView!.isUserInteractionEnabled = true
    passwordTextField.rightViewMode = .whileEditing
    passwordTextField.delegate = self
    passwordTextField.cornerRadius = screenSize.height * (16/iPhoneXHeight)
    let paddingView2 = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.passwordTextField.frame.height))
    passwordTextField.leftView = paddingView2
    passwordTextField.leftViewMode = .always
    
    passwordConfirmTextField.attributedPlaceholder = NSAttributedString(string: "Пароль повторно", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 0.70)])
    passwordConfirmTextField.backgroundColor = UIColor.emailPasswordTextFieldGrey
    passwordConfirmTextField.textColor = .white
    passwordConfirmTextField.cornerRadius = screenSize.height * (16/iPhoneXHeight)
    passwordConfirmTextField.font = NewFonts.SFProDisplayRegular16
    passwordConfirmTextField.delegate = self
    let paddingView3 = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.passwordConfirmTextField.frame.height))
         passwordConfirmTextField.leftView = paddingView3
         passwordConfirmTextField.leftViewMode = .always
    
    signUpButton.setTitle("Создать аккаунт", for: .normal)
    signUpButton.titleLabel?.font = NewFonts.SFProDisplayBold16
    signUpButton.setTitleColor(.white, for: .normal)
    signUpButton.setBackgroundColor(color: UIColor.newBlue, forState: .normal)
    signUpButton.setImage(nil, for: .normal)
    signUpButton.layer.cornerRadius = screenSize.height * (16/iPhoneXHeight)
    signUpButton.maskToBounds = true
    signUpButton.addTarget(self, action: #selector(confirm(_:)), for: .touchUpInside)
    
    privacyLabel.font = UIFont.systemFont(ofSize: 13)
    privacyLabel.textColor = UIColor.textGrey
    privacyLabel.text = "Продолжая, вы соглашаетесь с Политикой конфедициальности и Условиями пользования."
  }
  
  func setupConstraints() {
    logoImageView.snp.makeConstraints { (make) in
      make.top.equalTo(screenSize.height * (140/iPhoneXHeight))
      make.right.equalTo(screenSize.height * (-86/iPhoneXHeight))
      make.left.equalTo(screenSize.height * (86/iPhoneXHeight))
    }
    
    emailTextField.snp.makeConstraints { (make) in
      make.top.equalTo(logoImageView.snp.bottom).offset(screenSize.height * (48/iPhoneXHeight))
      make.right.equalTo(screenSize.height * (-16/iPhoneXHeight))
      make.left.equalTo(screenSize.height * (16/iPhoneXHeight))
      make.height.equalTo(screenSize.height * (58/iPhoneXHeight))
    }
    passwordTextField.snp.makeConstraints { (make) in
      make.top.equalTo(emailTextField.snp.bottom).offset(screenSize.height * (12/iPhoneXHeight))
      make.right.equalTo(screenSize.height * (-16/iPhoneXHeight))
      make.left.equalTo(screenSize.height * (16/iPhoneXHeight))
      make.height.equalTo(screenSize.height * (58/iPhoneXHeight))
    }
    passwordConfirmTextField.snp.makeConstraints { (make) in
      make.top.equalTo(passwordTextField.snp.bottom).offset(screenSize.height * (12/iPhoneXHeight))
      make.right.equalTo(screenSize.height * (-16/iPhoneXHeight))
      make.left.equalTo(screenSize.height * (16/iPhoneXHeight))
      make.height.equalTo(screenSize.height * (58/iPhoneXHeight))
    }
    
    signUpButton.snp.makeConstraints { (make) in
      make.top.equalTo(passwordConfirmTextField.snp.bottom).offset(screenSize.height * (62/iPhoneXHeight))
      make.right.equalTo(screenSize.height * (-20/iPhoneXHeight))
      make.left.equalTo(screenSize.height * (20/iPhoneXHeight))
      make.height.equalTo(screenSize.height * (48/iPhoneXHeight))
    }
    
    privacyLabel.snp.makeConstraints { (make) in
      make.bottom.equalTo(self.view.snp.bottom).offset(screenSize.height * (-40/iPhoneXHeight))
      make.right.equalTo(self.view.snp.right).offset(screenSize.height * (-20/iPhoneXHeight))
      make.left.equalTo(self.view.snp.left).offset(screenSize.height * (20/iPhoneXHeight))
    }
    
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
      
      SVProgressHUD.show()
      presenter.isAnyUserWith(userEmail: email) { (success, error) in
        if success {
          self.presenter.setEmailAndPass(email: email, pass: pass, name: self.viewModel?.userName ?? "", lastName: self.viewModel?.userLastName ?? "", city: self.viewModel?.userCity ??  "", userType: self.viewModel?.userType ?? "")
          
          self.signInpresenter.registerUser(email: email, password: AuthModule.pass, success: {
            SVProgressHUD.dismiss()
            let nextViewController = profileStoryboard.instantiateViewController(withIdentifier: "tabBarVC") as! UITabBarController
            self.navigationController?.pushViewController(nextViewController, animated: true)
          }) { (error) in
            SVProgressHUD.dismiss()
            AlertDialog.showAlert("Ошибка", message: error, viewController: self)
          }
        } else {
          SVProgressHUD.dismiss()
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

