//
//  MeasurementsViewController.swift
//  MSA
//
//  Created by Nik on 31.08.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit
import Charts

enum Option {
    case toggleValues
    case toggleIcons
    case toggleHighlight
    case animateX
    case animateY
    case animateXY
    case saveToGallery
    case togglePinchZoom
    case toggleAutoScaleMinMax
    case toggleData
    case toggleBarBorders
    // CandleChart
    case toggleShadowColorSameAsCandle
    case toggleShowCandleBar
    // CombinedChart
    case toggleLineValues
    case toggleBarValues
    case removeDataSet
    // CubicLineSampleFillFormatter
    case toggleFilled
    case toggleCircles
    case toggleCubic
    case toggleHorizontalCubic
    case toggleStepped
    // HalfPieChartController
    case toggleXValues
    case togglePercent
    case toggleHole
    case spin
    case drawCenter
    // RadarChart
    case toggleXLabels
    case toggleYLabels
    case toggleRotate
    case toggleHighlightCircle
    
    var label: String {
        switch self {
        case .toggleValues: return "Toggle Y-Values"
        case .toggleIcons: return "Toggle Icons"
        case .toggleHighlight: return "Toggle Highlight"
        case .animateX: return "Animate X"
        case .animateY: return "Animate Y"
        case .animateXY: return "Animate XY"
        case .saveToGallery: return "Save to Camera Roll"
        case .togglePinchZoom: return "Toggle PinchZoom"
        case .toggleAutoScaleMinMax: return "Toggle auto scale min/max"
        case .toggleData: return "Toggle Data"
        case .toggleBarBorders: return "Toggle Bar Borders"
        // CandleChart
        case .toggleShadowColorSameAsCandle: return "Toggle shadow same color"
        case .toggleShowCandleBar: return "Toggle show candle bar"
        // CombinedChart
        case .toggleLineValues: return "Toggle Line Values"
        case .toggleBarValues: return "Toggle Bar Values"
        case .removeDataSet: return "Remove Random Set"
        // CubicLineSampleFillFormatter
        case .toggleFilled: return "Toggle Filled"
        case .toggleCircles: return "Toggle Circles"
        case .toggleCubic: return "Toggle Cubic"
        case .toggleHorizontalCubic: return "Toggle Horizontal Cubic"
        case .toggleStepped: return "Toggle Stepped"
        // HalfPieChartController
        case .toggleXValues: return "Toggle X-Values"
        case .togglePercent: return "Toggle Percent"
        case .toggleHole: return "Toggle Hole"
        case .spin: return "Spin"
        case .drawCenter: return "Draw CenterText"
        // RadarChart
        case .toggleXLabels: return "Toggle X-Labels"
        case .toggleYLabels: return "Toggle Y-Labels"
        case .toggleRotate: return "Toggle Rotate"
        case .toggleHighlightCircle: return "Toggle highlight circle"
        }
    }
}

class MeasurementsViewController: UIViewController, ChartViewDelegate {
  @IBOutlet var chartView: LineChartView!
  var options: [Option]!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
      }
  func setupUI() {
                self.title = "Line Chart 1"
         self.options = [.toggleValues,
                         .toggleFilled,
                         .toggleCircles,
                         .toggleCubic,
                         .toggleHorizontalCubic,
                         .toggleIcons,
                         .toggleStepped,
                         .toggleHighlight,
                         .animateX,
                         .animateY,
                         .animateXY,
                         .saveToGallery,
                         .togglePinchZoom,
                         .toggleAutoScaleMinMax,
                         .toggleData]
         
         chartView.delegate = self
         
         chartView.chartDescription?.enabled = false
         chartView.dragEnabled = true
         chartView.setScaleEnabled(true)
         chartView.pinchZoomEnabled = true
         chartView.drawBordersEnabled = false
         chartView.drawGridBackgroundEnabled = false

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
         leftAxis.axisMaximum = 80
         leftAxis.axisMinimum = 0
         //leftAxis.gridLineDashLengths = [5, 5]
         leftAxis.drawLimitLinesBehindDataEnabled = true
         
         chartView.rightAxis.enabled = false
         
         //[_chartView.viewPortHandler setMaximumScaleY: 2.f];
         //[_chartView.viewPortHandler setMaximumScaleX: 2.f];

//         let marker = BalloonMarker(color: UIColor(white: 180/255, alpha: 1),
//                                    font: .systemFont(ofSize: 12),
//                                    textColor: .white,
//                                    insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8))
       //  marker.chartView = chartView
       //  marker.minimumSize = CGSize(width: 80, height: 40)
      //   chartView.marker = marker
         
         chartView.legend.form = .line

         
         chartView.animate(xAxisDuration: 2.5)
         setDataCount(7, range: 1)
    //round
    for set in chartView.data!.dataSets as! [LineChartDataSet] {
                  set.mode = (set.mode == .cubicBezier) ? .horizontalBezier : .cubicBezier
              }
              chartView.setNeedsDisplay()
    //
    


  }
  
  func setDataCount(_ count: Int, range: UInt32) {
      let values = (0..<count).map { (i) -> ChartDataEntry in
        let val = Double(Double(arc4random_uniform(range)) + Double(arc4random_uniform(60)))
          return ChartDataEntry(x: Double(i), y: val, icon: nil)
      }
      
      let set1 = LineChartDataSet(entries: values, label: "DataSet 1")
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
  }
  
  func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
    print("Chart value selected!")
  }

}
