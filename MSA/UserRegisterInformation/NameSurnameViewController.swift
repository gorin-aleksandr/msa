//
//  RegSecondViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 2/22/18.
//  Copyright © 2018 easyapps.solutions. All rights reserved.
//

import UIKit

enum MSA_User_Type: String {
    case sport = "СПОРТСМЕН"
    case trainer = "ТРЕНЕР"
}

class NameSurnameViewController: UIViewController {

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var surnameTF: UITextField!
    @IBOutlet weak var sportsmanImage: UIImageView!
    @IBOutlet weak var trainerImage: UIImageView!
    
    var type = MSA_User_Type.sport
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let name = AuthModule.currUser.firstName {
            nameTF.text = name
        }
        if let surname = AuthModule.currUser.lastname {
            surnameTF.text = surname
        }
        // Do any additional setup after loading the view.
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
        if nameTF.text != "" && surnameTF.text != "" {
            AuthModule.currUser.firstName = nameTF.text!
            AuthModule.currUser.lastname = surnameTF.text!
            AuthModule.currUser.type = type.rawValue
        } else {
            AlertDialog.showAlert("Ошибка", message: "Заполните все поля", viewController: self)
        }
    }
    
    
    
}
