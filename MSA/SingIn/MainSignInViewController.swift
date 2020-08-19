//
//  MainSignInViewController.swift
//  MSA
//
//  Created by Nik on 06.08.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit

class MainSignInViewController: UIViewController {
  
  @IBOutlet weak var mailButton: UIButton!
  @IBOutlet weak var facebookButton: UIButton!
  @available(iOS 13.0, *)
  @IBOutlet lazy var appleButton: MyAuthorizationAppleIdButton? = { return nil }()
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var privacyLabel: UILabel!
  @IBOutlet weak var haveAccountLabel: UILabel!
  @IBOutlet weak var mailLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  func setupUI() {
    mailButton.titleLabel?.font = UIFont(name: Fonts.SFProDisplayRegular, size: 16)
    mailButton.setTitleColor(UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00), for: .normal)
   // mailButton.setBackgroundColor(color: UIColor(red: 0.96, green: 0.96, blue: 0.99, alpha: 0.1), forState: .normal)
    mailButton.roundCorners(.allCorners, radius: 12)
    mailButton.addTarget(self, action: #selector(mailButtonAction(_:)), for: .touchUpInside)
    
    facebookButton.titleLabel?.font = UIFont(name: Fonts.SFProDisplayRegular, size: 16)
    facebookButton.setTitleColor(UIColor.white, for: .normal)
    facebookButton.setTitle("Facebook", for: .normal)
    facebookButton.setBackgroundColor(color: UIColor(red: 0.27, green: 0.40, blue: 0.84, alpha: 1.00), forState: .normal)
    facebookButton.roundCorners(.allCorners, radius: 12)
    facebookButton.setImage(UIImage(named: "facebook-with-circle 1"), for: .normal)
    facebookButton.addTarget(self, action: #selector(facebookButtonAction), for: .touchUpInside)
    
    nextButton.titleLabel?.font = UIFont(name: Fonts.SFProDisplayBold, size: 16)
    nextButton.setTitleColor(UIColor.white, for: .normal)
    nextButton.setTitle("Войти", for: .normal)
    nextButton.setBackgroundColor(color: UIColor.newBlue, forState: .normal)
    nextButton.roundCorners(.allCorners, radius: 12)
    nextButton.addTarget(self, action: #selector(facebookButtonAction), for: .touchUpInside)
    
    if #available(iOS 13.0, *) {
      appleButton!.roundCorners(.allCorners, radius: 12)
    } else {
      // Fallback on earlier versions
    }
   
    haveAccountLabel.font = UIFont(name: Fonts.SFProDisplayRegular, size: 24)
    haveAccountLabel.textColor = .white
    haveAccountLabel.text = "Уже есть аккаунт?"
    
    mailLabel.font = UIFont(name: Fonts.SFProDisplayRegular, size: 16)
    mailLabel.textColor = .white
    mailLabel.text = "Регистрация с помощью Email"
    
    privacyLabel.font = UIFont(name: Fonts.SFProDisplayRegular, size: 24)
    privacyLabel.textColor = UIColor(red: 0.59, green: 0.59, blue: 0.59, alpha: 1.00)
    privacyLabel.text = "Продолжая, вы соглашаетесь с Политикой конфедициальности и Условиями пользования."
  
  }
  
  @objc func mailButtonAction(_ sender: UIButton) {
    let nextViewController = signInStoryboard.instantiateViewController(withIdentifier: "EmailPasswordViewController") as! EmailPasswordViewController
    self.navigationController?.pushViewController(nextViewController, animated: true)
  }
  
  @objc func facebookButtonAction(_ sender: UIButton) {
    
  }
  
  @objc func signButtonAction(_ sender: UIButton) {
     let nextViewController = signInStoryboard.instantiateViewController(withIdentifier: "MailLoginViewController") as! MailLoginViewController
     self.navigationController?.pushViewController(nextViewController, animated: true)
   }
  
}
