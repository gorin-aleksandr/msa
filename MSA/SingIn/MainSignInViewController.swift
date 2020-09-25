//
//  MainSignInViewController.swift
//  MSA
//
//  Created by Nik on 06.08.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit
import AuthenticationServices
import CryptoKit
import Firebase

class MainSignInViewController: UIViewController {
  
  @IBOutlet weak var mailButton: UIButton!
  @IBOutlet weak var facebookButton: UIButton!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var privacyLabel: UILabel!
  @IBOutlet weak var haveAccountLabel: UILabel!
  @IBOutlet weak var mailLabel: UILabel!
  @IBOutlet weak var logoImageView: UIImageView!
  @IBOutlet weak var facebookImageView: UIImageView!
  @IBOutlet weak var mainBackgroundImageView: UIImageView!
  @available(iOS 13.0, *)
  @IBOutlet lazy var appleButton: MyAuthorizationAppleIdButton? = { return nil }()

  
  fileprivate var currentNonce: String?
  
  var viewModel: SignInViewModel?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
     navigationController?.setNavigationBarHidden(true, animated: false)
     navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
     navigationController?.navigationBar.shadowImage = nil
     navigationItem.leftBarButtonItem?.tintColor = .newBlack
  }
  func setupUI() {
    setupConstraints()
    
    mailButton.isHidden = viewModel?.userLastName == "" ? true : false
    mailLabel.isHidden = viewModel?.userLastName == "" ? true : false
    mailButton.titleLabel?.font = NewFonts.SFProDisplayRegular16
    mailButton.setTitleColor(UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00), for: .normal)
    // mailButton.setBackgroundColor(color: UIColor(red: 0.96, green: 0.96, blue: 0.99, alpha: 0.1), forState: .normal)
    mailButton.layer.cornerRadius = screenSize.height * (12/iPhoneXHeight)
    mailButton.maskToBounds = true
    mailButton.addTarget(self, action: #selector(mailButtonAction(_:)), for: .touchUpInside)
    
    facebookButton.titleLabel?.font = NewFonts.SFProDisplayRegular16
    facebookButton.setTitleColor(UIColor.white, for: .normal)
    facebookButton.setTitle("Войти с помощью Facebook", for: .normal)
    facebookButton.setBackgroundColor(color: UIColor(red: 0.27, green: 0.40, blue: 0.84, alpha: 1.00), forState: .normal)
    facebookButton.layer.cornerRadius = screenSize.height * (12/iPhoneXHeight)
    facebookButton.maskToBounds = true
    facebookButton.addTarget(self, action: #selector(facebookButtonAction), for: .touchUpInside)
    
    nextButton.titleLabel?.font = NewFonts.SFProDisplayRegular16
    nextButton.setTitleColor(UIColor.white, for: .normal)
    nextButton.setTitle("Войти", for: .normal)
    nextButton.setBackgroundColor(color: UIColor.newBlue, forState: .normal)
    nextButton.layer.cornerRadius = screenSize.height * (12/iPhoneXHeight)
    nextButton.maskToBounds = true
    nextButton.titleLabel?.textAlignment = .center
    nextButton.addTarget(self, action: #selector(signButtonAction), for: .touchUpInside)
    
    
    if #available(iOS 13.0, *) {
      appleButton!.layer.cornerRadius = screenSize.height * (16/iPhoneXHeight)
      appleButton!.maskToBounds = true
      appleButton!.authorizationButton.addTarget(self, action: #selector(appleButtonAction), for: .touchDown)
    }

    
    haveAccountLabel.font = NewFonts.SFProDisplayRegular16
    haveAccountLabel.textColor = .white
    haveAccountLabel.text = "Уже есть аккаунт?"
    
    mailLabel.font = NewFonts.SFProDisplayRegular16
    mailLabel.textColor = .white
    mailLabel.text = "Регистрация с помощью Email"
    
    privacyLabel.font = NewFonts.SFProDisplayRegular12
    privacyLabel.textColor = .textGrey
    privacyLabel.text = "Продолжая, вы соглашаетесь с Политикой конфедициальности и Условиями пользования."
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
    
    mailButton.snp.makeConstraints { (make) in
      make.top.equalTo(logoImageView.snp.bottom).offset(screenSize.height * (65/iPhoneXHeight))
      make.centerX.equalTo(self.view.snp.centerX)
      make.height.equalTo(screenSize.height * (48/iPhoneXHeight))
      make.width.equalTo(screenSize.width * (335/iPhoneXWidth))
    }
    
    facebookButton.snp.makeConstraints { (make) in
      make.top.equalTo(mailButton.snp.bottom).offset(screenSize.height * (8/iPhoneXHeight))
      make.centerX.equalTo(self.view.snp.centerX)
      make.height.equalTo(screenSize.height * (48/iPhoneXHeight))
      make.width.equalTo(screenSize.width * (335/iPhoneXWidth))
    }
    
    if #available(iOS 13.0, *) {
      appleButton?.snp.makeConstraints { (make) in
        make.top.equalTo(facebookButton.snp.bottom).offset(screenSize.height * (8/iPhoneXHeight))
        make.centerX.equalTo(self.view.snp.centerX)
        make.height.equalTo(screenSize.height * (48/iPhoneXHeight))
        make.width.equalTo(screenSize.width * (335/iPhoneXWidth))
      }
      
//      let imgView = UIImageView(image: UIImage(named: "AppleBlack"))
//      let tap = UITapGestureRecognizer(target: self, action:  #selector(handleAppleSignInSelector))
//      imgView.addGestureRecognizer(tap)
//      imgView.isUserInteractionEnabled = true
//      self.view.addSubview(imgView)
//
//      imgView.snp.makeConstraints { (make) in
//        make.top.equalTo(self.appleButton!.snp.top)
//        make.right.equalTo(self.appleButton!.snp.right)
//        make.left.equalTo(self.appleButton!.snp.left)
//        make.bottom.equalTo(self.appleButton!.snp.bottom)
//      }
    } else {
      // Fallback on earlier versions
    }
    
    haveAccountLabel.snp.makeConstraints { (make) in
      make.top.equalTo(facebookButton.snp.bottom).offset(screenSize.height * (100/iPhoneXHeight))
      make.centerX.equalTo(self.view.snp.centerX)
    }
    
    nextButton.snp.makeConstraints { (make) in
      make.top.equalTo(haveAccountLabel.snp.bottom).offset(screenSize.height * (16/iPhoneXHeight))
      make.right.equalTo(self.view.snp.right).offset(screenSize.height * (-20/iPhoneXHeight))
      make.left.equalTo(self.view.snp.left).offset(screenSize.height * (20/iPhoneXHeight))
      make.height.equalTo(screenSize.height * (48/iPhoneXHeight))
    }
    
    privacyLabel.snp.makeConstraints { (make) in
      make.bottom.equalTo(self.view.snp.bottom).offset(screenSize.height * (-40/iPhoneXHeight))
      make.right.equalTo(self.view.snp.right).offset(screenSize.height * (-20/iPhoneXHeight))
      make.left.equalTo(self.view.snp.left).offset(screenSize.height * (20/iPhoneXHeight))
    }
    mailLabel.snp.makeConstraints { (make) in
      make.centerX.equalTo(self.mailButton.snp.centerX)
      make.centerY.equalTo(self.mailButton.snp.centerY)
    }
    
    facebookImageView.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.facebookButton.snp.centerY)
      make.left.equalTo(self.facebookButton.snp.left).offset(screenSize.height * (40/iPhoneXHeight))
      make.height.width.equalTo(screenSize.height * (19/iPhoneXHeight))
    }
    
  }
  
  @objc private func handleAppleSignInSelector() {
    print("Pressed image selector")
    if #available(iOS 13, *) {
      startSignInWithAppleFlow()
    } else {
      // Fallback on earlier versions
    }
  }
  
  
  @objc func mailButtonAction(_ sender: UIButton) {
    let nextViewController = signInStoryboard.instantiateViewController(withIdentifier: "EmailPasswordViewController") as! EmailPasswordViewController
    nextViewController.viewModel = viewModel
    self.navigationController?.pushViewController(nextViewController, animated: true)
  }
  
  @objc func facebookButtonAction(_ sender: UIButton) {
    viewModel?.loginWithFacebook(success: {
      if AuthModule.currUser.type == nil {
        let nextViewController = signInStoryboard.instantiateViewController(withIdentifier: "StartOnboardingViewController") as! StartOnboardingViewController
        nextViewController.viewModel = SignInViewModel()
        nextViewController.viewModel?.flowType = .update
        self.navigationController?.pushViewController(nextViewController, animated: true)
      } else {
        let nextViewController = profileStoryboard.instantiateViewController(withIdentifier: "tabBarVC") as! UITabBarController
        self.navigationController?.pushViewController(nextViewController, animated: true)
      }
    }, failure: { (error) in
      AlertDialog.showAlert("Ошибка", message: error, viewController: self)
    })
  }
  
  @objc func signButtonAction(_ sender: UIButton) {
    let nextViewController = signInStoryboard.instantiateViewController(withIdentifier: "MailLoginViewController") as! MailLoginViewController
    nextViewController.viewModel = self.viewModel
    self.navigationController?.pushViewController(nextViewController, animated: true)
  }
  
  @objc func appleButtonAction(_ sender: UIButton) {
    if #available(iOS 13, *) {
      startSignInWithAppleFlow()
    } else {
      // Fallback on earlier versions
    }
  }
  
  @objc @available(iOS 13, *)
  func startSignInWithAppleFlow() {
    let nonce = randomNonceString()
    currentNonce = nonce
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    let request = appleIDProvider.createRequest()
    request.requestedScopes = [.fullName, .email]
    request.nonce = nonce.sha256()
    
    let authorizationController = ASAuthorizationController(authorizationRequests: [request])
    authorizationController.delegate = self
    authorizationController.presentationContextProvider = self
    authorizationController.performRequests()
  }
}

