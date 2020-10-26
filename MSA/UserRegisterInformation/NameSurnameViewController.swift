//
//  RegSecondViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 2/22/18.
//  Copyright © 2018 easyapps.solutions. All rights reserved.
//

import UIKit
import Firebase
import SearchTextField

enum MSA_User_Type: String {
  case sport = "СПОРТСМЕН"
  case trainer = "ТРЕНЕР"
}

class NameSurnameViewController: BasicViewController {
  
  @IBOutlet weak var blurView: UIVisualEffectView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {didSet{activityIndicator.stopAnimating()}}
  @IBOutlet weak var nameTF: UITextField!
  @IBOutlet weak var surnameTF: UITextField!
  @IBOutlet weak var cityTF: SearchTextField!
  @IBOutlet weak var sportsmanImage: UIImageView!
  @IBOutlet weak var trainerImage: UIImageView!
  @IBOutlet weak var confirmButton: UIButton!

  var type = MSA_User_Type.sport
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  private let presenter = UserSignInPresenter(auth: AuthModule())
  private let anotherPresenter = SignUpPresenter(signUp: UserDataManager())
  var cities: [String] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    
    anotherPresenter.attachView(view: self)
    presenter.attachView(view: self)
    nameTF.delegate = self
    surnameTF.delegate = self
    cityTF.delegate = self
    cityTF.placeholder = "Город*"
    if let name = AuthModule.currUser.firstName {
      nameTF.text = name
    }
    if let surname = AuthModule.currUser.lastName {
      surnameTF.text = surname
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    setupCities()
  }
  
  func setupCities() -> Bool {
    guard let js = loadJson(filename: "cities") else {
      return false
    }
    cities = js.map { $0.name }
    cityTF.filterStrings(cities)
    cityTF.comparisonOptions = [.caseInsensitive]
    cityTF.maxNumberOfResults = 5
    cityTF.direction = .up
    cityTF.maxResultsListHeight = 150
    cityTF.theme.font = NewFonts.SFProDisplayRegular14
    cityTF.theme.fontColor = .darkCyanGreen
    cityTF.theme.bgColor = .white
    cityTF.theme.separatorColor = .darkCyanGreen45
    cityTF.theme.placeholderColor = .white
    cityTF.theme.separatorColor = .darkCyanGreen45
    cityTF.theme.cellHeight = 35
    cityTF.lineColor = .white
    return true
  }
  
  @IBAction func selectSportsman(_ sender: Any) {
    sportsmanImage.image = #imageLiteral(resourceName: "selected")
    trainerImage.image = #imageLiteral(resourceName: "notSelected")
    type = MSA_User_Type.sport
  }
  
  @IBAction func selectTrainer(_ sender: Any) {
    sportsmanImage.image = #imageLiteral(resourceName: "notSelected")
    trainerImage.image = #imageLiteral(resourceName: "selected")
    type = MSA_User_Type.trainer
  }
  @IBAction func back(_ sender: Any) {
    navigationController?.popViewController(animated: true)
  }
  @IBAction func confirm(_ sender: Any) {
    if let name = nameTF.text, let surname = surnameTF.text {
      anotherPresenter.setName(name: name)
      anotherPresenter.setSurname(surname: surname)
      if let city = cityTF.text {
        anotherPresenter.setCity(city: city)
        AnalyticsSender.shared.logEvent(eventName: "user_city_registration", params: ["city": city])
      }
      anotherPresenter.setType(type: type)
      AnalyticsSender.shared.logEvent(eventName: "sign_up")
      switch type {
        case .sport:
          AnalyticsSender.shared.logEvent(eventName: "sign_up_sportsman")
        case .trainer:
          AnalyticsSender.shared.logEvent(eventName: "sign_up_coach")
      }
      registrated()
    } else {
      AlertDialog.showAlert("Ошибка", message: "Заполните все поля", viewController: self)
    }
  }
  
}

extension NameSurnameViewController: SignInViewProtocol {
  func startLoading() {
    blurView.alpha = 0.3
    activityIndicator.startAnimating()
  }
  func finishLoading() {
    blurView.alpha = 0
    activityIndicator.stopAnimating()
  }
  func setUser(user: UserVO) {
    AuthModule.currUser = user
    presenter.saveUser(context: context, user: AuthModule.currUser)
  }
  func setNoUser() {
    
  }
  func notRegistrated(resp: String) {
    AlertDialog.showAlert("Ошибка", message: resp, viewController: self)
  }
  func notLogged(resp: String) {
    
  }
  func loggedWithFacebook() {
    
  }
  func logged() {
    
  }
  func registrated() {
    DispatchQueue.main.async {
      let storyBoard = UIStoryboard(name: "Main", bundle:nil)
      let nextViewController = storyBoard.instantiateViewController(withIdentifier: "regThird") as! UserInfoViewController
      nextViewController.presenter = self.anotherPresenter
      nextViewController.presenter2 = self.presenter
      self.show(nextViewController, sender: nil)
    }
    
    //        anotherPresenter.createNewUser(newUser: AuthModule.currUser)
  }
}

extension NameSurnameViewController: SignUpViewProtocol {
  func notUpdated() {
    
  }
  func next() {
  }
  func userCreated() {
    //        DispatchQueue.main.async {
    //            let storyBoard = UIStoryboard(name: "Main", bundle:nil)
    //            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "regThird") as! UserInfoViewController
    //            self.show(nextViewController, sender: nil)
    //        }
  }
  
  func userNotCreated() {
    AlertDialog.showAlert("Ошибка регистрации", message: "Повторите еще раз", viewController: self)
  }
  
}
extension NameSurnameViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    if textField == nameTF {
      surnameTF.becomeFirstResponder()
    } else if textField == surnameTF {
      cityTF.becomeFirstResponder()
    } else {
      nameTF.becomeFirstResponder()
    }
    return true
  }
}
