//
//  CircleTrainingDayViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 8/21/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import CoreBluetooth

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
    @IBOutlet weak var heartBeatButton: UIButton!
    
    var manager = TrainingManager(type: .my)
    var heartBeatService = HeartBeatManager()
    
    var lastConnectedDeviceId: String? {
        return UserDefaults.standard.value(forKey: "lastTimeConnectedDevice") as? String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.becameActive(_:)), name: NSNotification.Name(rawValue: "AppComeFromBackground"), object: nil)

        
        manager.initView(view: self)
        manager.initFlowView(view: self)
        configureUI()
        startTraining()
        heartBeatService.heartBeatDelegate = self
        heartBeatService.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    @objc
    private func becameActive(_ notification: NSNotification) {
        guard let time = notification.object as? Int else {return}
        if time > 5 && time < 10000 {
            manager.resetFromBackground(with: time - 5)
        }
    }
    
    private func configureUI() {
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.setTitle(title: manager.getCurrentTraining()?.name ?? "", subtitle: "День #\(manager.numberOfDay()) . Упражнений: \(manager.exercisesCount())")
        configureTableView()
        self.pauseButton.addTarget(self, action: #selector(pauseIteration(_:)), for: .touchUpInside)
        self.playButton.addTarget(self, action: #selector(resumeIteration(_:)), for: .touchUpInside)
        self.stopButton.addTarget(self, action: #selector(stopIteration(_:)), for: .touchUpInside)
        self.playNextButton.addTarget(self, action: #selector(nextIterationstate(_:)), for: .touchUpInside)
        heartBeatButton.layer.cornerRadius = 6
        heartBeatButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
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
    @IBAction func heartBeatButtonTapped(_ sender: Any) {
        let destinationVC = UIStoryboard(name: "Trannings", bundle: .main).instantiateViewController(withIdentifier: "HeartBeatDeviceViewController") as! HeartBeatDeviceViewController
        let presenter = HeartBeatDevicePresenter(view: destinationVC, heartBeatService: heartBeatService)
        destinationVC.presenter = presenter
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    private func disable(myButtons: [UIButton]) {
        let buttons = [playButton,stopButton,playNextButton,pauseButton]
        for button in buttons {
            if myButtons.contains(button!) {
                button?.isUserInteractionEnabled = false
            } else {
                button?.isUserInteractionEnabled = true
            }
        }
    }
    
    @objc private func nextIterationstate(_ sender: UIButton) {
        manager.nextStateOrIteration()
    }
    
    @objc private func stopIteration(_ sender: UIButton) {
        tableView.isUserInteractionEnabled = true
        manager.fullStop()
        disable(myButtons: [stopButton, pauseButton, playNextButton])
    }
    
    @objc private func pauseIteration(_ sender: UIButton) {
        manager.pauseIteration()
        disable(myButtons: [pauseButton, playNextButton])
    }
    
    @objc private func resumeIteration(_ sender: UIButton) {
        manager.startOrContineIteration()
        disable(myButtons: [playButton])
    }
    private func startTraining() {
        tableView.isUserInteractionEnabled = false
        manager.startTraining()
        disable(myButtons: [playButton])
    }
    
    deinit {
         heartBeatService.disconnect()
    }
}

extension CircleTrainingDayViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CircleTrainingExerciseTableViewCell", for: indexPath) as? CircleTrainingExerciseTableViewCell else {return UITableViewCell()}
        if let ex = manager.getCurrentday()?.exercises[indexPath.row] {
            if let e = manager.realm.getArray(ofType: Exercise.self, filterWith: NSPredicate(format: "id = %@", ex.exerciseId)).first {
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


extension CircleTrainingDayViewController: HeartBeatDelegate {
    func heartBitDidReceived(_ value: Int) {
        pulseLabel.text = String(value)
    }
    
    func connectLastDeviceIfAvailable() {
        heartBeatService.scanForDevices()
    }
}

extension CircleTrainingDayViewController: HeartBeatManagerDelegate {
    func handleBluetooth(status: CBManagerState) {
        if  let _ = lastConnectedDeviceId, status == .poweredOn {
            heartBeatService.scanForDevices()
        }
    }
    
    func deviceDetected(device: CBPeripheral) {
        if let id = lastConnectedDeviceId, id == device.identifier.uuidString  {
            heartBeatService.connectDevice(with: id)
        }
    }
    
    func deviceDidFailedToConnect(peripheral: CBPeripheral, error: Error?) {}
    
    func deviceDidConnected(peripheral: CBPeripheral) {}
    
    func couldNotDiscoverServicesOrCharacteristics() {}
    
    func deviceDidDisconnected() {}
    
}