@available(iOS 13.0, *)
extension MainSignInViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
  
  @available(iOS 13.0, *)
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return self.view.window!
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      guard let nonce = currentNonce else {
        fatalError("Invalid state: A login callback was received, but no login request was sent.")
      }
      guard let appleIDToken = appleIDCredential.identityToken else {
        print("Unable to fetch identity token")
        return
      }
      guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
        print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
        return
      }
      // Initialize a Firebase credential.      
      let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce, accessToken: nil)
      viewModel!.loginWithAppleId(credential: credential, success: {
        if AuthModule.currUser.type == nil {
          let nextViewController = signInStoryboard.instantiateViewController(withIdentifier: "StartOnboardingViewController") as! StartOnboardingViewController
          nextViewController.viewModel = SignInViewModel()
          nextViewController.viewModel?.flowType = .update
          self.navigationController?.pushViewController(nextViewController, animated: true)
        } else {
          let nextViewController = profileStoryboard.instantiateViewController(withIdentifier: "tabBarVC") as! UITabBarController
          self.navigationController?.pushViewController(nextViewController, animated: true)
        }
      }) { (error) in
        AlertDialog.showAlert("Ошибка", message: error, viewController: self)
      }
    }
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
    print("Sign in with Apple errored: \(error)")
    AlertDialog.showAlert("Ошибка", message: error.localizedDescription, viewController: self)
  }
  
}
