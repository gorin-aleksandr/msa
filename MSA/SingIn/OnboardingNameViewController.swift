//
//  OnboardingNameViewController.swift
//  MSA
//
//  Created by Nik on 06.08.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit
import SearchTextField
import SVProgressHUD

class OnboardingNameViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var nameTextField: SearchTextField!
  @IBOutlet weak var lastNameTextField: UITextField!
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var logoImageView: UIImageView!

  var viewModel: SignInViewModel?
  let presenter = SignUpPresenter(signUp: UserDataManager())

  override func viewDidLoad() {
    super.viewDidLoad()
    presenter.attachView(view: self)
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
    navigationItem.leftBarButtonItem?.tintColor = .newBlack
  }
  
  func setupUI() {
    setupConstraints()
    let backButton = UIBarButtonItem(image: UIImage(named: "backIcon"), style: .plain, target: self, action: #selector(self.backAction))
    self.navigationItem.leftBarButtonItem = backButton
    self.navigationController?.navigationBar.tintColor = .newBlack

    titleLabel.font = NewFonts.SFProDisplayBold24
    titleLabel.textColor = UIColor.newBlack
    titleLabel.text = viewModel!.signInDataControllerType == .name ?  "Давайте познакомимся" : "Откуда вы ?"
    
    descriptionLabel.font = NewFonts.SFProDisplayRegular16
    descriptionLabel.textColor = UIColor.newBlack
    descriptionLabel.text = viewModel!.signInDataControllerType == .name ? "Введите ваше имя" : "Укажите ваш город"
    
    nameTextField.placeholder = viewModel!.signInDataControllerType == .name ? "Имя" : "Город"
    nameTextField.backgroundColor = UIColor.textFieldBackgroundGrey
    nameTextField.layer.cornerRadius = screenSize.height * (16/iPhoneXHeight)
    nameTextField.font = NewFonts.SFProDisplayRegular16
    nameTextField.delegate = self
    nameTextField.lineColor = .clear

    if viewModel!.signInDataControllerType == .city {
      setupCitiesTextField()
    }
    
    lastNameTextField.placeholder = "Фамилия"
    lastNameTextField.backgroundColor = UIColor.textFieldBackgroundGrey
    lastNameTextField.layer.cornerRadius = screenSize.height * (16/iPhoneXHeight)
    lastNameTextField.font = NewFonts.SFProDisplayRegular16
    lastNameTextField.delegate = self
    lastNameTextField.isHidden = viewModel!.signInDataControllerType == .name ? false : true
    
    startButton.titleLabel?.font = NewFonts.SFProDisplayRegular14
    startButton.setTitleColor(UIColor.diasbledGrey, for: .normal)
    startButton.setTitleColor(.white, for: .selected)
    startButton.setBackgroundColor(color: UIColor.backgroundLightGrey, forState: .normal)
    startButton.setBackgroundColor(color: UIColor.newBlue, forState: .selected)
    startButton.setImage(nil, for: .normal)
    startButton.setImage(UIImage(named: "doubleChevron"), for: .selected)
    startButton.layer.cornerRadius = screenSize.height * (16/iPhoneXHeight)
    startButton.layer.masksToBounds = true
    startButton.addTarget(self, action: #selector(startButtonAction(_:)), for: .touchUpInside)
  }
  
  @objc func backAction() {
    self.navigationController?.popViewController(animated: true)
  }
  
  func setupConstraints() {
    logoImageView.snp.makeConstraints { (make) in
      make.top.equalTo(screenSize.height * (176/iPhoneXHeight))
      make.right.equalTo(screenSize.height * (-141/iPhoneXHeight))
      make.left.equalTo(screenSize.height * (141/iPhoneXHeight))
    }
    
    titleLabel.textAlignment = .center
    titleLabel.snp.makeConstraints { (make) in
      make.top.equalTo(logoImageView.snp.bottom).offset(screenSize.height * (48/iPhoneXHeight))
      make.right.equalTo(self.view.snp.right).offset(screenSize.height * (-20/iPhoneXHeight))
      make.left.equalTo(self.view.snp.left).offset(screenSize.height * (20/iPhoneXHeight))
    }
    
    descriptionLabel.textAlignment = .center
    descriptionLabel.snp.makeConstraints { (make) in
      make.top.equalTo(titleLabel.snp.bottom).offset(screenSize.height * (11/iPhoneXHeight))
      make.right.equalTo(titleLabel.snp.right)
      make.left.equalTo(titleLabel.snp.left)
    }
    
    nameTextField.snp.makeConstraints { (make) in
      make.top.equalTo(descriptionLabel.snp.bottom).offset(screenSize.height * (76/iPhoneXHeight))
      make.right.equalTo(self.view.snp.right).offset(screenSize.height * (-20/iPhoneXHeight))
      make.left.equalTo(self.view.snp.left).offset(screenSize.height * (20/iPhoneXHeight))
      make.height.equalTo(screenSize.height * (56/iPhoneXHeight))
    }
    
    lastNameTextField.snp.makeConstraints { (make) in
      make.top.equalTo(nameTextField.snp.bottom).offset(screenSize.height * (8/iPhoneXHeight))
      make.right.equalTo(self.view.snp.right).offset(screenSize.height * (-20/iPhoneXHeight))
      make.left.equalTo(self.view.snp.left).offset(screenSize.height * (20/iPhoneXHeight))
      make.height.equalTo(screenSize.height * (56/iPhoneXHeight))
    }
    
    startButton.snp.makeConstraints { (make) in
      make.bottom.equalTo(self.view.snp.bottom).offset(screenSize.height * (-50/iPhoneXHeight))
      make.right.equalTo(self.view.snp.right).offset(screenSize.height * (-20/iPhoneXHeight))
      make.left.equalTo(self.view.snp.left).offset(screenSize.height * (20/iPhoneXHeight))
      make.height.equalTo(screenSize.height * (66/iPhoneXHeight))
    }
    
  }
    
  @objc func startButtonAction(_ sender: UIButton) {
    if sender.isSelected {
      if viewModel!.signInDataControllerType == .name {
        let nextViewController = signInStoryboard.instantiateViewController(withIdentifier: "OnboardingNameViewController") as! OnboardingNameViewController
        nextViewController.viewModel = viewModel
        nextViewController.viewModel!.signInDataControllerType = .city
        self.navigationController?.pushViewController(nextViewController, animated: true)
      } else {
        if viewModel!.flowType == .new {
          let nextViewController = signInStoryboard.instantiateViewController(withIdentifier: "MainSignInViewController") as! MainSignInViewController
          nextViewController.viewModel = viewModel
          self.navigationController?.pushViewController(nextViewController, animated: true)
        } else if viewModel!.flowType == .update {
          AuthModule.currUser.firstName = viewModel!.userName
          AuthModule.currUser.lastName = viewModel!.userLastName
          AuthModule.currUser.type = viewModel!.userType
          AuthModule.currUser.city = viewModel!.userCity
          
          SVProgressHUD.show()
          presenter.createNewUser(newUser: AuthModule.currUser, success: {
            SVProgressHUD.dismiss()
            let nextViewController = profileStoryboard.instantiateViewController(withIdentifier: "tabBarVC") as! UITabBarController
            self.navigationController?.pushViewController(nextViewController, animated: true)
          }) { (value) in
            AlertDialog.showAlert("Ошибка", message: value, viewController: self)
          }
        }
      }
    }
  }
  
  func setupCitiesTextField() {
    nameTextField.filterStrings(viewModel!.cities)
    nameTextField.comparisonOptions = [.caseInsensitive]
    nameTextField.maxNumberOfResults = 5
    nameTextField.direction = .up
    nameTextField.maxResultsListHeight = 150
    nameTextField.theme.font = NewFonts.SFProDisplayBold14
    nameTextField.theme.fontColor = .newBlack
    nameTextField.theme.bgColor = .white
    nameTextField.theme.separatorColor = .newBlack
    nameTextField.theme.placeholderColor = .diasbledGrey
    nameTextField.theme.cellHeight = 35
    nameTextField.lineColor = .white
    nameTextField.itemSelectionHandler = { filteredResults, itemPosition in
      let item = filteredResults[itemPosition]
      print("Item at position \(itemPosition): \(item.title)")
      self.nameTextField.text = item.title
      self.startButton.isSelected = true
    }
  }
  
}

extension OnboardingNameViewController: UITextFieldDelegate {
  func textFieldDidChangeSelection(_ textField: UITextField) {
    if textField == nameTextField {
      if viewModel!.signInDataControllerType == .name {
        viewModel!.updateName(value: textField.text ?? "")
      } else {
        viewModel!.updateCity(value: textField.text ?? "")
      }
    } else if textField == lastNameTextField {
      viewModel!.updateLastName(value: textField.text ?? "")
    }
    
    if !nameTextField.text!.isEmpty && !lastNameTextField.text!.isEmpty {
      startButton.isSelected = true
    } else {
      startButton.isSelected = false
      
    }
  }
}

extension OnboardingNameViewController: SignUpViewProtocol {
  func startLoading() {
    
  }
  
  func finishLoading() {
    
  }
  
  func next() {
    
  }
  
  func notUpdated() {
    
  }
  
  func setUser(user: UserVO) {
    
  }
  
  func userCreated() {
    
  }
  
  func userNotCreated() {
    
  }
  
  
}
