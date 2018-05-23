//
//  StartViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 5/8/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var indacator: UIActivityIndicatorView! {
        didSet{
            indacator.startAnimating()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let start = StratCoordinator(nav: self.navigationController!, cont: context)
//        start.start()
        
        // Do any additional setup after loading the view.
    }



}
