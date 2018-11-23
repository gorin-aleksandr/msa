//
//  HeartBeatDetailsViewController.swift
//  MSA
//
//  Created by Andrey Krit on 11/14/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import SVProgressHUD

protocol HeartBeatDetailsViewProtocol: class {
    func setTitle(title: String)
    func setActionButtonText(text: String)
    func moveBack()
    func showAlert(title: String, message: String, action: (() -> ())?)
    func hideLoader()
}

class HeartBeatDetailsViewController: UIViewController, HeartBeatDetailsViewProtocol {
    
    @IBOutlet weak var deviceNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var actionButton: UIButton!
    
    var presenter: HeartBeatDetailsPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.start()
        configureButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SVProgressHUD.dismiss()
    }
    
    func setTitle(title: String) {
        deviceNameTextField.text = title
    }
    func setActionButtonText(text: String) {
        actionButton.setTitle(text, for: .normal)
    }
    
    private func configureButton() {
        actionButton.layer.masksToBounds = true
        actionButton.layer.cornerRadius = 12
        actionButton.layer.borderWidth = 1
        actionButton.layer.borderColor = UIColor.darkGreenColor.cgColor
    }
    
    func moveBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showAlert(title: String, message: String, action: (() -> ())?) {
        SVProgressHUD.dismiss()
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let action = action {
            let cancelAction = UIAlertAction(title: "Отмена", style: .default, handler: nil)
            let proceedAction = UIAlertAction(title: "Ок", style: .default) { _ in action() }
            alertController.addAction(cancelAction)
            alertController.addAction(proceedAction)
        } else {
            let proceedAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(proceedAction)
        }
        present(alertController, animated: true)
    }
    
    func hideLoader() {
        view.isUserInteractionEnabled = true
        SVProgressHUD.dismiss()
    }
    

    @IBAction func actionButtonTapped(_ sender: Any) {
        SVProgressHUD.show()
        view.isUserInteractionEnabled = false
        presenter?.makeAction()
    }
    @IBAction func saveButtonPressed(_ sender: Any) {
        presenter?.save(newName: deviceNameTextField.text)
    }
    
}
