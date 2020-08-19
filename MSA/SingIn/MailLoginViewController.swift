//
//  MailLoginViewController.swift
//  MSA
//
//  Created by Nik on 06.08.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit

class MailLoginViewController: UIViewController {
  
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var mailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var privacyLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
  }
  
  func setupUI() {
    
    nextButton.titleLabel?.font = UIFont(name: Fonts.SFProDisplayBold, size: 16)
    nextButton.setTitleColor(UIColor.white, for: .normal)
    nextButton.setTitle("Войти", for: .normal)
    nextButton.setBackgroundColor(color: UIColor.newBlue, forState: .normal)
    nextButton.roundCorners(.allCorners, radius: 12)
    nextButton.addTarget(self, action: #selector(signInButtonAction), for: .touchUpInside)
    
    privacyLabel.font = UIFont(name: Fonts.SFProDisplayRegular, size: 24)
    privacyLabel.textColor = UIColor(red: 0.59, green: 0.59, blue: 0.59, alpha: 1.00)
    privacyLabel.text = "Продолжая, вы соглашаетесь с Политикой конфедициальности и Условиями пользования."
    
    mailTextField.placeholder = "Почта"
    mailTextField.roundCorners(.allCorners, radius: 16)
    mailTextField.font = UIFont(name: Fonts.SFProDisplayRegular, size: 16)
    mailTextField.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.99, alpha: 0.45)
    mailTextField.textColor = .white
    let color = UIColor.white
    let placeholder = mailTextField.placeholder ?? ""
    mailTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : color])

    //mailTextField.delegate = self
    
    passwordTextField.placeholder = "Пароль"
    passwordTextField.roundCorners(.allCorners, radius: 16)
    passwordTextField.font = UIFont(name: Fonts.SFProDisplayRegular, size: 16)
    passwordTextField.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.99, alpha: 0.45)
    passwordTextField.textColor = .white
    let placeholderPassword = passwordTextField.placeholder ?? ""
    passwordTextField.attributedPlaceholder = NSAttributedString(string: placeholderPassword, attributes: [NSAttributedString.Key.foregroundColor : color])
    //passwordTextField.delegate = self
  }
  
  @objc func signInButtonAction(_ sender: UIButton) {
    let nextViewController = signInStoryboard.instantiateViewController(withIdentifier: "HowToTrainigViewController") as! HowToTrainigViewController
    self.navigationController?.pushViewController(nextViewController, animated: true)
  }
  
}
