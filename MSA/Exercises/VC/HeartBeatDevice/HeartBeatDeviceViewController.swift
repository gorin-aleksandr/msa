//
//  HeartBeatDeviceViewController.swift
//  MSA
//
//  Created by Andrey Krit on 11/13/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol HeartBeatDeviceViewProtocol: class {
    func showAlert(title: String, message: String, action: (() -> ())?)
    func reloadTableView()
    func showLoader()
    func hideLoader()
}

class HeartBeatDeviceViewController: UIViewController, HeartBeatDeviceViewProtocol {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    
    var presenter: HeartBeatDevicePresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        configureSearshButton()
        presenter.scanForDevices()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    private func configureSearshButton() {
        searchButton.layer.masksToBounds = true
        searchButton.layer.cornerRadius = 12
        searchButton.layer.borderWidth = 1
        searchButton.layer.borderColor = UIColor.darkGreenColor.cgColor
    }
    
    
    func reloadTableView() {
        tableView.reloadData()
    }
    
    
    func showAlert(title: String, message: String, action: (() -> ())?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let action = action {
             let cancelAction = UIAlertAction(title: "Отмена", style: .default, handler: nil)
            let proceedAction = UIAlertAction(title: "Ок", style: .default) { _ in action() }
                alertController.addAction(cancelAction)
                alertController.addAction(proceedAction)
            } else {
                let proceedAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alertController.addAction(proceedAction)
            }
            present(alertController, animated: true)
        }
    @IBAction func searchForDevicesButtonDidTapped(_ sender: Any) {
        presenter.stopScanning()
        presenter.scanForDevices()
    }
    
    func showLoader() {
        SVProgressHUD.show()
    }
    
    func hideLoader() {
        SVProgressHUD.dismiss()
    }
}

extension HeartBeatDeviceViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if presenter.devices.isEmpty {
            infoLabel.text = "Нет доступных устройств"
        } else {
            infoLabel.text = "Найденые устройства:"
        }
        return presenter.devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeartBeatDeviceTableViewCell", for: indexPath) as! HeartBeatDeviceTableViewCell
        cell.configureCellWith(device: presenter.filteredDevices[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let destinationVC = UIStoryboard.init(name: "Trannings", bundle: Bundle.main).instantiateViewController(withIdentifier: "HeartBeatDetailsViewController") as! HeartBeatDetailsViewController
        presenter.stopScanning()
        let nextPresenter = presenter.makeNextPresenter(withDeviceAtIndex: indexPath.row, view: destinationVC)
        destinationVC.presenter = nextPresenter
        navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    
}
