//
//  MyTranningsViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 6/10/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import FZAccordionTableView
import SDWebImage

class MyTranningsViewController: UIViewController {

    @IBOutlet weak var tableView: FZAccordionTableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    let manager = TrainingManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        initialViewConfiguration()
        initialDataLoading()
    }

    private func initialDataLoading() {
        manager.initDataSource(dataSource: TrainingsDataSource.shared)
        manager.initView(view: self)
        manager.loadTrainings()
    }
    
     private func initialViewConfiguration() {
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
        manager.setCurrent(training: manager.getTrainings()?.first)
        manager.dataSource?.newTemplate = TrainingTemplate()
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
    
    @objc
    private func startRoundTraining(sender: UIButton) {
        manager.setCurrent(day: manager.getTrainings()?.first?.weeks.first?.days[sender.tag])
        self.performSegue(withIdentifier: "roundTraining", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showExerciseInTraining":
            guard let vc = segue.destination as? IterationsViewController else {return}
            vc.manager = self.manager
        case "showCalendar":
            guard let vc = segue.destination as? CalendarViewController else {return}
            vc.manager = self.manager
        case "createTemplate":
            guard let vc = segue.destination as? CreateTemplateViewController else {return}
            vc.manager = self.manager
        case "roundTraining":
            guard let vc = segue.destination as? CircleTrainingDayViewController else {return}
            vc.manager = self.manager
        default:
            return
        }
    }
}

extension MyTranningsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TrainingDayHeaderView") as? TrainingDayHeaderView else {return nil}
        
        if let day = manager.getTrainings()?.first?.weeks.first?.days[section] {
            headerView.dateLabel.text = day.date
            headerView.dayLabel.text = "День #\(section + 1)"
            headerView.nameLabel.text = day.name
        }
        headerView.sircleTrainingButton.tag = section
        headerView.startTrainingButton.tag = section
        headerView.startTrainingButton.addTarget(self, action: #selector(startTraining(sender:)), for: .touchUpInside)
        headerView.sircleTrainingButton.addTarget(self, action: #selector(startRoundTraining(sender:)), for: .touchUpInside)

        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == (manager.getTrainings()?.first?.weeks.first?.days[indexPath.section].exercises.count ?? 0) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddExerciseToDayTableViewCell", for: indexPath) as? AddExerciseToDayTableViewCell else {return UITableViewCell()}
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseTableViewCell", for: indexPath) as? ExerciseTableViewCell else {return UITableViewCell()}
            if let exercise = manager.getTrainings()?.first?.weeks.first?.days[indexPath.section].exercises[indexPath.row] {
                if let ex = manager.realm.getElement(ofType: Exercise.self, filterWith: NSPredicate(format: "id = %d", exercise.exerciseId)) {
                    cell.exerciseNameLable.text = ex.name
                    cell.exerciseImageView.sd_setImage(with: URL(string: ex.pictures.first?.url ?? ""), placeholderImage: nil, options: .allowInvalidSSLCertificates, completed: nil)
                    
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return manager.getTrainings()?.first?.weeks.first?.days[section].exercises.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return manager.getTrainings()?.first?.weeks.first?.days.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let ex = manager.getTrainings()?.first?.weeks.first?.days[indexPath.section].exercises[indexPath.row] else {return}
        manager.setCurrent(exercise: ex)
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

extension MyTranningsViewController: TrainingsViewDelegate {
    func templatesLoaded() {
        
    }
    
    func templateCreated() {
        
    }
    
    func startLoading() {
        print("Start")
    }
    
    func finishLoading() {
        print("Finish")
    }
    
    func trainingsLoaded() {
        tableView.reloadData()
        manager.loadTemplates()

    }
    
    func errorOccurred(err: String) {
        print("Error")
    }
    
    
}
