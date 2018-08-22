//
//  MyTranningsViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 6/10/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

class MyTranningsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialViewConfiguration()
    }

    func initialViewConfiguration() {
        segmentControl.layer.masksToBounds = true
        segmentControl.layer.cornerRadius = 13
        segmentControl.layer.borderColor = lightBlue.cgColor
        segmentControl.layer.borderWidth = 1
        navigationController?.navigationBar.layer.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1).cgColor
        navigationController?.setNavigationBarHidden(false, animated: true)
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.black,
                     NSAttributedStringKey.font: UIFont(name: "Rubik-Medium", size: 17)!]
        self.navigationController?.navigationBar.titleTextAttributes = attrs
        configureTableView()
        
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
    }
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func calendarButtonAction(_ sender: Any) {
    }
    @IBAction func addButtonAction(_ sender: Any) {
    }
    @IBAction func optionsButton(_ sender: Any) {
    }

}

extension MyTranningsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
}
