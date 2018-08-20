//
//  WeightAndCapacityViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 8/20/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

class WeightAndCapacityViewController: UIViewController {

    @IBOutlet weak var traningLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var addPodhodButton: UIView!{didSet{addPodhodButton.layer.cornerRadius=12}}
    
    @IBOutlet weak var blackView: UIView! {didSet{blackView.layer.cornerRadius=15}}
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var playNextButton: UIButton!
    @IBOutlet weak var pulseLabel: UILabel!
    @IBOutlet weak var restLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    override func viewWillLayoutSubviews() {
        addPodhodButton.setShadow(shadowOpacity: 0.4)
    }
        
    private func configureUI() {
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
        self.tableView.register(UINib(nibName: "ApproachTableViewCell", bundle: nil), forCellReuseIdentifier: "ApproachTableViewCell")
    }
    
    @IBAction func backAction(_ sender: Any) {
        back()
    }
    
    @objc
    func back() {
        navigationController?.popViewController(animated: true)
    }
    
}

extension WeightAndCapacityViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ApproachTableViewCell", for: indexPath) as? ApproachTableViewCell else {return UITableViewCell()}
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}
