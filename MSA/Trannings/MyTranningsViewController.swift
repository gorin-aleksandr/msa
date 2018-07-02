//
//  MyTranningsViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 6/10/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

class MyTranningsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        initialViewConfiguration()
        // Do any additional setup after loading the view.
    }

    func initialViewConfiguration() {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
