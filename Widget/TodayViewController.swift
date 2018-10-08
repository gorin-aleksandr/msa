//
//  TodayViewController.swift
//  Widget
//
//  Created by Pavlo Kharambura on 10/5/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var labelTest: UILabel!
    @IBOutlet weak var icon: UIImageView! {
        didSet {
            icon.layer.cornerRadius = 20
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let dates = UserDefaults.init(suiteName: "group.easyappsolutions.widget")?.value(forKey: "dates") as? [String] {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            for d in dates {
                if formatter.string(from: Date().addingTimeInterval(TimeInterval(10800)))==d {
                    labelTest.text = "У вас тренировка сегодня!!!"
                }
            }
        }
    }
    
    
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
