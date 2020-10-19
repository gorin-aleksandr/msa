//
//  MeasurementViewModel.swift
//  MSA
//
//  Created by Nik on 08.09.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseFirestore
import Firebase

class Measurement {
  var id: String
  var type: Int
  var value: Double
  var createdDate: Date
  
  init(id: String, type: Int, value: Double, createdDate: Date) {
    self.id = id
    self.type = type
    self.value = value
    self.createdDate = createdDate
  }
}

class MeasurementViewModel {
  
  var titles: [String] = ["Вес","Рост","Подкожный жир","Висцеральный жир","Количество воды","Мышечная масса","Шея","Плечевой пояс","Грудь","Живот","Правая рука","Левая рука", "Ягодицы", "Правое бедро", "Левое бедро"]
  var measureUnits: [String] = ["кг","см","%","%","%","кг","см","см","см","см","см","см", "см", "см", "см"]
  var month: [String] = ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"]
  
  var icons: [String] = ["Frame 2281-2","Frame 2281-1","Frame 2281","Frame 2281-4","Frame 2281-3","Frame 2281-6","Шея","Плечевой пояс","Грудь","Живот","Правая рука","Левая рука","Ягодицы","Правое бедро", "Левое бедро"]
  var selectedIcons: [String] = ["Вес","Рост","Подкожный жир","Висцеральный жир","Количество воды","Мышечная масса","Шея-1","Плечевой пояс-1","Грудь-1","Живот-1","Правая рука-1","Левая рука-1", "Ягодицы-1", "Правое бедро-1", "Левое бедро-1"]
  let db = Firestore.firestore()
  var startDate: Date?
  var endDate: Date?
  var currentWeek: [Date]?
  var currentWeekDay = Date()
  var selectedDatesRange: [Date] = []
  var currentTypeTitle = "Вес"
  var currentTypeId = 0
  var isHiddenLeftRightButton = false
  var selectedUserId = "0"
  var currentMonth = ""
  var newMeasurementsTitle = ""
  var newMeasurementsImage: UIImage?
  var newMeasurementDate = Date()
  var newMeasurementId = 0
  var xMins: [Double] = [30,140,2,2,30,20,30,70,50,50,20,20,50,30,30]
  var xMaxs: [Double] = [200,220,50,50,80,150,50,200,160,160,70,70,200,120,120]
  var selectedMeasurements: [Measurement] = []
  var reloadChart: (() -> ())?
  var xMin = 0.0
  var xMax = 0.0
  
  init() {
    //    try! realm.write {
    //       realm.delete(realm.objects(Measurement.self))
    //    }
    setupCurrentWeekTimeFrame(previous: false, next: false)
    
  }
  func setupCurrentWeekTimeFrame(previous: Bool, next: Bool) {
    if previous {
      startDate = Calendar.current.date(byAdding: .day, value: -14, to: startDate!)!
      endDate = Calendar.current.date(byAdding: .day, value: -14, to: endDate!)!
      currentWeek = Date.dates(from: startDate!, to: endDate!)
    } else if next {
      startDate = Calendar.current.date(byAdding: .day, value: 14, to: startDate!)!
      endDate = Calendar.current.date(byAdding: .day, value: 14, to: endDate!)!
      currentWeek = Date.dates(from: startDate!, to: endDate!)
    } else {
      startDate = Calendar.current.date(byAdding: .day, value: -14, to: currentWeekDay)!
      endDate = Date()
      currentWeek = Date.dates(from: startDate!, to: endDate!)
    }
    
  }
  
  func numberOfRowInSectionForDataController(section: Int) -> Int {
    return titles.count
  }
  
  func fetchMeasurements(success: @escaping (Bool)->()) {
    
    db.collection("Measurements").document(selectedUserId).collection("\(currentTypeId)").order(by: "createdDate", descending: false).getDocuments { querySnapshot, error in
      guard let snapshot = querySnapshot else {
        print("Error fetching snapshots: \(error!)")
        return
      }
      self.selectedMeasurements = []
      
      if snapshot.documentChanges.count == 0 {
        success(true)
      }
      snapshot.documentChanges.forEach { diff in
        let item = diff.document.data()
        let stamp = item["createdDate"] as! Timestamp
        let date = stamp.dateValue()
        print("New value: \(stamp.dateValue()) val =\(item["value"] as! Double)")
        
        let measurement = Measurement(id: diff.document.documentID,type: item["type"] as! Int, value: item["value"] as! Double, createdDate: date)
        print("Date = \(stamp.dateValue())")
        self.selectedMeasurements.append(measurement)
        print(snapshot)
      }
      success(true)
    }
  }
  
