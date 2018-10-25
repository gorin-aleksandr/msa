//
//  CalendarViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 8/19/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController {

    let defaultCalendar: Calendar = {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()
    
    var calendarView: VACalendarView!
    var days = [TrainingDay]()
    var manager = TrainingManager(type: .my)
    
    @IBAction func backAction(_ sender: Any) {
        back()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupCalendarView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(getDate(notification:)), name: NSNotification.Name(rawValue: "dayTapped"), object: nil)
    }
    
    @objc
    func getDate(notification: NSNotification) {
        if let date = notification.userInfo?["date"] as? Date {
            for day in days {
                if day.date == stringFrom(date: date) {
                    manager.setWeekFromDay(day: day)
                    navigationController?.popViewController(animated: true)
                }
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
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.darkCyanGreen,
                     NSAttributedStringKey.font: UIFont(name: "Rubik-Medium", size: 17)!]
        self.navigationController?.navigationBar.titleTextAttributes = attrs
        
        setCalendarVieW()
        selectCalendarDays()
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
            calendarView.selectDates(days.map {$0.date.getDate()!.addingTimeInterval(TimeInterval(exactly: 14400)!)})
        }
    }
    
    @objc
    func back() {
        navigationController?.popViewController(animated: true)
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
        let endDate = formatter.date(from: "01.01.2021")!
        
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


extension CalendarViewController: VAMonthViewAppearanceDelegate {
    
    func leftInset() -> CGFloat {
        return 10.0
    }
    
    func rightInset() -> CGFloat {
        return 10.0
    }
    
    func verticalMonthTitleFont() -> UIFont {
        return UIFont.init(name: "Rubik-Medium", size: 15)!
    }
    
    func verticalMonthTitleColor() -> UIColor {
        return lightWhiteBlue
    }
    
    func verticalCurrentMonthTitleColor() -> UIColor {
        return lightWhiteBlue
    }
    
}

extension CalendarViewController: VADayViewAppearanceDelegate {
    
    // Колір цифр
    func textColor(for state: VADayState) -> UIColor {
        switch state {
        case .out:
            return UIColor(red: 214 / 255, green: 214 / 255, blue: 219 / 255, alpha: 1.0)
        case .selected:
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
            return lightWhiteBlue
        default:
            return .clear
        }
    }
    
    func shape() -> VADayShape {
        return .circle
    }
    
    func dotBottomVerticalOffset(for state: VADayState) -> CGFloat {
        switch state {
        case .selected:
            return 2
        default:
            return -7
        }
    }
    
}

extension CalendarViewController: VACalendarViewDelegate {
    
    func selectedDate(_ date: Date) {
        print(date)
    }
    
}
