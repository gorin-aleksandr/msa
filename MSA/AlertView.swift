//
//  AlertView.swift
//  MSA
//
//  Created by Pavlo Kharambura on 2/20/18.
//  Copyright © 2018 easyapps.solutions. All rights reserved.
//

import Foundation
import UIKit

class AlertDialog {
    
    class func showAlert(_ title: String, message: String, viewController: UIViewController, dismissed: (() -> Void)? = nil) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "Ok", style: .cancel) { (action) in
            dismissed?()
        }
        alertController.addAction(dismissAction)
        
        viewController.present(alertController, animated: true, completion: nil)
        
    }
    
    class func showConfirmationAlert(_ title: String, message: String, viewController: UIViewController, confirmAction: (() -> Void)? = nil) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Oк", style: .default) { (action) in
            confirmAction?()
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        viewController.present(alertController, animated: true, completion: nil)
        
    }
    
    class func showGeneralErrorAlert(on viewController: UIViewController) {
        let alertController = UIAlertController(title: "Ошибка", message: "Попробуйте еще раз.", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "Ok", style: .cancel)
        alertController.addAction(dismissAction)
        viewController.present(alertController, animated: true, completion: nil)

    }
    
}
