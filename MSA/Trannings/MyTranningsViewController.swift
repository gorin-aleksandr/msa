//
//  MyTranningsViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 6/10/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import FZAccordionTableView

protocol TrainingsDelegate {
    
}

protocol TrainingsDataSource {
    
}

class MyTranningsViewController: UIViewController {

    @IBOutlet weak var tableView: FZAccordionTableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
//    var days = [TrainingDay]()
    
    var dataSource: TrainingsDataSource?
    var delegate: TrainingsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialViewConfiguration()
    }

    
    func initialViewConfiguration() {
        segmentControl.layer.masksToBounds = true
        segmentControl.layer.cornerRadius = 13
        segmentControl.layer.borderColor = lightBlue.cgColor
        segmentControl.layer.borderWidth = 1
        navigationController?.navigationBar.layer.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1).cgColor
        navigationController?.setNavigationBarHidden(false, animated: true)
        let attrs = [NSAttributedStringKey.foregroundColor: UIColor.black,
                     NSAttributedStringKey.font: UIFont(name: "Rubik-Medium", size: 17)!]
        self.navigationController?.navigationBar.titleTextAttributes = attrs
        segmentControl.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Rubik-Medium", size: 13)!],for: .normal)
        configureTableView()
        
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
//        tableView.separatorColor = .clear
        self.tableView.tableFooterView = UIView()
        tableView.allowMultipleSectionsOpen = true
        tableView.register(UINib(nibName: "TrainingDayHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TrainingDayHeaderView")
        tableView.register(UINib(nibName: "ExerciseTableViewCell", bundle: nil), forCellReuseIdentifier: "ExerciseTableViewCell")
        tableView.register(UINib(nibName: "AddExerciseToDayTableViewCell", bundle: nil), forCellReuseIdentifier: "AddExerciseToDayTableViewCell")
    }
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func optionsButton(_ sender: Any) {
        showOptionsAlert()
    }
    @IBAction func showCalendar(_ sender: Any) {
        self.performSegue(withIdentifier: "showCalendar", sender: nil)
    }
    @IBAction func saveTemplate(_ sender: Any) {
        self.performSegue(withIdentifier: "createTemplate", sender: nil)
    }
    
    func showOptionsAlert() {
        let alert = UIAlertController(title: "Редактирование тренировки", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        let myString  = "Редактирование тренировки"
        var myMutableString = NSMutableAttributedString()
        myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedStringKey.font: UIFont(name: "Rubik-Medium", size: 17)!])
        myMutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black, range: NSRange(location:0,length:myString.count))
        alert.setValue(myMutableString, forKey: "attributedTitle")
        
        let save = UIAlertAction(title: "Сохранить как шаблон", style: .default, handler: { action in
            self.segmentControl.layer.borderColor = lightBlue.cgColor
        })
        let delete = UIAlertAction(title: "Удалить тренировку", style: .default, handler: { action in
            self.segmentControl.layer.borderColor = lightBlue.cgColor
        })
        let cancel = UIAlertAction(title: "Отмена", style: .default, handler: { action in
            self.segmentControl.layer.borderColor = lightBlue.cgColor
        })
        
        alert.addAction(save)
        alert.addAction(delete)
        alert.addAction(cancel)
        segmentControl.layer.borderColor = UIColor.lightGray.cgColor
        self.present(alert, animated: true, completion: nil)
        setFont(action: save, text: "Сохранить как шаблон", regular: true)
        setFont(action: delete, text: "Удалить тренировку", regular: true)
        setFont(action: cancel, text: "Отмена", regular: false)

    }

    private func setFont(action: UIAlertAction,text: String, regular: Bool) {
        var fontName = "Rubik"
        if !regular {
            fontName = "Rubik-Medium"
        }
        let attributedText = NSMutableAttributedString(string: text)
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.addAttribute(kCTFontAttributeName as NSAttributedStringKey, value: UIFont(name: fontName, size: 17.0)!, range: range)
        guard let label = (action.value(forKey: "__representer") as AnyObject).value(forKey: "label") as? UILabel else { return }
        label.attributedText = attributedText
    }
    
    @objc
    private func startTraining(sender: UIButton) {
        
    }
    
}

extension MyTranningsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TrainingDayHeaderView") as? TrainingDayHeaderView else {return nil}
        
//        let day = days[section]
//        headerView.dateLabel.text = day.date
//        headerView.dayLabel.text = "День #\(section)"
//        headerView.nameLabel.text = day.name
        
        headerView.sircleTrainingButton.tag = section
        headerView.startTrainingButton.tag = section
        headerView.startTrainingButton.addTarget(self, action: #selector(startTraining(sender:)), for: .touchUpInside)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 2 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddExerciseToDayTableViewCell", for: indexPath) as? AddExerciseToDayTableViewCell else {return UITableViewCell()}
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseTableViewCell", for: indexPath) as? ExerciseTableViewCell else {return UITableViewCell()}
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return days[section].exercises.count
        return 3
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
//        return days.count
        return 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showExerciseInTraining", sender: nil)
    }
}

extension MyTranningsViewController: FZAccordionTableViewDelegate {
    func tableView(_ tableView: FZAccordionTableView, willOpenSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
        guard let sectionHeader = header as? TrainingDayHeaderView else { return }
        sectionHeader.headerState.toggle()
    }
    func tableView(_ tableView: FZAccordionTableView, willCloseSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
        guard let sectionHeader = header as? TrainingDayHeaderView else { return }
        sectionHeader.headerState.toggle()
    }
}
