//
//  AnketaInfoViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 2/17/18.
//  Copyright © 2018 easyapps.solutions. All rights reserved.
//

import UIKit

class UserInfoViewController: UIViewController {

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

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter.attachView(view: self)
        // Do any additional setup after loading the view.
    }

    @IBAction func setAgeButton(_ sender: Any) {
        AuthModule.currUser.age = Int(ageLabel.text!)
    }
    @IBAction func setSexButton(_ sender: Any) {
        AuthModule.currUser.sex = sexLabel.text!
    }
    @IBAction func setHeightButton(_ sender: Any) {
        AuthModule.currUser.height = Int(heightLabel.text!)
    }
    @IBAction func setWeightButton(_ sender: Any) {
        AuthModule.currUser.weight = Int(weightLabel.text!)
    }
    @IBAction func setLevelButton(_ sender: Any) {
        AuthModule.currUser.level = levelLabel.text!
    }
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func confirmButton(_ sender: Any) {
        presenter.createNewUser(newUser: AuthModule.currUser)
    }
    
    @IBAction func selectSantimeters(_ sender: Any) {
        smImage.image = #imageLiteral(resourceName: "selected")
        ft.image = #imageLiteral(resourceName: "notSelected")
        AuthModule.currUser.heightType = HeightType.sm.rawValue
    }
    @IBAction func selectFuts(_ sender: Any) {
        smImage.image = #imageLiteral(resourceName: "notSelected")
        ft.image = #imageLiteral(resourceName: "selected")
        AuthModule.currUser.heightType = HeightType.ft.rawValue
    }
    @IBAction func selectKilograms(_ sender: Any) {
        kgImage.image = #imageLiteral(resourceName: "selected")
        pounds.image = #imageLiteral(resourceName: "notSelected")
        AuthModule.currUser.weightType = WeightType.kg.rawValue
    }
    @IBAction func selectPounds(_ sender: Any) {
        kgImage.image = #imageLiteral(resourceName: "notSelected")
        pounds.image = #imageLiteral(resourceName: "selected")
        AuthModule.currUser.weightType = WeightType.pd.rawValue
    }
    
}

extension UserInfoViewController: SignUpView {
 
    func openPicker(picker: UIPickerView) {
        
    }
    
    func startLoading() {
        activityIndicator.startAnimating()
    }
    
    func finishLoading() {
        activityIndicator.stopAnimating()
    }
    
    func setUser(user: UserVO) {
        AuthModule.currUser = user
    }
    
    func userCreated() {
        DispatchQueue.main.async {
            let storyBoard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MainProfileVC") as! MainViewController
            self.show(nextViewController, sender: nil)
        }
    }
    
    func userNotCreated() {
        AlertDialog.showAlert("Ошибка регистрации", message: "Повторите еще раз", viewController: self)
    }
    
    
}
