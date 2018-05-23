//
//  EditProfileViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 4/4/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class EditProfileViewController: UIViewController {

    @IBOutlet weak var profilePhoto: UIView!
    @IBOutlet weak var changeImageButton: UIButton! {didSet{changeImageButton.imageView?.contentMode = .scaleAspectFit}}
    
    @IBOutlet weak var trainername: UILabel!
    @IBOutlet weak var trainerImage: UIImageView! {didSet{trainerImage.layer.cornerRadius = 25}}
    
    @IBOutlet weak var userNametextField: SkyFloatingLabelTextField!
    @IBOutlet weak var userSurnameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var sportsmanTypeImage: UIImageView!
    @IBOutlet weak var trainerTypeImage: UIImageView!
    
    @IBOutlet weak var smImage: UIImageView!
    @IBOutlet weak var ftImage: UIImageView!
    @IBOutlet weak var kgImage: UIImageView!
    @IBOutlet weak var pdImage: UIImageView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var changePass: UIButton! {didSet{changePass.layer.cornerRadius = 15}}
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationItem()
        setProfileImage(image: #imageLiteral(resourceName: "me"))
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func configureNavigationItem() {
        let button1 = UIBarButtonItem(image: #imageLiteral(resourceName: "ok_blue"), style: .plain, target: self, action: #selector(self.back))
        let button2 = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(self.back))
        button2.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = button2
        self.navigationItem.rightBarButtonItem = button1
        self.navigationItem.title = "Настройки"
    }
    
    func setProfileImage(image: UIImage) {
        let customImageViev = ProfileImageView()
        customImageViev.image = image
        customImageViev.frame = CGRect(x: 0, y: 0, width: 115, height: 145)
        customImageViev.setNeedsLayout()
        profilePhoto.addSubview(customImageViev)
    }
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func changeProfilePhotoButton(_ sender: Any) {
    
    }
    @IBAction func deleteTrainer(_ sender: Any) {
    }
    @IBAction func setSportsmanType(_ sender: Any) {
    }
    @IBAction func setTrainerType(_ sender: Any) {
    }
    @IBAction func setAge(_ sender: Any) {
    }
    @IBAction func setSex(_ sender: Any) {
    }
    @IBAction func setHeight(_ sender: Any) {
    }
    @IBAction func setWeight(_ sender: Any) {
    }
    @IBAction func setLevel(_ sender: Any) {
    }
    @IBAction func setSantimeters(_ sender: Any) {
    }
    @IBAction func setFt(_ sender: Any) {
    }
    @IBAction func setKg(_ sender: Any) {
    }
    @IBAction func setPd(_ sender: Any) {
    }
    
    @IBAction func help(_ sender: Any) {
    }
    @IBAction func rules(_ sender: Any) {
    }
    @IBAction func logout(_ sender: Any) {
    }
    
}
