//
//  MailLoginViewController.swift
//  MSA
//
//  Created by Nik on 06.08.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit
import SVProgressHUD

class MailLoginViewController: UIViewController {
  
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var mailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var privacyLabel: UILabel!
  @IBOutlet weak var logoImageView: UIImageView!
  @IBOutlet weak var mainBackgroundImageView: UIImageView!

  var viewModel: SignInViewModel?
  var presenter = SignUpPresenter(signUp: UserDataManager())
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    navigationController?.setNavigationBarHidden(false, animated: false)
    navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationController?.navigationBar.shadowImage = UIImage()
    navigationController?.navigationBar.isTranslucent = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    navigationController?.setNavigationBarHidden(true, animated: false)
    navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
    navigationController?.navigationBar.shadowImage = nil
    navigationItem.leftBarButtonItem?.tintColor = .white
  }

  func setupUI() {
    setupConstraints()
    let backButton = UIBarButtonItem(image: UIImage(named: "backIcon"), style: .plain, target: self, action: #selector(self.backAction))
    self.navigationItem.leftBarButtonItem = backButton
    self.navigationController?.navigationBar.tintColor = .white

    nextButton.titleLabel?.font = NewFonts.SFProDisplayBold16
    nextButton.setTitleColor(UIColor.white, for: .normal)
    nextButton.setTitle("Войти", for: .normal)
    nextButton.setBackgroundColor(color: UIColor.newBlue, forState: .normal)
    nextButton.layer.cornerRadius = screenSize.height * (16/iPhoneXHeight)
    nextButton.layer.masksToBounds = true
    nextButton.addTarget(self, action: #selector(signInButtonAction), for: .touchUpInside)
    
    privacyLabel.font = NewFonts.SFProDisplayRegular14
    privacyLabel.textColor = UIColor(red: 0.59, green: 0.59, blue: 0.59, alpha: 1.00)
    privacyLabel.text = "Продолжая, вы соглашаетесь с Политикой конфедициальности и Условиями пользования."
    
    mailTextField.placeholder = "Почта"
    mailTextField.cornerRadius = screenSize.height * (16/iPhoneXHeight)
    mailTextField.font = NewFonts.SFProDisplayRegular16
    mailTextField.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.99, alpha: 0.45)
    mailTextField.textColor = .white
    let color = UIColor.white
    let placeholder = mailTextField.placeholder ?? ""
    mailTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : color])
    mailTextField.delegate = self
    let paddingView2 = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.mailTextField.frame.height))
     mailTextField.leftView = paddingView2
     mailTextField.leftViewMode = .always
    
    passwordTextField.placeholder = "Пароль"
    passwordTextField.cornerRadius = screenSize.height * (16/iPhoneXHeight)
    passwordTextField.font = NewFonts.SFProDisplayRegular16
    passwordTextField.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.99, alpha: 0.45)
    passwordTextField.textColor = .white
    let placeholderPassword = passwordTextField.placeholder ?? ""
    passwordTextField.attributedPlaceholder = NSAttributedString(string: placeholderPassword, attributes: [NSAttributedString.Key.foregroundColor : color])
    passwordTextField.delegate = self
    let paddingView3 = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.passwordTextField.frame.height))
        passwordTextField.leftView = paddingView3
        passwordTextField.leftViewMode = .always
  }
  
  @objc func backAction() {
    self.navigationController?.popViewController(animated: true)
  }
  
  func setupConstraints() {
    mainBackgroundImageView.snp.makeConstraints { (make) in
       make.top.equalTo(self.view.snp.top)
       make.bottom.equalTo(self.view.snp.bottom)
       make.right.equalTo(self.view.snp.right)
       make.left.equalTo(self.view.snp.left)
     }
    
    logoImageView.snp.makeConstraints { (make) in
       make.top.equalTo(screenSize.height * (140/iPhoneXHeight))
       make.right.equalTo(screenSize.height * (-86/iPhoneXHeight))
       make.left.equalTo(screenSize.height * (86/iPhoneXHeight))
     }
    
  mailTextField.snp.makeConstraints { (make) in
      make.top.equalTo(logoImageView.snp.bottom).offset(screenSize.height * (106/iPhoneXHeight))
      make.right.equalTo(screenSize.height * (-16/iPhoneXHeight))
      make.left.equalTo(screenSize.height * (16/iPhoneXHeight))
      make.height.equalTo(screenSize.height * (58/iPhoneXHeight))
    }
    
    passwordTextField.snp.makeConstraints { (make) in
         make.top.equalTo(mailTextField.snp.bottom).offset(screenSize.height * (12/iPhoneXHeight))
         make.right.equalTo(screenSize.height * (-16/iPhoneXHeight))
         make.left.equalTo(screenSize.height * (16/iPhoneXHeight))
         make.height.equalTo(screenSize.height * (58/iPhoneXHeight))
       }
    
    nextButton.snp.makeConstraints { (make) in
      make.top.equalTo(passwordTextField.snp.bottom).offset(screenSize.height * (74/iPhoneXHeight))
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
  
  @objc func signInButtonAction(_ sender: UIButton) {
    SVProgressHUD.show()
    self.viewModel!.loginUserWithEmail(success: {
      SVProgressHUD.dismiss()
      let nextViewController = profileStoryboard.instantiateViewController(withIdentifier: "tabBarVC") as! UITabBarController
      self.navigationController?.pushViewController(nextViewController, animated: true)
    }) { (errorString) in
      SVProgressHUD.dismiss()
      self.showAlert(text: errorString)
    }
  }
  
  
  func showAlert(text: String) {
    if text == "" {
        AlertDialog.showAlert("Нет подключения к интернету.", message: "Проверьте соединение и повторите попытку позже.", viewController: self)
    } else {
        if text != "FBCancel" {
            AlertDialog.showAlert("Ошибка авторизации", message: text, viewController: self)
        }
    }
  }
}

extension MailLoginViewController: UITextFieldDelegate {
  func textFieldDidChangeSelection(_ textField: UITextField) {
    if textField == mailTextField {
      viewModel!.updateMail(value: textField.text ?? "")
    } else {
      viewModel!.updatePassword(value: textField.text ?? "")
    }
  }
}


