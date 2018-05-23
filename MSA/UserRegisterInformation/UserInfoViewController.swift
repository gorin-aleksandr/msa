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
    
    private let presenter = SignUpPresenter(signUp: UserDataManager())
    private var dataType: PickerDataType!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.attachView(view: self)
        presenter.setHeightType(type: .sm)
        presenter.setWeightType(type: .kg)
        
        // Do any additional setup after loading the view.
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
        presenter.addProfileInfo(user: AuthModule.currUser)
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
            ageLabel.text = "\(presenter.getAges()[row])"
            presenter.setAge(age: Int(ageLabel.text!)!)
        } else if dataType == PickerDataType.Sex {
            sexLabel.text = presenter.getSexes()[row]
            presenter.setSex(sex: sexLabel.text!)
        } else if dataType == PickerDataType.Height {
            heightLabel.text = "\(presenter.getHeight()[row])"
            presenter.setHeight(height: Int(heightLabel.text!)!)
        } else if dataType == PickerDataType.Weight {
            weightLabel.text = "\(presenter.getWeight()[row])"
            presenter.setWeight(weight: Int(weightLabel.text!)!)
        } else {
            levelLabel.text = presenter.getlevels()[row]
            presenter.setLevel(level: levelLabel.text!)
        }
        closePicker()
    }
    
    func openPicker() {
        dataPicker.reloadAllComponents()
        dataPicker.alpha = 1
    }
    
    func closePicker() {
        dataPicker.alpha = 0
    }
    
}

extension UserInfoViewController: SignUpViewProtocol {
    func startLoading() {
        blurView.alpha = 0.3
        activityIndicator.startAnimating()
    }
    
    func finishLoading() {
        blurView.alpha = 0
        activityIndicator.stopAnimating()
    }
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
    
    func setUser(user: UserVO) {
        AuthModule.currUser = user
    }
    
    func userCreated() {
    }
    
    func userNotCreated() {
    }
    
}

