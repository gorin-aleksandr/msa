//
//  MeasurementsViewController.swift
//  MSA
//
//  Created by Nik on 31.08.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit

class AddMeasurementTypeController: UIViewController {
 
  
  @IBOutlet var tableView: UITableView!
  var viewModel: MeasurementViewModel?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
   override func viewWillAppear(_ animated: Bool) {
     super.viewWillAppear(true)
     self.tabBarController?.tabBar.isHidden = true
   }
   
   override func viewWillDisappear(_ animated: Bool) {
     super.viewWillDisappear(true)
     self.tabBarController?.tabBar.isHidden = false
   }
  
  func setupUI() {
    self.title = "Замеры"
    tableView.dataSource = self
    tableView.delegate = self
    tableView.tableFooterView = UIView()
    tableView.snp.makeConstraints { (make) in
      make.top.equalTo(self.view.snp.top)
      make.bottom.equalTo(self.view.snp.bottom)
      make.right.equalTo(self.view.snp.right)
      make.left.equalTo(self.view.snp.left)
    }
    let backButton = UIBarButtonItem(image: UIImage(named: "backIcon"), style: .plain, target: self, action: #selector(self.backAction))
    self.navigationItem.leftBarButtonItem = backButton
    self.navigationController?.navigationBar.tintColor = .newBlack
    
  }
  
  @objc func backAction() {
    self.dismiss(animated: true, completion: nil)
  }
  
}

// MARK: - TableViewDataSource
extension AddMeasurementTypeController: UITableViewDataSource, UITableViewDelegate {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return screenSize.height * (78/iPhoneXHeight)
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel!.numberOfRowInMeasurementTypeController(section: section)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = viewModel!.measureTypeCell(tableView: tableView, indexPath: indexPath, canSelectButton: false)
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    DispatchQueue.main.async {
      let nextViewController = measurementsStoryboard.instantiateViewController(withIdentifier: "NewMeasurementViewController") as! NewMeasurementViewController
      nextViewController.modalPresentationStyle = .overFullScreen
      nextViewController.viewModel = self.viewModel
      nextViewController.viewModel!.newMeasurementId = indexPath.row
      self.present(nextViewController, animated: true, completion: nil)
    }
  }
}

