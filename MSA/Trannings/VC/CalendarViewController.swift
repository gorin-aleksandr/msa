//
//  CalendarViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 8/19/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

let lightBlue_ = UIColor(red: 72 / 255, green: 157 / 255, blue: 255 / 255, alpha: 1.0)

class CalendarViewController: UIViewController {

    let defaultCalendar: Calendar = {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()
    
    var calendarView: VACalendarView!
    
    @IBAction func backAction(_ sender: Any) {
        back()
    }
    @IBAction func optionsAction(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupCalendarView()
    }
    
    private func configureUI() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.black,
                     NSAttributedStringKey.font: UIFont(name: "Rubik-Medium", size: 17)!]
        self.navigationController?.navigationBar.titleTextAttributes = attrs
        
        setCalendarVieW()
        calendarView.selectDates([Date()])
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
    
//    private func setDatesPlusOneDay(dates: [Date]) {
//        let newDates = dates.map({$0.addingTimeInterval(TimeInterval(86400))})
//        calendarView.selectDates(newDates)
//    }
    
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
        return lightBlue_
    }
    
    func verticalCurrentMonthTitleColor() -> UIColor {
        return lightBlue_
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
            return lightBlue_
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
