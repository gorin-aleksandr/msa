//
//  CalendarViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 8/19/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

protocol MeasurementsCalendarDelegate {
  func selectedDates(dates: [Date])
}

class DateMeasurementsCalendarController: UIViewController {
  
  weak var delegate: TrainingCalendarProtocol?
  var datesDelegate: MeasurementsCalendarDelegate?

  let defaultCalendar: Calendar = {
    var calendar = Calendar.current
    calendar.firstWeekday = 2
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    return calendar
  }()
  
  var calendarView: VACalendarView!
  var days = [TrainingDay]()
  var manager = TrainingManager(type: .my)
  var startRangeDate: Date?
  var endRangeDate: Date?
  var selectedDates: [Date] = []
  
  @objc func backAction(_ sender: Any) {
    back()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Выберите даты"
    configureUI()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    setupCalendarView()
    
    NotificationCenter.default.addObserver(self, selector: #selector(getDate(notification:)), name: NSNotification.Name(rawValue: "dayTapped"), object: nil)
  }
  
  @objc func selectDatesAction() {
    datesDelegate?.selectedDates(dates: selectedDates)
    self.dismiss(animated: true, completion: nil)
  }
  
  @objc
  func getDate(notification: NSNotification) {
    if let date = notification.userInfo?["date"] as? Date {
      print(date)
      if date > Date() {
         return
      }
      if startRangeDate == nil {
        startRangeDate = date
      } else  if endRangeDate == nil {
        endRangeDate = date
        if startRangeDate < endRangeDate {
          selectedDates = startRangeDate!.allDates(till: endRangeDate!)
        }
      } else if startRangeDate != nil && endRangeDate != nil{
        startRangeDate = date
        endRangeDate = nil
        selectedDates = []
      }
      
      if startRangeDate != nil && endRangeDate == nil {
        calendarView.selectDates([date])
      } else if startRangeDate != nil && endRangeDate != nil {
        calendarView.selectDates(selectedDates)
      }
    }
  }
  
  func stringFrom(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyy"
    return formatter.string(from: date)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
      case "showTrainingDay":
        guard let vc = segue.destination as? CircleTrainingDayViewController else {return}
        vc.manager = self.manager
      default:
        return
    }
  }
  
