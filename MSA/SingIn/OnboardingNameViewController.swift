//
//  OnboardingNameViewController.swift
//  MSA
//
//  Created by Nik on 06.08.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit

class OnboardingNameViewController: UIViewController {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var lastNameTextField: UITextField!
  @IBOutlet weak var startButton: UIButton!

  override func viewDidLoad() {
      super.viewDidLoad()
    setupUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    navigationController?.setNavigationBarHidden(false, animated: false)
  }
  
  func setupUI() {
    titleLabel.font = UIFont(name: Fonts.SFProDisplayBold, size: 24)
    titleLabel.textColor = UIColor.newBlack
    titleLabel.text = "Давайте познакомимся"

    descriptionLabel.font = UIFont(name: Fonts.SFProDisplayRegular, size: 16)
    descriptionLabel.textColor = UIColor.newBlack
    descriptionLabel.text = "Введите ваше имя"
    
    nameTextField.placeholder = "Имя"
    nameTextField.backgroundColor = UIColor.textFieldBackgroundGrey
    nameTextField.roundCorners(.allCorners, radius: 16)
    nameTextField.font = UIFont(name: Fonts.SFProDisplayRegular, size: 16)
    nameTextField.delegate = self

    lastNameTextField.placeholder = "Фамилия"
    lastNameTextField.backgroundColor = UIColor.textFieldBackgroundGrey
    lastNameTextField.roundCorners(.allCorners, radius: 16)
    lastNameTextField.font = UIFont(name: Fonts.SFProDisplayRegular, size: 16)
    lastNameTextField.delegate = self

    startButton.titleLabel?.font = UIFont(name: Fonts.SFProDisplayRegular, size: 14)
    startButton.setTitleColor(UIColor.diasbledGrey, for: .normal)
    startButton.setTitleColor(.white, for: .selected)
    startButton.setBackgroundColor(color: UIColor.backgroundLightGrey, forState: .normal)
    startButton.setBackgroundColor(color: UIColor.newBlue, forState: .selected)
    startButton.setImage(nil, for: .normal)
    startButton.setImage(UIImage(named: "doubleChevron"), for: .selected)
    startButton.roundCorners(.allCorners, radius: 12)
    startButton.addTarget(self, action: #selector(startButtonAction(_:)), for: .touchUpInside)

  }
  
  @objc func startButtonAction(_ sender: UIButton) {
    if sender.isSelected {
      let nextViewController = signInStoryboard.instantiateViewController(withIdentifier: "MainSignInViewController") as! MainSignInViewController
      self.navigationController?.pushViewController(nextViewController, animated: true)
    }
  }
    
}

extension OnboardingNameViewController: UITextFieldDelegate {
  func textFieldDidChangeSelection(_ textField: UITextField) {
    if !nameTextField.text!.isEmpty && !lastNameTextField.text!.isEmpty {
      startButton.isSelected = true
    } else {
      startButton.isSelected = false

    }
  }
}