  func addRandomMeasurement() {
    
  }
  
  func saveMeasure(value: Double, date: Date) {
    
    if let index = selectedMeasurements.firstIndex(where: {NSCalendar.current.isDate(date, inSameDayAs: $0.createdDate)}) {
      let measurement = selectedMeasurements[index]
      print("Userid = \(selectedUserId)")
      db.collection("Measurements").document(selectedUserId).collection("\(newMeasurementId)").document(measurement.id).updateData([
        "value": value,
        "createdDate": date,
        "type" : newMeasurementId,
        "timeStamp": FieldValue.serverTimestamp()
      ])
    } else {
      db.collection("Measurements").document(selectedUserId).collection("\(newMeasurementId)").addDocument(data: [
        "value": value,
        "createdDate": date,
        "type" : newMeasurementId,
        "timeStamp": FieldValue.serverTimestamp()
      ])
    }
    Analytics.logEvent("add_measurement", parameters: ["name": newMeasurementsTitle])
    reloadChart?()
  }
  
  func numberOfRowInMeasurementTypeController(section: Int) -> Int {
    return titles.count
  }
  
  func heightForRow(indexPath: IndexPath) -> CGFloat {
    return screenSize.height * (78/iPhoneXHeight)
  }
  
  func formatedDate() -> String? {
    
    if  selectedDatesRange.isEmpty {
      let dateStringStart = DateFormatter.sharedDateFormatter.string(from: startDate!)
      let dateStringEnd = DateFormatter.sharedDateFormatter.string(from: endDate!)
      return "\(dateStringStart) - \(dateStringEnd)"
    } else {
      let dateStringStart = DateFormatter.sharedDateFormatter.string(from: selectedDatesRange.first!)
      let dateStringEnd = DateFormatter.sharedDateFormatter.string(from: selectedDatesRange.last!)
      return "\(dateStringStart) - \(dateStringEnd)"
    }
  }
  
  
  func headerCell(tableView: UITableView, indexPath: IndexPath) -> DateMeasurementsTableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "DateMeasurementsTableViewCell") as! DateMeasurementsTableViewCell
    cell.titleLabel.text = formatedDate()
    
    cell.leftButton.isHidden = isHiddenLeftRightButton
    cell.rightButton.isHidden = isHiddenLeftRightButton
    //    if !isHiddenLeftRightButton {
    //      cell.rightButton.isHidden =  NSCalendar.current.isDate(endDate!, inSameDayAs: Date()) ? true : false
    //    }
    
    
    cell.selectionStyle = .none
    return cell
  }
  
  func chartCell(tableView: UITableView, indexPath: IndexPath) -> ChartTableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ChartTableViewCell") as! ChartTableViewCell
    cell.xMin = xMins[currentTypeId]
    cell.xMax = xMaxs[currentTypeId] //selectedMeasurements.map { $0.value }.max()
    let dateRange = selectedDatesRange.isEmpty ? currentWeek! : selectedDatesRange
    cell.setDataCount(days: dateRange, measurements: selectedMeasurements, unit: measureUnits[currentTypeId])
    cell.selectionStyle = .none
    return cell
  }
  
  func measureTitleCell(tableView: UITableView, indexPath: IndexPath) -> MeasureTitleCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "MeasureTitleCell") as! MeasureTitleCell
    cell.titleLabel.text = currentTypeTitle
    cell.selectionStyle = .none
    return cell
  }
  
  func measureTypeCell(tableView: UITableView, indexPath: IndexPath, canSelectButton: Bool) -> MeasureTypeCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "MeasureTypeCell") as! MeasureTypeCell
    
    if canSelectButton {
      cell.iconImageView.image = currentTypeId == indexPath.row ? UIImage(named: selectedIcons[indexPath.row]) : UIImage(named: icons[indexPath.row])
      cell.selectedIconImageView.isHidden = currentTypeId == indexPath.row ? false : true
      
    } else {
      cell.iconImageView.image = UIImage(named: icons[indexPath.row])
      cell.selectedIconImageView.isHidden = true
    }
    
    cell.titleLabel.text = titles[indexPath.row]
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
