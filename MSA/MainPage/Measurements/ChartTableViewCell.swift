//
//  ChartTableViewCell.swift
//  MSA
//
//  Created by Nik on 08.09.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

class ChartTableViewCell: UITableViewCell, ChartViewDelegate {
  @IBOutlet var chartView: LineChartView!
  
  static let identifier = "ChartTableViewCell"
  var xMin = 0.0
  var xMax = 0.0

  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    setupUI()
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func setupUI() {
    //chartView.delegate = self
    
    chartView.snp.makeConstraints { (make) in
      make.top.equalTo(self.contentView.snp.top)
      make.bottom.equalTo(self.contentView.snp.bottom)
      make.right.equalTo(self.contentView.snp.right).offset(screenSize.height * (-16/iPhoneXHeight))
      make.left.equalTo(self.contentView.snp.left).offset(screenSize.height * (16/iPhoneXHeight))
    }
    
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
       leftAxis.axisMaximum = xMax
       leftAxis.axisMinimum = xMin
       leftAxis.drawLimitLinesBehindDataEnabled = true
       chartView.rightAxis.enabled = false
       chartView.legend.form = .line

       chartView.xAxis.valueFormatter = BarChartFormatter(datesRange: days)
       chartView.xAxis.granularity = 1.0
       chartView.animate(xAxisDuration: 1)

    
    var values = (0..<days.count).map { (i) -> ChartDataEntry in
      if let index = measurements.firstIndex(where: {NSCalendar.current.isDate(days[i], inSameDayAs: $0.createdDate)}) {
        return ChartDataEntry(x: Double(i), y: measurements[index].value, data: nil)
      } else {
        if let index = measurements.lastIndex(where: { $0.createdDate < days[i]}) {
          return ChartDataEntry(x: Double(i), y: measurements[index].value, data: nil)
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
        values2.append(ChartDataEntry(x: Double(i), y: measurements[index].value, data: nil))
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
//       set2.drawFilledEnabled = true
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
}
