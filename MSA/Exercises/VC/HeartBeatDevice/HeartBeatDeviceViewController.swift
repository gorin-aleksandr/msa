//
//  HeartBeatDeviceViewController.swift
//  MSA
//
//  Created by Andrey Krit on 11/13/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

class HeartBeatDeviceViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        configureSearshButton()
    }
    
    private func configureSearshButton() {
        searchButton.layer.masksToBounds = true
        searchButton.layer.cornerRadius = 12
        searchButton.layer.borderWidth = 1
        searchButton.layer.borderColor = UIColor.darkGreenColor.cgColor
    }

}

extension HeartBeatDeviceViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeartBeatDeviceTableViewCell", for: indexPath) as! HeartBeatDeviceTableViewCell
        return cell
    }
    
    
}
