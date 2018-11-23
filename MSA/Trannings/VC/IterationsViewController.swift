//
//  WeightAndCapacityViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 8/20/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import CoreBluetooth

class IterationsViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var loadingView: UIView!
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
    @IBOutlet weak var restOrWorkImageView: UIImageView!
    @IBOutlet weak var pulseImageView: UIImageView!
    @IBOutlet weak var heartBeatButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var manager = TrainingManager(type: .my)
    let heartBeatService = HeartBeatManager()
    
    var lastConnectedDeviceId: String? {
        return UserDefaults.standard.value(forKey: "lastTimeConnectedDevice") as? String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.becameActive(_:)), name: NSNotification.Name(rawValue: "AppComeFromBackground"), object: nil)

        
        manager.initView(view: self)
        manager.initFlowView(view: self)
        manager.setState(state: .iterationsOnly)
        heartBeatService.heartBeatDelegate = self
        heartBeatService.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureUI()
        tableView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        addPodhodButton.setShadow(shadowOpacity: 0.4)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        manager.finish()
    }
    
    private func configureUI() {
        loadingView.isHidden = true
        navigationController?.setNavigationBarHidden(false, animated: true)
        let attrs = [NSAttributedStringKey.foregroundColor: darkCyanGreen,
                     NSAttributedStringKey.font: UIFont(name: "Rubik-Medium", size: 17)!]
        self.navigationController?.navigationBar.titleTextAttributes = attrs
        self.traningLabel.text = manager.getCurrentExercise()?.name
        self.addButton.addTarget(self, action: #selector(addIteration), for: .touchUpInside)
        configureTableView()
        self.pauseButton.addTarget(self, action: #selector(pauseIteration(_:)), for: .touchUpInside)
        self.playButton.addTarget(self, action: #selector(resumeIteration(_:)), for: .touchUpInside)
        self.stopButton.addTarget(self, action: #selector(stopIteration(_:)), for: .touchUpInside)
        self.playNextButton.addTarget(self, action: #selector(nextIterationstate(_:)), for: .touchUpInside)
        heartBeatButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        heartBeatButton.layer.cornerRadius = 6
        
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
    
    @objc private func becameActive(_ notification: NSNotification) {
        guard let time = notification.object as? Int else {return}
        if time > 5 && time < 10000 {
            manager.resetFromBackground(with: time - 5)
        }
    }
    
    @objc private func nextIterationstate(_ sender: UIButton) {
        if iterationsPresent() {
            manager.nextStateOrIteration()
        }
    }

    @objc private func stopIteration(_ sender: UIButton) {
        if iterationsPresent() {
            manager.fullStop()
            disable(myButtons: [stopButton, pauseButton, playNextButton])
        }
    }
    
    @objc private func pauseIteration(_ sender: UIButton) {
        if iterationsPresent() {
            manager.pauseIteration()
            disable(myButtons: [pauseButton, playNextButton])
        }
    }
    
    @objc private func resumeIteration(_ sender: UIButton) {
        if iterationsPresent() {
            manager.startOrContineIteration()
            disable(myButtons: [playButton])
        } else {
            AlertDialog.showAlert("Вы не можете начать!", message: "Добавьте хотя бы одну итерацию.", viewController: self)
        }
    }
    @objc private func startIteration(_ sender: UIButton) {
        manager.startExercise(from: sender.tag)
        disable(myButtons: [playButton])
    }
    
    private func iterationsPresent() -> Bool {
        if manager.getCurrentExercise()?.iterations.count == 0 {
            return false
        } else {
            return true
        }
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
    @IBAction func showExerciseInfo(_ sender: Any) {
        performSegue(withIdentifier: "exerciseInfo", sender: nil)
    }
    @IBAction func moveToDevicesViewController(_ sender: Any) {
        let destinationVC = UIStoryboard(name: "Trannings", bundle: .main).instantiateViewController(withIdentifier: "HeartBeatDeviceViewController") as! HeartBeatDeviceViewController
        let presenter = HeartBeatDevicePresenter(view: destinationVC, heartBeatService: heartBeatService)
        destinationVC.presenter = presenter
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    @objc
    func back() {
//        manager.fullStop()
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    func addIteration() {
        manager.addIteration {
            UIView.transition(with: self.tableView, duration: 0.35, options: .transitionCrossDissolve, animations: { self.tableView.reloadData() })
        }
    }
    
    @objc
    func copyIteration(at index: Int) {
        manager.copyIteration(index: index) {
            UIView.transition(with: self.tableView, duration: 0.35, options: .transitionCrossDissolve, animations: { self.tableView.reloadData() })
        }
    }
    
    fileprivate func whitespaceString(font: UIFont = UIFont(name: "Rubik-Medium", size: 17)!, width: CGFloat) -> String {
        let kPadding: CGFloat = 20
        let mutable = NSMutableString(string: "")
        let attribute = [kCTFontAttributeName: font]
        while mutable.size(withAttributes: attribute as [NSAttributedStringKey : Any]).width < width - (2 * kPadding) {
            mutable.append(" ")
        }
        return mutable as String
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "exerciseInfo":
            guard let vc = segue.destination as? ExercisesInfoViewController else {return}
            vc.execise = manager.realm.getElement(ofType: Exercise.self, filterWith: NSPredicate(format: "id = %@", manager.getCurrentExercise()?.exerciseId ?? "")) ?? nil
        case "configureIteration":
            guard let vc = segue.destination as? ConfigureTranningExersViewController else {return}
            vc.manager = self.manager
        default:
            return
        }
    }
    
    deinit {
        heartBeatService.disconnect()
    }
    
}

extension IterationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ApproachTableViewCell", for: indexPath) as? ApproachTableViewCell else {return UITableViewCell()}
        if let iteration = manager.getCurrentExercise()?.iterations[indexPath.row] {
            cell.configureCell(iteration: iteration, indexPath: indexPath)
            cell.restButton.addTarget(self, action: #selector(startIteration(_:)), for: .touchUpInside)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.getCurrentExercise()?.iterations.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let iteration = manager.getCurrentExercise()?.iterations[indexPath.row] {
            manager.setCurrent(iteration: iteration)
            performSegue(withIdentifier: "configureIteration", sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = getDeleteAction()
        let copy = getCopyAction()
        return [delete, copy]
    }
    
    private func getCopyAction() -> UITableViewRowAction {
        let copy = UITableViewRowAction(style: .normal, title: "Копировать") { (action, indexPath) in
            self.copyIteration(at: indexPath.row)
        }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 110, height: 55))
        view.backgroundColor = UIColor.white
        let imageView = UIImageView(frame: CGRect(x: 0, y: 15, width: 100, height: 26))
        imageView.image = #imageLiteral(resourceName: "small_primary")
        view.addSubview(imageView)
        let image = view.image()
        copy.backgroundColor = UIColor(patternImage: image)
        
        return copy
    }
    
    private func getDeleteAction() -> UITableViewRowAction {
        let delete = UITableViewRowAction(style: .normal, title: ".") { (action, indexPath) in
            guard let object = self.manager.getCurrentExercise()?.iterations[indexPath.row] else {return}
            self.manager.realm.deleteObject(object)
            self.manager.editTraining(wiht: self.manager.getCurrentTraining()?.id ?? -1, success: {})
            UIView.transition(with: self.tableView, duration: 0.35, options: .transitionCrossDissolve, animations: { self.tableView.reloadData() })

        }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 55))
        view.backgroundColor = UIColor.white
        let imageView = UIImageView(frame: CGRect(x: 30, y: 18, width: 19, height: 19))
        imageView.image = #imageLiteral(resourceName: "delete_red_24px")
        view.addSubview(imageView)
        let image = view.image()
        delete.backgroundColor = UIColor(patternImage: image)

        return delete
    }
    
}

extension IterationsViewController: TrainingsViewDelegate {
    func startLoading() {
        loadingView.isHidden = false
    }
    
    func finishLoading() {
        loadingView.isHidden = true
    }
    func trainingsLoaded() {}
    func templateCreated() {}
    func templatesLoaded() {}
    func trainingEdited() {}
    func errorOccurred(err: String) {}
    func synced() {}
}

extension IterationsViewController: TrainingFlowDelegate {
    
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
    }
    
    func higlightIteration(on: Int) {
        let indexPath = IndexPath(row: on, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = lightBLUE
        if on != 0 {
            let prevIndexPath = IndexPath(row: on-1, section: 0)
            let cell = tableView.cellForRow(at: prevIndexPath)
            cell?.backgroundColor = .white
        } else {
            let row = (manager.getCurrentExercise()?.iterations.count ?? 0) - 1
            let indexPath = IndexPath(row: row, section: 0)
            let cell = tableView.cellForRow(at: indexPath)
            cell?.backgroundColor = .white
        }
    }
}

extension IterationsViewController: HeartBeatDelegate {
    func heartBitDidReceived(_ value: Int) {
        pulseLabel.text = String(value)
    }
    
    func connectLastDeviceIfAvailable() {
        heartBeatService.scanForDevices()
    }
}

extension IterationsViewController: HeartBeatManagerDelegate {
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
