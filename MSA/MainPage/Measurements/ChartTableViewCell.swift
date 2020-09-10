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
      make.right.equalTo(self.contentView.snp.right)
      make.left.equalTo(self.contentView.snp.left)
    }
    
   
    
  }
  
  func setDataCount(days: [Date], measurements: [Measurement]) {
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
       chartView.animate(xAxisDuration: 1)

    
    let values = (0..<days.count).map { (i) -> ChartDataEntry in
      var val = 0.0
      for n in 0..<measurements.count {
        print(" den \(days[i])")
        print(" valden \(measurements[n].createdDate)")

        if(NSCalendar.current.isDate(days[i], inSameDayAs: measurements[n].createdDate as Date)){
             val = measurements[0].value
             return ChartDataEntry(x: Double(days[i].day), y: val, data: nil)
        }
        
      }
      
//      if measurements.indices.contains(i) {
//        if days[i] == measurements[0].createdDate {
//          val = measurements[0].value
//          return ChartDataEntry(x: Double(days[i].day), y: val, data: nil)
//        }
//      }
      return ChartDataEntry(x: Double(days[i].day), y: val, data: nil)

    }
    
    
    let set1 = LineChartDataSet(entries: values, label: "кг")
    set1.drawIconsEnabled = false
    
    set1.lineDashLengths = nil//[5, 2.5]
    set1.highlightLineDashLengths = [5, 2.5]
    set1.setColor(UIColor(red: 0.34, green: 0.45, blue: 0.60, alpha: 1.00))
    set1.setCircleColor(UIColor(red: 0.34, green: 0.45, blue: 0.60, alpha: 1.00))
    set1.lineWidth = 2
    set1.circleRadius = 9
    set1.drawCircleHoleEnabled = true
    set1.valueFont = .systemFont(ofSize: 9)
    set1.formLineDashLengths = nil//[5, 2.5]
    set1.formLineWidth = 1
    set1.formSize = 15
    
    let gradientColors = [UIColor(red: 0.34, green: 0.45, blue: 0.60, alpha: 1.00).cgColor, UIColor(red: 0.34, green: 0.45, blue: 0.60, alpha: 0.00).cgColor]
    let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: nil)!
    
    set1.fillAlpha = 1
    set1.fill = Fill(linearGradient: gradient, angle: -90) //.linearGradient(gradient, angle: 90)
    set1.drawFilledEnabled = true
    
    let data = LineChartData(dataSet: set1)
    
    chartView.data = data
    for set in chartView.data!.dataSets as! [LineChartDataSet] {
         set.mode = (set.mode == .cubicBezier) ? .horizontalBezier : .cubicBezier
       }
       chartView.setNeedsDisplay()
  }
}

extension ChartTableViewCell: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return "Понедельник"
    }
}
