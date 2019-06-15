//
//  AnketaInfoViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 2/17/18.
//  Copyright © 2018 easyapps.solutions. All rights reserved.
//

import UIKit

enum PickerDataType {
    case Age
    case Height
    case Weight
    case Sex
    case Level
}

class UserInfoViewController: BasicViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var buttonClose: UIButton! {didSet{buttonClose.alpha = 0}}
    @IBOutlet weak var sexHeader: UILabel!
    @IBOutlet weak var heightHeader: UILabel!
    @IBOutlet weak var weightHeader: UILabel!
    @IBOutlet weak var ageHeader: UILabel!
    @IBOutlet weak var levelHeader: UILabel!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var dataPicker: UIPickerView! {didSet{dataPicker.alpha = 0}}
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var smImage: UIImageView!
    @IBOutlet weak var ft: UIImageView!
    @IBOutlet weak var kgImage: UIImageView!
    @IBOutlet weak var pounds: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {didSet{activityIndicator.stopAnimating()}}
    
    @IBOutlet weak var stackWithMeasureButtons: UIStackView!
    @IBOutlet weak var weightStackView: UIStackView!
    @IBOutlet weak var measureStackView: UIStackView!
     var presenter = SignUpPresenter(signUp: UserDataManager())
     var dataType: PickerDataType!
     var presenter2 = UserSignInPresenter(auth: AuthModule())
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.attachView(view: self)
        presenter2.attachView(view: self)

        presenter.setHeightType(type: .sm)
        presenter.setWeightType(type: .kg)
        
        //Temporary fix
        measureStackView.layer.opacity = 0
        weightStackView.layer.opacity = 0
        configureHeaders()
    }

    func configureHeaders() {
        sexHeader.isHidden = AuthModule.currUser.sex == nil
        ageHeader.isHidden = AuthModule.currUser.age == nil
        weightHeader.isHidden = AuthModule.currUser.weight == nil
        heightHeader.isHidden = AuthModule.currUser.height == nil
        levelHeader.isHidden = AuthModule.currUser.level == nil
        
        sexLabel.text = AuthModule.currUser.sex == nil ? "Пол" : (AuthModule.currUser.sex ?? "") + ", пол"
        ageLabel.text = AuthModule.currUser.age == nil ? "Возраст" : "\(AuthModule.currUser.age ?? 0)" + ", лет"
        weightLabel.text = AuthModule.currUser.weight == nil ? "Вес" : "\(AuthModule.currUser.weight ?? 0)" + ", кг"
        heightLabel.text = AuthModule.currUser.height == nil ? "Рост" : "\(AuthModule.currUser.height ?? 0)" + ", см"
        levelLabel.text = AuthModule.currUser.level == nil ? "Уровень подготовки" : "\(AuthModule.currUser.level ?? "")"
    }
    
    @IBAction func setAgeButton(_ sender: Any) {
        dataType = PickerDataType.Age
        openPicker()
    }
    @IBAction func setSexButton(_ sender: Any) {
        dataType = PickerDataType.Sex
        openPicker()
    }
    @IBAction func setHeightButton(_ sender: Any) {
        dataType = PickerDataType.Height
        openPicker()
    }
    @IBAction func setWeightButton(_ sender: Any) {
        dataType = PickerDataType.Weight
        openPicker()
    }
    @IBAction func setLevelButton(_ sender: Any) {
        dataType = PickerDataType.Level
        openPicker()
    }
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func confirmButton(_ sender: Any) {
        if !AuthModule.facebookAuth {
            if let email = AuthModule.currUser.email {
                presenter2.registerUser(email: email, password: AuthModule.pass)
            }
        } else {
            presenter.createNewUser(newUser: AuthModule.currUser)
        }

//        presenter.addProfileInfo(user: AuthModule.currUser)
    }
    
    @IBAction func selectSantimeters(_ sender: Any) {
        smImage.image = #imageLiteral(resourceName: "selected")
        ft.image = #imageLiteral(resourceName: "notSelected")
        presenter.setHeightType(type: .sm)
    }
    @IBAction func selectFuts(_ sender: Any) {
        smImage.image = #imageLiteral(resourceName: "notSelected")
        ft.image = #imageLiteral(resourceName: "selected")
        presenter.setHeightType(type: .ft)
    }
    @IBAction func selectKilograms(_ sender: Any) {
        kgImage.image = #imageLiteral(resourceName: "selected")
        pounds.image = #imageLiteral(resourceName: "notSelected")
        presenter.setWeightType(type: .kg)
    }
    @IBAction func selectPounds(_ sender: Any) {
        kgImage.image = #imageLiteral(resourceName: "notSelected")
        pounds.image = #imageLiteral(resourceName: "selected")
        presenter.setWeightType(type: .pd)
    }
    @IBAction func closePicker(_ sender: Any) {
        self.closePicker()
    }
    
}

