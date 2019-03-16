//
//  SetPurposeViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 4/4/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

class SetPurposeViewController: UIViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!{didSet{activityIndicator.stopAnimating()}}
    @IBOutlet weak var labelInfo: UILabel!
    @IBOutlet weak var purposeTextField: UITextField!
    @IBOutlet weak var countCharLabel: UILabel!
    @IBOutlet weak var startTraningsView: UIView! {didSet{startTraningsView.layer.cornerRadius = 15}}
    
    private let presenter = EditProfilePresenter(profile: UserDataManager())
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationItem()
        presenter.attachView(view: self)

        // Do any additional setup after loading the view.
    }

    @objc func save() {
        if let purpose = purposeTextField.text, purpose != AuthModule.currUser.purpose {
            presenter.setPurpose(purpose: purpose)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        if let purp = AuthModule.currUser.purpose {
            purposeTextField.text = purp
        } else {
            purposeTextField.text = ""
        }
        countCharLabel.text = "\(purposeTextField.text?.count ?? 0) / 32"
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        countCharLabel.text = "\(purposeTextField.text?.count ?? 0) / 32"
    }
    
    func configureNavigationItem() {
        purposeTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        let button1 = UIBarButtonItem(image: #imageLiteral(resourceName: "ok_blue"), style: .plain, target: self, action: #selector(self.save))
        let button2 = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(back))
        button2.tintColor = darkCyanGreen
        self.navigationItem.leftBarButtonItem = button2
        self.navigationItem.rightBarButtonItem = button1
        self.navigationItem.title = "Цель тренировок"
        let attrs = [NSAttributedStringKey.foregroundColor: darkCyanGreen,
                     NSAttributedStringKey.font: UIFont(name: "Rubik-Medium", size: 17)!]
        self.navigationController?.navigationBar.titleTextAttributes = attrs

    }
    
}

extension SetPurposeViewController: EditProfileProtocol {
    
    func purposeSetted() {
        DispatchQueue.main.async {
            self.presenter.setUser(user: AuthModule.currUser, context: self.context)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func errorOcurred(_ error: String) {
        DispatchQueue.main.async {
            AlertDialog.showAlert("Ошибка", message: error, viewController: self)
        }
    }
    
    func startLoading() {
        activityIndicator.startAnimating()
    }
    
    func finishLoading() {
        activityIndicator.stopAnimating()
    }
    
    func setUser(user: UserVO) {}
    func setNoUser() {}
    func setAvatar(image: UIImage) {}
    
}
