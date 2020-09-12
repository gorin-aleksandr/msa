//
//  MeasurementsViewController.swift
//  MSA
//
//  Created by Nik on 31.08.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit
import Charts
import SVProgressHUD

class MeasurementsViewController: UIViewController, ChartViewDelegate {
  @IBOutlet var tableView: UITableView!
  
  var viewModel: MeasurementViewModel? {
    didSet {
      self.viewModel!.reloadChart = {
        self.fetchMeasurements()
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    self.tabBarController?.tabBar.isHidden = true
    fetchMeasurements()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    self.tabBarController?.tabBar.isHidden = false
  }
  
  func setupUI() {
    self.title = "Замеры"
    let backButton = UIBarButtonItem(image: UIImage(named: "arrow-left 1"), style: .plain, target: self, action: #selector(self.backAction))
    self.navigationItem.leftBarButtonItem = backButton
    self.navigationController?.navigationBar.tintColor = .newBlack
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.snp.makeConstraints { (make) in
      make.top.equalTo(self.view.snp.top)
      make.bottom.equalTo(self.view.snp.bottom)
      make.right.equalTo(self.view.snp.right)
      make.left.equalTo(self.view.snp.left)
    }
    
    let btn = UIButton(type: .custom) as UIButton
    btn.setBackgroundImage(UIImage(named: "Float"), for: .normal)
    self.view.addSubview(btn)
    btn.snp.makeConstraints { (make) in
      make.right.equalTo(self.view.snp.right).offset(screenSize.height * (-8/iPhoneXHeight))
      make.bottom.equalTo(self.view.snp.bottom).offset(screenSize.height * (-15/iPhoneXHeight))
      make.height.width.equalTo(screenSize.height * (96/iPhoneXHeight))
    }
    
    btn.addTarget(self, action: #selector(addMeasure), for: .touchUpInside)
    
  }
  
  @objc func backAction() {
    self.navigationController?.popViewController(animated: true)
  }
  
  @objc func addMeasure(_ sender: UIButton) {
    DispatchQueue.main.async {
      let nextViewController = measurementsStoryboard.instantiateViewController(withIdentifier: "AddMeasurementTypeController") as! AddMeasurementTypeController
      nextViewController.viewModel = self.viewModel
      let nc = UINavigationController(rootViewController: nextViewController)
      self.present(nc, animated: true, completion: nil)
    }
  }
  
  @objc func selectTimeFrame(_ sender: UIButton) {
    let vc = measurementsStoryboard.instantiateViewController(withIdentifier: "DateMeasurementsCalendarController") as! DateMeasurementsCalendarController
    vc.datesDelegate = self
    let nc = UINavigationController(rootViewController: vc)
    self.present(nc, animated: true, completion: nil)
  }
  
  @objc func previousWeekAction(_ sender: UIButton) {
    viewModel!.setupCurrentWeekTimeFrame(previous: true, next: false)
    self.tableView.reloadData()
  }
  
  @objc func nextWeekAction(_ sender: UIButton) {
    viewModel!.setupCurrentWeekTimeFrame(previous: false, next: true)
    self.tableView.reloadData()
  }
  
  func fetchMeasurements() {
    SVProgressHUD.show()
    viewModel!.fetchMeasurements(success: { value in
      SVProgressHUD.dismiss()
      self.tableView.reloadData()
    })
  }
  
  func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
    print("Chart value selected!")
  }
  
}

// MARK: - TableViewDataSource
extension MeasurementsViewController: UITableViewDataSource, UITableViewDelegate {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return viewModel!.heightForRow(indexPath: indexPath)
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel!.numberOfRowInSectionForDataController(section: section)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if indexPath.section == 0 {
      switch indexPath.row {
        case 0:
          let cell = viewModel!.headerCell(tableView: tableView, indexPath: indexPath)
          cell.calendarButton.addTarget(self, action: #selector(selectTimeFrame), for: .touchUpInside)
          cell.leftButton.addTarget(self, action: #selector(previousWeekAction), for: .touchUpInside)
          cell.rightButton.addTarget(self, action: #selector(nextWeekAction), for: .touchUpInside)
          return cell
        case 1:
          return viewModel!.chartCell(tableView: tableView, indexPath: indexPath)
        case 2:
          return viewModel!.measureTitleCell(tableView: tableView, indexPath: indexPath)
        default:
          return viewModel!.headerCell(tableView: tableView, indexPath: indexPath)
      }
    }
    
    if indexPath.section == 1 {
      return viewModel!.measureTypeCell(tableView: tableView, indexPath: indexPath, canSelectButton: true)
    }
    
    return viewModel!.headerCell(tableView: tableView, indexPath: indexPath)
    
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 1 {
      viewModel!.currentTypeId = indexPath.row
      viewModel!.currentTypeTitle = viewModel!.titles[indexPath.row]
      fetchMeasurements()
    }
    
  }
}


extension MeasurementsViewController: MeasurementsCalendarDelegate {
  func selectedDates(dates: [Date]) {
    self.viewModel!.isHiddenLeftRightButton = true
    self.viewModel!.selectedDatesRange = dates
    self.tableView.reloadData()
    print("Chizas! \(dates)")
  }
}

