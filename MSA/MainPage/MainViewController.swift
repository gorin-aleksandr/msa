//
//  MainViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 2/18/18.
//  Copyright © 2018 easyapps.solutions. All rights reserved.
//

import UIKit

class MainViewController: BasicViewController {

    @IBOutlet weak var galleryCollectionView: UICollectionView!
    @IBOutlet weak var galleryView: UIView! { didSet { galleryView.layer.cornerRadius = 10 } }
    @IBOutlet weak var profileViewbg: UIView! { didSet { profileViewbg.layer.cornerRadius = 10 } }
    @IBOutlet weak var userImage: UIView!
    @IBOutlet weak var trainerImage: UIImageView! {didSet{trainerImage.layer.cornerRadius = 15}}
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userLevel: UILabel!
    @IBOutlet weak var dailyTraining: UILabel!
    @IBOutlet weak var dreamInsideView: UIView! {didSet {dreamInsideView.layer.cornerRadius = 9}}
    @IBOutlet weak var dreamView: UIView! { didSet{dreamView.layer.cornerRadius = 10 }}
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        configureProfile()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func configureProfile() {
        setProfileImage(image: nil, url: AuthModule.currUser.avatar)
        if let name = AuthModule.currUser.firstName, let surname = AuthModule.currUser.lastname {
            userName.text = name + " " + surname
        }
        if let level = AuthModule.currUser.level {
            userLevel.text = level
        }
        if let dream = AuthModule.currUser.purpose {
            dailyTraining.text = dream
        }
    }
    
    func setProfileImage(image: UIImage?, url: String?) {
        let customImageViev = ProfileImageView()
        if let image = image {
            customImageViev.image = image
        }
        if let url = url {
            customImageViev.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "image.jpg"), options: .allowInvalidSSLCertificates, completed: nil)
        }
        AuthModule.userAvatar = customImageViev.image
        customImageViev.frame = CGRect(x: 0, y: 0, width: 70, height: 90)
        customImageViev.setNeedsLayout()
        userImage.addSubview(customImageViev)
    }
    
    @IBAction func cameraButon(_ sender: Any) {
    }
    @IBAction func addButton(_ sender: Any) {
    }
    @IBAction func statisticButton(_ sender: Any) {
    }
    @IBAction func infoWeightHeightEct(_ sender: Any) {
    }
    @IBAction func foodButton(_ sender: Any) {
    }
    @IBAction func traningsButton(_ sender: Any) {
    }
    @IBAction func settingsButton(_ sender: Any) {
    }
    @IBAction func setPurpose(_ sender: Any) {
        
    }
    
}
