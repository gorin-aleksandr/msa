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

        manager.initView(view: self)
        manager.initFlowView(view: self)
        configureUI()
        startTraining()
    }

    private func configureUI() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.setTitle(title: manager.getCurrentTraining()?.name ?? "", subtitle: "День #\(manager.numberOfDay()) . Упражнений: \(manager.exercisesCount())")
        configureTableView()
        self.pauseButton.addTarget(self, action: #selector(pauseIteration(_:)), for: .touchUpInside)
        self.playButton.addTarget(self, action: #selector(resumeIteration(_:)), for: .touchUpInside)
        self.stopButton.addTarget(self, action: #selector(stopIteration(_:)), for: .touchUpInside)
        self.playNextButton.addTarget(self, action: #selector(nextIterationstate(_:)), for: .touchUpInside)
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
        manager.fullStop()
    }
    @IBAction func saveButtonAction(_ sender: Any) {
    }
    
    @objc private func nextIterationstate(_ sender: UIButton) {
        manager.nextStateOrIteration()
    }
    
    @objc private func stopIteration(_ sender: UIButton) {
        manager.fullStop()
    }
    
    @objc private func pauseIteration(_ sender: UIButton) {
        manager.pauseIteration()
    }
    
    @objc private func resumeIteration(_ sender: UIButton) {
        manager.startOrContineIteration()
    }
    private func startTraining() {
        manager.startTraining()
    }
}

extension CircleTrainingDayViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CircleTrainingExerciseTableViewCell", for: indexPath) as? CircleTrainingExerciseTableViewCell else {return UITableViewCell()}
        if let ex = manager.getCurrentday()?.exercises[indexPath.row] {
            if let e = manager.realm.getArray(ofType: Exercise.self, filterWith: NSPredicate(format: "id = %d", ex.exerciseId)).first {
                cell.picture.sd_setImage(with: URL(string: (e.pictures.first?.url)!), placeholderImage: nil, options: .allowInvalidSSLCertificates, completed: nil)
                cell.nameLabel.text = e.name
            }
            cell.podhodCountLabel.text =  "Подход #  из \(ex.iterations.count)"
            cell.circleButton.isHidden = manager.trainingState == .round ? false : true
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


extension CircleTrainingDayViewController: TrainingsViewDelegate {
    func startLoading() {
//        loadingView.isHidden = false
    }
    
    func finishLoading() {
//        loadingView.isHidden = true
    }
    func trainingsLoaded() {}
    func templateCreated() {}
    func templatesLoaded() {}
    func trainingEdited() {}
    func errorOccurred(err: String) {}
    func synced() {}
}

extension CircleTrainingDayViewController: TrainingFlowDelegate {
    
    func rewriteIterations() {
        tableView.reloadData()
    }
    
    private func configureWorkView(time: String) {
        restLabel.textColor = lightGREEN
        restOrWorkImageView.image = UIImage(named: "title_timer-1")
        restLabel.text = time
    }
    private func configureRestView(time: String) {
        restLabel.textColor = lightRED
        restOrWorkImageView.image = UIImage(named: "title_timer_1")
        restLabel.text = time
    }
    
    func changeTime(time: String, iterationState: IterationState, i: (Int,Int)) {
        switch iterationState {
        case .work:
            configureWorkView(time: time)
        case .rest:
            configureRestView(time: time)
        }
        let indexPath = IndexPath(row: i.0, section: 0)
        guard let cell = tableView.cellForRow(at: indexPath) as? CircleTrainingExerciseTableViewCell else {return}
        cell.podhodCountLabel.text = "Подход #\(i.1+1) из \(manager.getIterationsCount())"
        cell.counts.setTitle("\(manager.getCurrentIterationInfo().counts)", for: .normal)
        cell.kdButton.setTitle("\(manager.getCurrentIterationInfo().weight) кг", for: .normal)
        cell.progressView.progress = Float(i.1+1)/Float(manager.getIterationsCount())
    }
    
    func higlightIteration(on: Int) {
        let indexPath = IndexPath(row: on, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? CircleTrainingExerciseTableViewCell else {return}
        cell.bgView.backgroundColor = lightBLUE
        if on != 0 {
            let prevIndexPath = IndexPath(row: on-1, section: 0)
            let cell = tableView.cellForRow(at: prevIndexPath)
            cell?.backgroundColor = .white
        } else {
            let row = (manager.getCurrentExercise()?.iterations.count ?? 0) - 1
            let indexPath = IndexPath(row: row, section: 0)
            guard let cell = tableView.cellForRow(at: indexPath) as? CircleTrainingExerciseTableViewCell else {return}
            cell.bgView.backgroundColor = .white
        }
    }
}

