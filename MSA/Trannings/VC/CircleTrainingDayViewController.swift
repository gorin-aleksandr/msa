//
//  CircleTrainingDayViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 8/21/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

class CircleTrainingDayViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var blackView: UIView! {didSet{blackView.layer.cornerRadius=15}}
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var playNextButton: UIButton!
    @IBOutlet weak var pulseLabel: UILabel!
    @IBOutlet weak var restLabel: UILabel!
    @IBOutlet weak var restOrWorkImageView: UIImageView!
    @IBOutlet weak var pulseImageView: UIImageView!
    
    var manager = TrainingManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    private func configureUI() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.setTitle(title: manager.getCurrentTraining()?.name ?? "", subtitle: "День # . Упражнений: \(manager.getCurrentday()?.exercises.count ?? 0)")
        
        configureTableView()
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorColor = .clear
        self.tableView.register(UINib(nibName: "CircleTrainingExerciseTableViewCell", bundle: nil), forCellReuseIdentifier: "CircleTrainingExerciseTableViewCell")
    }
   
    @IBAction func backButtonAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func saveButtonAction(_ sender: Any) {
    }
    
}

extension CircleTrainingDayViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CircleTrainingExerciseTableViewCell", for: indexPath) as? CircleTrainingExerciseTableViewCell else {return UITableViewCell()}
        if let ex = manager.getCurrentday()?.exercises[indexPath.row] {
            if let e = manager.realm.getArray(ofType: Exercise.self, filterWith: NSPredicate(format: "id = %d", ex.exerciseId)).first {
                cell.picture.sd_setImage(with: URL(string: (e.pictures.first?.url)!), placeholderImage: nil, options: .allowInvalidSSLCertificates, completed: nil)
                cell.nameLabel.text = e.name
                // TODO:!!!
            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.getCurrentday()?.exercises.count ?? 0
        }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
}

