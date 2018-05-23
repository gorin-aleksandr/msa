//
//  SetPurposeViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 4/4/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

class SetPurposeViewController: UIViewController {

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

    @objc func back() {
        if let purpose = purposeTextField.text {
            presenter.setPurpose(purpose: purpose)
        }
//        navigationController?.popViewController(animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        countCharLabel.text = "\(purposeTextField.text?.count ?? 0) / 32"
    }
    
    func configureNavigationItem() {
        purposeTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        let button1 = UIBarButtonItem(image: #imageLiteral(resourceName: "ok_blue"), style: .plain, target: self, action: #selector(self.back))
        let button2 = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(self.back))
        button2.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = button2
        self.navigationItem.rightBarButtonItem = button1
        self.navigationItem.title = "Цель тренировок"
    }
    
}

extension SetPurposeViewController: EditProfileProtocol {
    
    func purposeSetted() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func errorOcurred(_ error: String) {
        DispatchQueue.main.async {
            AlertDialog.showAlert("Ошибка", message: error, viewController: self)
        }
    }
    
    func startLoading() {
//        activityIndicator.startAnimating()
    }
    
    func finishLoading() {
//        activityIndicator.stopAnimating()
    }
    
    func setUser(user: UserVO) {}
    func setNoUser() {}
    func setAvatar(image: UIImage) {}
    
}