extension UserInfoViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if dataType == PickerDataType.Age {
            return presenter.getAges().count
        } else if dataType == PickerDataType.Sex {
            return presenter.getSexes().count
        } else if dataType == PickerDataType.Height {
            return presenter.getHeight().count
        } else if dataType == PickerDataType.Weight {
            return presenter.getWeight().count
        } else {
            return presenter.getlevels().count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if dataType == PickerDataType.Age {
            return "\(presenter.getAges()[row])"
        } else if dataType == PickerDataType.Sex {
            return presenter.getSexes()[row]
        } else if dataType == PickerDataType.Height {
            return "\(presenter.getHeight()[row])"
        } else if dataType == PickerDataType.Weight {
            return "\(presenter.getWeight()[row])"
        } else {
            return presenter.getlevels()[row]
        }
    }
 
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if dataType == PickerDataType.Age {
            ageLabel.text = "\(presenter.getAges()[row]), лет"
            presenter.setAge(age: Int(presenter.getAges()[row]))
        } else if dataType == PickerDataType.Sex {
            sexLabel.text = "\(presenter.getSexes()[row]), пол"
            presenter.setSex(sex: presenter.getSexes()[row])
        } else if dataType == PickerDataType.Height {
            heightLabel.text = "\(presenter.getHeight()[row]), см"
            presenter.setHeight(height: Int(presenter.getHeight()[row]))
        } else if dataType == PickerDataType.Weight {
            weightLabel.text = "\(presenter.getWeight()[row]), кг"
            presenter.setWeight(weight: Int(presenter.getWeight()[row]))
        } else {
            levelLabel.text = presenter.getlevels()[row]
            presenter.setLevel(level: levelLabel.text!)
        }
        configureHeaders()
    }
    
    func openPicker() {
        var row = 0
        if dataType == PickerDataType.Age {
            if let age = AuthModule.currUser.age {
                row = presenter.getAges().firstIndex(of: age) ?? 16
            } else {
                row = 16
            }
        } else if dataType == PickerDataType.Sex {
            if let sex = AuthModule.currUser.sex {
                row = presenter.getSexes().firstIndex(of: sex) ?? 0
            }
        } else if dataType == PickerDataType.Height {
            if let h = AuthModule.currUser.height {
                row = presenter.getHeight().firstIndex(of: h) ?? 90
            } else {
                row = 90
            }
        } else if dataType == PickerDataType.Weight {
            if let w = AuthModule.currUser.weight {
                row = presenter.getWeight().firstIndex(of: w) ?? 20
            } else {
                row = 20
            }
        } else {
            if let l = AuthModule.currUser.level {
                row = presenter.getlevels().firstIndex(of: l) ?? 0
            } else {
                row = 0
            }
        }
        dataPicker.reloadAllComponents()
        dataPicker.selectRow(row, inComponent: 0, animated: true)
        dataPicker.alpha = 1
        buttonClose.alpha = 1
    }
    
    func closePicker() {
        dataPicker.alpha = 0
        buttonClose.alpha = 0
    }
    
}

extension UserInfoViewController: SignUpViewProtocol {
//    func startLoading() {
//        blurView.alpha = 0.3
//        activityIndicator.startAnimating()
//    }
//
//    func finishLoading() {
//        blurView.alpha = 0
//        activityIndicator.stopAnimating()
//    }
    func next() {
        presenter.saveUser(context: context, user: AuthModule.currUser)
        DispatchQueue.main.async {
            let storyBoard = UIStoryboard(name: "Profile", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarVC") as! UITabBarController
            self.show(nextViewController, sender: nil)
        }
    }
    func notUpdated() {
        AlertDialog.showAlert("Ошибка", message: "Ошибка добавления інформации", viewController: self)
    }
    
//    func setUser(user: UserVO) {
//        AuthModule.currUser = user
//    }
    
    func userCreated() {
        presenter.addProfileInfo(user: AuthModule.currUser)
    }
    
    func userNotCreated() {
        AlertDialog.showAlert("Ошибка регистрации", message: "Повторите еще раз", viewController: self)
    }
    
}

extension UserInfoViewController: SignInViewProtocol {
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
        presenter.createNewUser(newUser: AuthModule.currUser)
    }
}
