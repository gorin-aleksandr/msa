//
//  MeasurementViewModel.swift
//  MSA
//
//  Created by Nik on 08.09.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit
import RealmSwift

class Measurement: Object {
  @objc dynamic var unit = ""
  @objc dynamic var type = 0
  @objc dynamic var value = 0.0
  @objc dynamic var createdDate = Date()
}

class MeasurementViewModel {

  var titles: [String] = ["Вес","Рост","Подкожный жир","Висцеральный жир","Количество воды","Мышечная масса","Шея","Плечевой пояс","Грудь","Живот","Правая рука","Левая рука","Живот", "Ягодицы", "Правое бедро", "Левое бедро"]
  var month: [String] = ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]

  var icons: [String] = ["Frame 2281-2","Frame 2281-1","Frame 2281","Frame 2281-4","Frame 2281-3","Frame 2281-6","Шея","Плечевой пояс","Грудь","Живот","Правая рука","Левая рука","Живот","Ягодицы","Правое бедро", "Левое бедро"]
   var selectedIcons: [String] = ["Вес","Рост","Подкожный жир","Висцеральный жир","Количество воды","Мышечная масса","Шея-1","Плечевой пояс-1","Грудь-1","Талия-1","Живот-1","Правая рука-1","Левая рука-1","Живот-1", "Ягодицы-1", "Правое бедро-1", "Левое бедро-1"]
  let realm = try! Realm()
  var startDate: Date?
  var endDate: Date?
  var currentWeek: [Date]?
  var currentTypeTitle = "Вес"
  var currentTypeId = 0
  var currentMonth = ""
  var newMeasurementsTitle = ""
  var newMeasurementsImage: UIImage?
  var newMeasurementDate: Date?

  var newMeasurementId = 0
  var xMins: [Double] = [30,140,2,2,30,20,30,70,50,50,20,50,30]
  var xMax: [Double] = [200,220,50,50,80,150,50,200,160,160,70,200,120]
    
  lazy var measurements: [Measurement] = []
  var selectedMeasurements: [Measurement] = []

  init() {
//    try! realm.write {
//       realm.delete(realm.objects(Measurement.self))
//    }
    setupCurrentTimeFrame()
    
  }
  func setupCurrentTimeFrame() {
    var calendar = Calendar.autoupdatingCurrent
    calendar.firstWeekday = 2 // Start on Monday (or 1 for Sunday)
    let today = calendar.startOfDay(for: Date())
    var week = [Date]()
    if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) {
        for i in 0...6 {
            if let day = calendar.date(byAdding: .day, value: i, to: weekInterval.start) {
                week += [day]
            }
        }
    }
    startDate = week.first
    endDate = week.last
    currentWeek = week
  }
  
  func numberOfRowInSectionForDataController(section: Int) -> Int {
    switch section {
      case 0:
        return 3
      case 1:
        return titles.count
      default:
        return 0
    }
  }
  
  func fetchMeasurements() {
      measurements = realm.objects(Measurement.self).filter({ $0.value != 0 })
      selectedMeasurements = measurements.filter({ $0.type == self.currentTypeId })
  }
  
  func addRandomMeasurement() {
    try! realm.write {
      let newMeasurement = Measurement()
      newMeasurement.value = Double(Double(arc4random_uniform(20)) + Double(arc4random_uniform(60)))
      realm.add(newMeasurement)
    }
  }
  
  func saveMeasure(value: Double, date: Date) {
    try! realm.write {
        let newMeasurement = Measurement()
        newMeasurement.value = value
        newMeasurement.createdDate = date
        newMeasurement.type = newMeasurementId
        realm.add(newMeasurement)
      }
  }
  
  func numberOfRowInMeasurementTypeController(section: Int) -> Int {
    return titles.count
  }
  
  func heightForRow(indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 0 {
      switch indexPath.row {
        case 0:
        return screenSize.height * (60/iPhoneXHeight)
        case 1:
          return screenSize.height * (306/iPhoneXHeight)
        case 2:
          return screenSize.height * (40/iPhoneXHeight)
        default:
        return screenSize.height * (60/iPhoneXHeight)
      }
    } else {
      return screenSize.height * (78/iPhoneXHeight)
    }

  }
  
  func formatedDate() -> String? {
    let dateStringStart = DateFormatter.sharedDateFormatter.string(from: startDate!)
    let dateStringEnd = DateFormatter.sharedDateFormatter.string(from: endDate!)
    return "\(dateStringStart) - \(dateStringEnd)"
  }
  

  func headerCell(tableView: UITableView, indexPath: IndexPath) -> DateMeasurementsTableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "DateMeasurementsTableViewCell") as! DateMeasurementsTableViewCell
    cell.titleLabel.text = formatedDate()
    cell.selectionStyle = .none
    return cell
  }
  
  func chartCell(tableView: UITableView, indexPath: IndexPath) -> ChartTableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ChartTableViewCell") as! ChartTableViewCell
    if measurements.count != 0 {
      cell.xMin = xMins[currentTypeId]
      cell.xMax = xMax[currentTypeId]
      cell.setDataCount(days: currentWeek!, measurements: selectedMeasurements)
    }
    cell.selectionStyle = .none
    return cell
  }
  
  func measureTitleCell(tableView: UITableView, indexPath: IndexPath) -> MeasureTitleCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "MeasureTitleCell") as! MeasureTitleCell
    cell.titleLabel.text = currentTypeTitle
    cell.selectionStyle = .none
    return cell
  }
  
  func measureTypeCell(tableView: UITableView, indexPath: IndexPath) -> MeasureTypeCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "MeasureTypeCell") as! MeasureTypeCell
    cell.iconImageView.image = currentTypeId == indexPath.row ? UIImage(named: selectedIcons[indexPath.row]) : UIImage(named: icons[indexPath.row])
    cell.titleLabel.text = titles[indexPath.row]
    cell.selectedIconImageView.isHidden = currentTypeId == indexPath.row ? false : true
    
    cell.selectionStyle = .none
    return cell
  }
  
}

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}

extension DateFormatter {

    static var sharedDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.YY"
        return dateFormatter
    }()
}


extension String {
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
}
