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
import Firebase
import Charts

class MeasurementsViewController: UIViewController, ChartViewDelegate {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var leftButton: UIButton!
  @IBOutlet weak var rightButton: UIButton!
  @IBOutlet weak var calendarButton: UIButton!
  @IBOutlet weak var titleContentView: UIView!
  
  @IBOutlet weak var titleMeasureLabel: UILabel!
  @IBOutlet weak var iconImageView: UIImageView!
  @IBOutlet weak var titlMeasureContentView: UIView!
  
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet var chartView: LineChartView!
  
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
    Analytics.logEvent("measurements_screen", parameters: ["name": viewModel!.currentTypeTitle])
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
    
    titleContentView.snp.makeConstraints { (make) in
      make.top.equalTo(self.view.snp.top)
      make.height.equalTo(screenSize.height * (60/iPhoneXHeight))
      make.right.equalTo(self.view.snp.right)
      make.left.equalTo(self.view.snp.left)
    }
    
    titleLabel.font = NewFonts.SFProDisplayBold20
    titleLabel.textColor = UIColor.newBlack
    
    titleLabel.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.titleContentView.snp.centerY)
      make.left.equalTo(self.titleContentView.snp.left).offset(screenSize.height * (16/iPhoneXHeight))
    }
    
    calendarButton.addTarget(self, action: #selector(selectTimeFrame), for: .touchUpInside)
    calendarButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.titleContentView.snp.centerY)
      make.left.equalTo(titleLabel.snp.right).offset(screenSize.height * (11/iPhoneXHeight))
      make.height.width.equalTo(screenSize.height * (36/iPhoneXHeight))
    }
    
    rightButton.addTarget(self, action: #selector(nextWeekAction), for: .touchUpInside)
    rightButton.snp.makeConstraints { (make) in
      make.right.equalTo(self.titleContentView.snp.right).offset(screenSize.height * (-25/iPhoneXHeight))
      make.centerY.equalTo(self.titleContentView.snp.centerY)
      make.height.equalTo(screenSize.height * (28/iPhoneXHeight))
      make.width.equalTo(screenSize.height * (28/iPhoneXHeight))
    }
    
    leftButton.addTarget(self, action: #selector(previousWeekAction), for: .touchUpInside)
    leftButton.snp.makeConstraints { (make) in
      make.right.equalTo(rightButton.snp.right).offset(screenSize.height * (-60/iPhoneXHeight))
      make.centerY.equalTo(self.titleContentView.snp.centerY)
      make.height.equalTo(screenSize.height * (28/iPhoneXHeight))
      make.width.equalTo(screenSize.height * (28/iPhoneXHeight))
    }
    
    chartView.snp.makeConstraints { (make) in
      make.top.equalTo(self.titleContentView.snp.bottom)
      make.height.equalTo(screenSize.height * (306/iPhoneXHeight))
      make.right.equalTo(self.view.snp.right).offset(screenSize.width * (-16/iPhoneXWidth))
      make.left.equalTo(self.view.snp.left).offset(screenSize.width * (16/iPhoneXWidth))
    }
    
    titlMeasureContentView.snp.makeConstraints { (make) in
      make.top.equalTo(self.chartView.snp.bottom)
      make.height.equalTo(screenSize.height * (40/iPhoneXHeight))
      make.right.equalTo(self.view.snp.right)
      make.left.equalTo(self.view.snp.left)
    }
    
    iconImageView.image = UIImage(named: "Ellipse 14")
    iconImageView.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.titlMeasureContentView.snp.centerY)
      make.left.equalTo(self.titlMeasureContentView.snp.left).offset(screenSize.height * (16/iPhoneXHeight))
      make.height.width.equalTo(screenSize.height * (16/iPhoneXHeight))
    }
    
    titleMeasureLabel.font = NewFonts.SFProDisplayRegular12
    titleMeasureLabel.textColor = UIColor.newBlack
    titleMeasureLabel.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.titlMeasureContentView.snp.centerY)
      make.left.equalTo(self.iconImageView.snp.right).offset(screenSize.height * (12/iPhoneXHeight))
    }
    
    tableView.snp.makeConstraints { (make) in
      make.top.equalTo(titlMeasureContentView.snp.bottom)
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
  
  func setupChart() {
    
    titleLabel.text = viewModel!.formatedDate()
    leftButton.isHidden = viewModel!.isHiddenLeftRightButton
    rightButton.isHidden = viewModel!.isHiddenLeftRightButton
    
    titleMeasureLabel.text = viewModel!.currentTypeTitle
    let dateRange = viewModel!.selectedDatesRange.isEmpty ? viewModel!.currentWeek! : viewModel!.selectedDatesRange
    setDataCount(days: dateRange, measurements: viewModel!.selectedMeasurements, unit: viewModel!.measureUnits[viewModel!.currentTypeId])
  }
  
  func setDataCount(days: [Date], measurements: [Measurement], unit: String) {
    chartView.chartDescription?.enabled = false
    chartView.dragEnabled = true
    chartView.setScaleEnabled(true)
    chartView.pinchZoomEnabled = true
    chartView.drawBordersEnabled = false
    chartView.drawGridBackgroundEnabled = false
    chartView.delegate = self
    
    // x-axis limit line
    let llXAxis = ChartLimitLine(limit: 10, label: "Index 10")
    llXAxis.lineWidth = 4
    llXAxis.lineDashLengths = [10, 10, 0]
    llXAxis.labelPosition = .bottomRight
    llXAxis.valueFont = .systemFont(ofSize: 10)
    chartView.xAxis.gridLineDashLengths = [10, 10]
    chartView.xAxis.gridLineDashPhase = 0
    chartView.xAxis.labelPosition = .bottom
    let leftAxis = chartView.leftAxis
    leftAxis.removeAllLimitLines()
    if let maxObject = measurements.max(by: { $0.value < $1.value }), let minObject = measurements.min(by: { $0.value > $1.value }) {
      leftAxis.axisMaximum = maxObject.value * 1.05
      leftAxis.axisMinimum = minObject.value * 0.95
    } else {
      leftAxis.axisMaximum = viewModel!.xMaxs[viewModel!.currentTypeId]
      leftAxis.axisMinimum = viewModel!.xMins[viewModel!.currentTypeId]
    }
    leftAxis.drawLimitLinesBehindDataEnabled = true
    chartView.rightAxis.enabled = false
    chartView.legend.form = .line
    chartView.xAxis.valueFormatter = BarChartFormatter(datesRange: days)
    chartView.xAxis.granularity = 1.0
    chartView.animate(xAxisDuration: 1)
    
    
    var values = (0..<days.count).map { (i) -> ChartDataEntry in
      if let index = measurements.firstIndex(where: {NSCalendar.current.isDate(days[i], inSameDayAs: $0.createdDate)}) {
        return ChartDataEntry(x: Double(i), y: measurements[index].value.roundTo(places: 1), data: nil)
      } else {
        if let index = measurements.lastIndex(where: { $0.createdDate < days[i]}) {
          return ChartDataEntry(x: Double(i), y: measurements[index].value.roundTo(places: 1), data: nil)
        }
      }
      return ChartDataEntry(x: Double(i), y: 0, data: nil)
    }
    
    values.sort(by: { $0.x < $1.x })
    
    let set1 = LineChartDataSet(entries: values, label: unit)
    set1.drawIconsEnabled = false
    set1.highlightEnabled = false
    set1.lineDashLengths = nil//[5, 2.5]
    set1.highlightLineDashLengths = nil//[5, 2.5]
    set1.setColor(UIColor(red: 0.34, green: 0.45, blue: 0.60, alpha: 1.00))
    set1.setCircleColor(UIColor(red: 0.34, green: 0.45, blue: 0.60, alpha: 1.00))
    set1.lineWidth = 2
    set1.circleRadius = 7
    set1.drawCirclesEnabled = false
    set1.drawCircleHoleEnabled = true
    set1.valueFont = .systemFont(ofSize: 9)
    set1.formLineDashLengths = nil//[5, 2.5]
    set1.drawValuesEnabled = false
    set1.formLineWidth = 1
    set1.formSize = 15
    
    let gradientColors = [UIColor(red: 0.34, green: 0.45, blue: 0.60, alpha: 1.00).cgColor, UIColor(red: 0.34, green: 0.45, blue: 0.60, alpha: 0.00).cgColor]
    let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
    
    set1.fillAlpha = 1
    set1.fill = Fill(linearGradient: gradient, angle: -90)
    set1.drawFilledEnabled = true
    
    //chartView.data = data
    //chartView.lineData?.addDataSet(set1)
    
    var values2: [ChartDataEntry] = []
    for i in 0..<days.count {
      if let index = measurements.firstIndex(where: {NSCalendar.current.isDate(days[i], inSameDayAs: $0.createdDate)}) {
        values2.append(ChartDataEntry(x: Double(i), y: measurements[index].value.roundTo(places: 1), data: nil))
      }
    }
    
    let set2 = LineChartDataSet(entries: values2, label: unit)
    set2.drawIconsEnabled = false
    set1.highlightEnabled = false
    set2.lineDashLengths = nil//[5, 2.5]
    set2.highlightLineDashLengths = nil//[5, 2.5]
    set2.setColor(.clear)
    set2.setCircleColor(UIColor(red: 0.34, green: 0.45, blue: 0.60, alpha: 1.00))
    set2.lineWidth = 2
    set2.circleRadius = 7
    set2.drawCirclesEnabled = true
    set2.drawCircleHoleEnabled = true
    set2.valueFont = .systemFont(ofSize: 9)
    set2.formLineDashLengths = nil//[5, 2.5]
    set2.drawValuesEnabled = true
    set2.formLineWidth = 1
    set2.formSize = 15
    set2.fillAlpha = 1
    //       set2.fill = Fill(linearGradient: gradient, angle: -90)
    //       set2.drawFilledEnaself.bled = true
    //chartView.lineData?.addDataSet(set2)
    
    let ss = [set1,set2]
    let data = LineChartData(dataSets: ss)
    data.highlightEnabled = false
    chartView.data = data
    
    for set in chartView.data!.dataSets as! [LineChartDataSet] {
      set.mode = (set.mode == .linear) ? .horizontalBezier : .stepped
    }
    chartView.setNeedsDisplay()
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
    setupChart()
    self.tableView.reloadData()
  }
  
  @objc func nextWeekAction(_ sender: UIButton) {
    if !NSCalendar.current.isDate(viewModel!.endDate!, inSameDayAs: Date()) {
      viewModel!.setupCurrentWeekTimeFrame(previous: false, next: true)
      setupChart()
      tableView.reloadData()
    }
  }
  
  func fetchMeasurements() {
    SVProgressHUD.show()
    viewModel!.fetchMeasurements(success: { value in
      SVProgressHUD.dismiss()
      self.setupChart()
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
    return 1
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return viewModel!.heightForRow(indexPath: indexPath)
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel!.numberOfRowInSectionForDataController(section: section)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return viewModel!.measureTypeCell(tableView: tableView, indexPath: indexPath, canSelectButton: true)
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    viewModel!.currentTypeId = indexPath.row
    viewModel!.currentTypeTitle = viewModel!.titles[indexPath.row]
    Analytics.logEvent("measurements_screen", parameters: ["name": viewModel!.currentTypeTitle])
    fetchMeasurements()
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