  private func configureUI() {
    navigationController?.setNavigationBarHidden(false, animated: true)
    let attrs = [NSAttributedString.Key.foregroundColor: UIColor.newBlue,
                 NSAttributedString.Key.font: NewFonts.SFProDisplayBold17]
    self.navigationController?.navigationBar.titleTextAttributes = attrs
    
    let rightBarButton = UIBarButtonItem(image: UIImage(named: "ok_blue"), style: .plain, target: self, action: #selector(self.selectDatesAction))
    self.navigationItem.rightBarButtonItem = rightBarButton
    self.navigationController?.navigationBar.tintColor = .newBlack

    let backButton = UIBarButtonItem(image: UIImage(named: "backIcon"), style: .plain, target: self, action: #selector(self.backAction(_:)))
    self.navigationItem.leftBarButtonItem = backButton
    self.navigationController?.navigationBar.tintColor = .newBlack

    
//    var saveButton = UIButton(type: .custom) as UIButton
//    self.view.addSubview(saveButton)
//    saveButton.titleLabel?.font = NewFonts.SFProDisplayBold16
//    saveButton.setTitleColor(UIColor.white, for: .normal)
//    saveButton.setTitle("Сохранить", for: .normal)
//    saveButton.setBackgroundColor(color: UIColor.newBlue, forState: .normal)
//    saveButton.layer.cornerRadius = screenSize.height * (16/iPhoneXHeight)
//    saveButton.layer.masksToBounds = true
//    saveButton.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
//    saveButton.snp.makeConstraints { (make) in
//      make.bottom.equalTo(self.view.snp.bottom).offset(screenSize.height * (-30/iPhoneXHeight))
//      make.left.equalTo(self.view.snp.left)
//      make.right.equalTo(self.view.snp.right)
//      make.height.equalTo(screenSize.height * (54/iPhoneXHeight))
//    }
    
    setCalendarVieW()
    selectCalendarDays()
  //  self.view.bringSubviewToFront(saveButton)
  }
  
  @objc func saveAction(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
  
  private func selectCalendarDays() {
    if let weeks = manager.getCurrentTraining()?.weeks {
      for week in weeks {
        for day in week.days {
          if day.date != "" {
            days.append(day)
          }
        }
      }
      var dates = days.map {$0.date.getDate()!.addingTimeInterval(TimeInterval(exactly: 14400)!)}
      dates.append(Date())
      calendarView.selectDates(days.map {$0.date.getDate()!.addingTimeInterval(TimeInterval(exactly: 14400)!)})
    }
  }
  
  @objc
  func back() {
    self.dismiss(animated: true, completion: nil)
  }
  
  private func setupCalendarView() {
    if calendarView.frame == .zero {
      calendarView.frame = CGRect(
        x: 0,
        y: (self.navigationController?.navigationBar.frame.height ?? 0) + 20,
        width: view.frame.width,
        height: view.frame.height - (self.navigationController?.navigationBar.frame.height ?? 0) - 20
      )
      calendarView.setup()
    }
  }
  
  
  private func setCalendarVieW() {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyy"
    
    let startDate = formatter.date(from: "01.01.2015")!
    let endDate = formatter.date(from: "01.01.2022")!
    
    let calendar = VACalendar(
      startDate: startDate,
      endDate: endDate,
      calendar: defaultCalendar
    )
    calendarView = VACalendarView(frame: .zero, calendar: calendar)
    calendarView.showDaysOut = false
    calendarView.selectionStyle = .multi
    calendarView.dayViewAppearanceDelegate = self
    calendarView.monthViewAppearanceDelegate = self
    calendarView.calendarDelegate = self
    calendarView.scrollDirection = .vertical
    self.view.insertSubview(calendarView, at: 0)
  }
  
}


extension DateMeasurementsCalendarController: VAMonthViewAppearanceDelegate {
  
  func leftInset() -> CGFloat {
    return 10.0
  }
  
  func rightInset() -> CGFloat {
    return 10.0
  }
  
  func verticalMonthTitleFont() -> UIFont {
    return NewFonts.SFProDisplayBold16
  }
  
  func verticalMonthTitleColor() -> UIColor {
    return .newBlue
  }
  
  func verticalCurrentMonthTitleColor() -> UIColor {
    return .newBlue
  }
  
}

extension DateMeasurementsCalendarController: VADayViewAppearanceDelegate {
  
  // Колір цифр
  func textColor(for state: VADayState) -> UIColor {
    switch state {
      case .out:
        return UIColor(red: 214 / 255, green: 214 / 255, blue: 219 / 255, alpha: 1.0)
      case .selected:
        return .white
      case .today:
        return .white
      case .unavailable:
        return .lightGray
      default:
        return .black
    }
  }
  
  // Колір кружечків
  func textBackgroundColor(for state: VADayState) -> UIColor {
    switch state {
      case .selected:
        return .newBlue
      case .today:
        return .lightGREEN
      default:
        return .clear
    }
  }
  
  func shape() -> VADayShape {
    return .circle
  }
  
  func dotBottomVerticalOffset(for state: VADayState) -> CGFloat {
    switch state {
      case .selected, .today:
        return 2
      default:
        return -7
    }
  }
  
}

extension DateMeasurementsCalendarController: VACalendarViewDelegate {
  
  func selectedDate(_ date: Date) {
    print(date)
  }
  
  func selectedDates(_ dates: [Date]) {
    print(dates)
  }
  
}

extension Date {
  
  func allDates(till endDate: Date) -> [Date] {
    var date = self
    var array: [Date] = []
    while date <= endDate {
      array.append(date)
      date = Calendar.current.date(byAdding: .day, value: 1, to: date)!
    }
    return array
  }
}
