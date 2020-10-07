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
import AudioToolbox
import SVProgressHUD
import Firebase
import SwiftRater

class MyTranningsViewController: UIViewController {

  
  
  @IBOutlet weak var barStackView: UIView!
  
  @IBOutlet weak var weekHeaderView: UIView!
  @IBOutlet weak var loadingView: UIView!
  @IBOutlet weak var tableView: FZAccordionTableView!
  @IBOutlet weak var weekLabel: UILabel!
  @IBOutlet weak var segmentControl: UISegmentedControl!
  @IBOutlet weak var nextWeekButton: UIButton!
  @IBOutlet weak var prevWeekButton: UIButton!
  @IBOutlet weak var addDayView: UIView! {
    didSet {
      addDayView.isHidden = true
      addDayView.layer.cornerRadius = 12
    }
  }
  var mainAddWeekDayView: addWeekDayView!
  var rightBarButtonStackView: UIView!
  
  private var tap: TapGesture!
  private var longPressRecognizer: UILongPressGestureRecognizer!
  private var copyWeekRecognizer: UILongPressGestureRecognizer!
  
  private let refreshControl = UIRefreshControl()
  
  var manager = TrainingManager(type: .my)
  var weekNumber = 0
  var showDeleteDayButton = false
  var trainingsShown = false
  var comunityPresenter: CommunityListPresenterProtocol!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    comunityPresenter = CommunityListPresenter(view: self)
    rightBarButtonStackView = barStackView
    longPressRecognizer = UILongPressGestureRecognizer(target: self, action:  #selector(longPressed))
    copyWeekRecognizer = UILongPressGestureRecognizer(target: self, action:  #selector(copyWeek))
    self.tableView.addGestureRecognizer(longPressRecognizer)
    self.weekHeaderView.addGestureRecognizer(copyWeekRecognizer)
    if manager.sportsmanId == AuthModule.currUser.id {
      AuthModule.isLastUserCurrent = true
      tableView.bounces = true
    } else {
      AuthModule.isLastUserCurrent = false
      tableView.bounces = false
    }
    weekLabel.addObserver(self, forKeyPath: "text", options: [.old, .new], context: nil)

  }
  
  
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "text" {
      if let value = change?[.newKey] as? String {
        if value == "Укажите название недели" || value == "" {
          weekLabel.textColor = .placeholderLightGrey
        } else {
          weekLabel.textColor = .darkCyanGreen
        }
        if weekLabel.text == "" {
          weekLabel.text = "Укажите название недели"
        }
      }
    }
  }
  
  @objc
  private func finishEditMode() {
    self.tableView.isEditing = false
    self.tableView.addGestureRecognizer(longPressRecognizer)
    self.navigationItem.rightBarButtonItem = nil
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButtonStackView)
  }
  
  @objc func longPressed(sender: UILongPressGestureRecognizer) {
    if sender.state == .began {
      if !self.tableView.isEditing {
        self.tableView.isEditing = true
        self.navigationItem.rightBarButtonItem = nil
        let button1 = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(finishEditMode))
        button1.title = "Done"
        let attrs = [NSAttributedString.Key.foregroundColor: darkCyanGreen,
                     NSAttributedString.Key.font: UIFont(name: "Rubik-Medium", size: 17)!]
        button1.setTitleTextAttributes(attrs, for: .normal)
        self.navigationItem.rightBarButtonItem  = button1
      }
    } else if sender.state == .ended {
      self.tableView.removeGestureRecognizer(longPressRecognizer)
    }
  }
  
  func snapshotOfCell(inputView: UIView) -> UIView {
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
    inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    let cellSnapshot = UIImageView(image: image)
    cellSnapshot.layer.masksToBounds = false
    cellSnapshot.layer.cornerRadius = 0.0
    cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
    cellSnapshot.layer.shadowRadius = 5.0
    cellSnapshot.layer.shadowOpacity = 0.4
    return cellSnapshot
  }
  
  @objc func copyWeek(sender: UILongPressGestureRecognizer) {
    if sender.state == .began {
      AudioServicesPlaySystemSound(1519)
      let alertController = UIAlertController(title: "Внимание!", message: "Ты хочешь скопировать неделю?", preferredStyle: .alert)
      let yesAction = UIAlertAction(title: "Да", style: .cancel) { (action) in
        CopyTrainingsManager.shared.copiedWeek = self.manager.dataSource?.currentWeek
        self.mainAddWeekDayView.insertButton.backgroundColor = .lightGREEN
        self.showHideButtons()
      }
      let cancelAction = UIAlertAction(title: "Отменить", style: .default) { _ in }
      
      alertController.addAction(cancelAction)
      alertController.addAction(yesAction)
      self.present(alertController, animated: true, completion: nil)
    }
  }
  
  @objc func copyDay(sender: UILongPressGestureRecognizer) {
    guard let index = sender.view?.tag else {return}
    if sender.state == .began {
      
      AudioServicesPlaySystemSound(1519)
      
      let alertController = UIAlertController(title: "Внимание!", message: "Ты хочешь скопировать \(index+1) день?", preferredStyle: .alert)
      let yesAction = UIAlertAction(title: "Да", style: .cancel) { (action) in
        CopyTrainingsManager.shared.copiedDay = self.manager.dataSource?.currentWeek?.days[index]
        //self.manager.copyDay(at: index)
        self.mainAddWeekDayView.insertButton.backgroundColor = .lightGREEN
        self.tableView.reloadData()
      }
      let cancelAction = UIAlertAction(title: "Отменить", style: .default) { _ in }
      
      alertController.addAction(cancelAction)
      alertController.addAction(yesAction)
      self.present(alertController, animated: true, completion: nil)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    initialDataLoading()
    initialViewConfiguration()
    Analytics.logEvent("opening_training_screen", parameters: nil)
  }
  
  private func initialDataLoading() {
    manager.initDataSource(dataSource: TrainingsDataSource.shared)
    manager.initView(view: self)
    setData()
  }
  
  private func setData() {
    if manager.sportsmanId == AuthModule.currUser.id {
      manager.loadTrainingsFromRealm()
      manager.syncUnsyncedTrainings()
    } else {
      self.navigationItem.title = "Тренировки спортсмена"
      manager.loadTrainings()
      manager.getMyExercises(success: nil)
    }
  }
  
  private func initialViewConfiguration() {
    loadingView.isHidden = true
    segmentControl.layer.masksToBounds = true
    segmentControl.layer.cornerRadius = 13
    segmentControl.layer.borderColor = lightWhiteBlue.cgColor
    segmentControl.layer.borderWidth = 1
    navigationController?.navigationBar.layer.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1).cgColor
    navigationController?.setNavigationBarHidden(false, animated: true)
    let attrs = [NSAttributedString.Key.foregroundColor: darkCyanGreen,
                 NSAttributedString.Key.font: UIFont(name: "Rubik-Medium", size: 14)!]
    self.navigationController?.navigationBar.titleTextAttributes = attrs
    segmentControl.setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "Rubik-Medium", size: 13)!],for: .normal)
    refreshControl.attributedTitle = NSAttributedString(string: "Синхронизация тренировки ...", attributes: attrs)
    configureTableView()
    showHideButtons()
  }
  
  private func showHideButtons() {
    if weekNumber == 0 {
      prevWeekButton.alpha = 0
    } else {
      prevWeekButton.alpha = 1
    }
    if weekNumber == (manager.dataSource?.currentTraining?.weeks.count ?? 1) - 1 {
      nextWeekButton.alpha = 0
    } else {
      nextWeekButton.alpha = 1
    }
  }
  
  private func configureTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView.showsVerticalScrollIndicator = false
    self.tableView.tableFooterView = UIView()
    tableView.allowMultipleSectionsOpen = false
    
    tableView.register(UINib(nibName: "TrainingDayHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TrainingDayHeaderView")
    tableView.register(UINib(nibName: "addWeekDayView", bundle: nil), forHeaderFooterViewReuseIdentifier: "addWeekDayView")
    tableView.register(UINib(nibName: "ExerciseTableViewCell", bundle: nil), forCellReuseIdentifier: "ExerciseTableViewCell")
    tableView.register(UINib(nibName: "AddExerciseToDayTableViewCell", bundle: nil), forCellReuseIdentifier: "AddExerciseToDayTableViewCell")
    tableView.register(UINib(nibName: "CreateExerciseTableViewCell", bundle: nil), forCellReuseIdentifier: "CreateExerciseTableViewCell")
    if #available(iOS 10.0, *) {
      tableView.refreshControl = refreshControl
    } else {
      tableView.addSubview(refreshControl)
    }
    refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    
    if manager.dataSource?.currentTraining?.weeks.count == nil {
      self.refreshControl.beginRefreshing()
      self.view.isUserInteractionEnabled = false
    }
  }
  
  @objc private func refreshData(_ sender: Any) {
    manager.synchronizeTrainingsData(success: {
      self.tableView.reloadData()
      self.refreshControl.endRefreshing()
    }, failture: {
      AlertDialog.showAlert("Ошибка синхронизации тренировок!", message: "Проверьте интернет соединение!", viewController: self, dismissed: {
        self.refreshControl.endRefreshing()
      })
    })
  }
  
  @objc func handleTap(sender: TapGesture) {
    let destinationVC = UIStoryboard(name: "Trannings", bundle: .main).instantiateViewController(withIdentifier: "ExercisesInfoViewController") as! ExercisesInfoViewController
    guard  let indexPath = sender.indexPath else {
      return
    }
    let ex = manager.getExercisesOf(day: indexPath.section)[indexPath.row]
    destinationVC.execise = manager.realm.getElement(ofType: Exercise.self, filterWith: NSPredicate(format: "id = %@", ex.exerciseId)) ?? nil
    self.navigationController?.pushViewController(destinationVC, animated: true)
  }
  
  @IBAction func back(_ sender: Any) {
    if manager.sportsmanId != AuthModule.currUser.id {
      SVProgressHUD.show()
      manager.editTraining(wiht:  manager.getCurrentTraining()?.id ?? -1, success: { [weak self] in
        guard let self = self else {return}
        DispatchQueue.main.async { [weak self] in
          guard let self = self else {return}
          RealmManager.shared.clearTrainings()
          self.manager.clearRealm()
          SVProgressHUD.dismiss()
          self.navigationController?.popViewController(animated: true)
        }
      }) { [weak self] (error) in
        guard let self = self else {return}
        DispatchQueue.main.async { [weak self] in
          guard let self = self else {return}
          RealmManager.shared.clearTrainings()
          SVProgressHUD.dismiss()
          AlertDialog.showAlert("Error", message: "\(error?.localizedDescription ?? "")", viewController: self)
        }
      }
    } else {
      self.navigationController?.popViewController(animated: true)
    }
  }
  @IBAction func optionsButton(_ sender: Any) {
    showOptionsAlert(addDayWeek: false)
  }
  @IBAction func showCalendar(_ sender: Any) {
    self.performSegue(withIdentifier: "showCalendar", sender: nil)
  }
  @IBAction func saveTemplate(_ sender: Any) {
    showOptionsAlert(addDayWeek: true)
  }
  @IBAction func previousWeek(_ sender: Any) {
    if weekNumber != 0 {
      weekNumber -= 1
      changeWeek()
    }
    showHideButtons()
  }
  @IBAction func nextWeek(_ sender: Any) {
    guard let weekCount = manager.getCurrentTraining()?.weeks.count else {return}
    if weekCount != 0 && weekNumber != weekCount - 1 {
      weekNumber += 1
      changeWeek()
    }
    showHideButtons()
  }
  @IBAction func renameWeek(_ sender: Any) {
    guard let weekCount = manager.getCurrentTraining()?.weeks.count, weekCount != 0 else {return}
    
    let alert = UIAlertController(title: "Новое название", message: "Введите новое название для недели", preferredStyle: UIAlertController.Style.alert)
    
    let action = UIAlertAction(title: "Подтвердить", style: .default) { (alertAction) in
      let textField = alert.textFields![0] as UITextField
      self.manager.renameWeek(name: textField.text)
      self.changeWeek()
    }
    let action2 = UIAlertAction(title: "Отменить", style: .default) { (alertAction) in }
    
    alert.addTextField { (textField) in
      textField.tag = 999
      textField.delegate = self
      textField.placeholder = "Введите название недели"
      if let name = self.manager.dataSource?.currentWeek?.name {
        textField.text = name
      }
    }
    
    alert.addAction(action)
    alert.addAction(action2)
    self.present(alert, animated: true, completion: nil)
  }
  
  func showAddDayWeekAlert() {
    let alert = UIAlertController(title: "Редактирование тренировки", message: "", preferredStyle: UIAlertController.Style.alert)
    
    let myString  = "Редактирование тренировки"
    var myMutableString = NSMutableAttributedString()
    myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font: UIFont(name: "Rubik-Medium", size: 17)!])
    myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location:0,length:myString.count))
    alert.setValue(myMutableString, forKey: "attributedTitle")
  }
  
  func saveTemplate() {
    manager.setCurrent(training: manager.getTrainings()?.first)
    manager.dataSource?.newTemplate = TrainingTemplate()
    self.performSegue(withIdentifier: "createTemplate", sender: nil)
  }
  
  func deleteTraining() {
    manager.deleteTraining(with: "\(manager.dataSource?.currentTraining?.id ?? -1)")
  }
  
  @objc
  func addWeekDayButtonAction(_ sender: UIButton) {
    showOptionsAlert(addDayWeek: true)
  }
  @objc
  func insertDayWeekButtonAction(_ sender: UIButton) {
    if  CopyTrainingsManager.shared.copiedDay != nil {
      self.manager.insertNewDay()
      self.mainAddWeekDayView.insertButton.backgroundColor = .lightGray
    } else if CopyTrainingsManager.shared.copiedWeek != nil {
      self.manager.insertNewWeek()
      self.mainAddWeekDayView.insertButton.backgroundColor = .lightGray
    } else {
      showNoInsert()
    }
    self.tableView.reloadData()
    self.changeWeek()
    
  }
  func showOptionsAlert(addDayWeek: Bool) {
    let alert = UIAlertController(title: "Редактирование тренировки", message: "", preferredStyle: UIAlertController.Style.alert)
    
    let myString  = "Редактирование тренировки"
    var myMutableString = NSMutableAttributedString()
    myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font: UIFont(name: "Rubik-Medium", size: 17)!])
    myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: NSRange(location:0,length:myString.count))
    alert.setValue(myMutableString, forKey: "attributedTitle")
    
    let firstAction = UIAlertAction(title: "Сохранить как шаблон", style: .default, handler: { action in
      if InAppPurchasesService.shared.currentSubscription == nil && self.manager.dataSource?.currentTraining?.weeks.count > 3 {
          let destinationVC = UIStoryboard(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "IAPViwController") as! IAPViewController
          destinationVC.presenter = self.comunityPresenter.createIAPPresenter(for: destinationVC)
          self.present(destinationVC, animated: true, completion: nil)        
      } else {
        self.segmentControl.layer.borderColor = lightWhiteBlue.cgColor
         if addDayWeek {
           self.addWeek()
           Analytics.logEvent("creating_training_week", parameters: nil)
         } else {
           self.saveTemplate()
         }
      }
 
    })
    let secondAction = UIAlertAction(title: "Удалить все тренировки", style: .default, handler: { action in
      self.segmentControl.layer.borderColor = lightWhiteBlue.cgColor
      if addDayWeek {
        self.addDay()
        Analytics.logEvent("creating_training_day", parameters: nil)
      } else {
        self.showDeleteTrainingsAlert()
      }
    })
    let thirdAction = UIAlertAction(title: "Удалить неделю", style: .default, handler: { action in
      self.segmentControl.layer.borderColor = lightWhiteBlue.cgColor
      self.showDeleteWeekAlert()
    })
    
    let fourthAction = UIAlertAction(title: showDeleteDayButton ? "Завершить удаление" : "Удалить день", style: .default, handler: { action in
      self.segmentControl.layer.borderColor = lightWhiteBlue.cgColor
      self.showDeleteDayButton = !self.showDeleteDayButton
      self.tableView.reloadData()
    })
    
    let cancel = UIAlertAction(title: "Отмена", style: .cancel, handler: { action in
      self.segmentControl.layer.borderColor = lightWhiteBlue.cgColor
    })
    if addDayWeek {
      alert.addAction(firstAction)
    }
    if manager.isMyProfile() || addDayWeek {
      alert.addAction(secondAction)
    }
    if !addDayWeek {
      alert.addAction(thirdAction)
      alert.addAction(fourthAction)
    }
    
    alert.addAction(cancel)
    segmentControl.layer.borderColor = UIColor.lightGray.cgColor
    self.present(alert, animated: true, completion: nil)
    if addDayWeek {
      setFont(action: firstAction, text: "Добавить неделю", regular: true)
      setFont(action: secondAction, text: "Добавить день", regular: true)
    } else {
      setFont(action: firstAction, text: "Сохранить как шаблон", regular: true)
      setFont(action: secondAction, text: "Удалить все тренировки", regular: true)
    }
    setFont(action: cancel, text: "Отмена", regular: false)
  }
  
  
  
  private func setFont(action: UIAlertAction,text: String, regular: Bool) {
    var fontName = "Rubik"
    if !regular {
      fontName = "Rubik-Medium"
    }
    let attributedText = NSMutableAttributedString(string: text)
    let range = NSRange(location: 0, length: attributedText.length)
    attributedText.addAttribute(kCTFontAttributeName as NSAttributedString.Key, value: UIFont(name: fontName, size: 17.0)!, range: range)
    guard let label = (action.value(forKey: "__representer") as AnyObject).value(forKey: "label") as? UILabel else { return }
    label.attributedText = attributedText
  }
  
  func deleteWeek() {
    manager.deleteWeek(at: weekNumber)
    setData()
  }
  
  func addDay() {
    SwiftRater.incrementSignificantUsageCount()
    
    guard let week = manager.dataSource?.currentWeek else {
      AlertDialog.showAlert("Нельзя добавить день!", message: "Сначала добавьте неделю", viewController: self)
      return
    }
    manager.addDay(week: week)
    tableView.reloadData()
    let section = (manager.dataSource?.currentWeek?.days.count ?? 1) - 1
    tableView.toggleSection(section)
  }
  
  func addWeek() {
    SwiftRater.incrementSignificantUsageCount()

    if let training = manager.dataSource?.currentTraining {
      manager.createWeak(in: training)
    } else {
      let training = Training()
      training.id = training.incrementID()
      training.name = "Новая тренировка"
      manager.realm.saveObject(training)
      manager.createWeak(in: training)
    }
    weekNumber = (manager.dataSource?.currentTraining?.weeks.count ?? 0) - 1
    changeWeek()
    tableView.toggleSection(0)
  }
  
  private func prepareForStrtTraining(completion: @escaping ()->()) {
    let info = manager.isEmptyExercise()
    if info.0 {
      let array = (info.1)!.map{String($0+1)}
      let joined = array.joined(separator: ", ")
      AlertDialog.showAlert("Ты не можешь начать тренировку!", message: "В упражнениях №\(joined) не добавнены подходы.", viewController: self)
    } else {
      completion()
    }
  }
  
  @objc
  private func startTraining(sender: UIButton) {
    manager.setCurrent(day: manager.dataSource?.currentWeek?.days[sender.tag])
    guard let day = manager.getCurrentday() else {
      return
    }
    var round = true
    if (day.roundExercisesIds.isEmpty) || (day.roundExercisesIds.first?.id == "") {
      round = false
    } else {
      round = true
    }
    switch round {
      case true:
        manager.setState(state: .round)
        manager.setSpecialIterationsForRound(indexes: self.selectedElements().1, completion: {})
      case false:
        manager.setState(state: .normal)
        manager.setIterationsForNormal()
    }
    
    if manager.getCurrentday()?.exercises.count != 0 {
      prepareForStrtTraining {
        self.performSegue(withIdentifier: "roundTraining", sender: nil)
      }
    } else {
      AlertDialog.showAlert("Ты не можешь начать тренировку!", message: "Сначала добавьте упражнения", viewController: self)
    }
  }
  
  @objc
  private func startRoundTraining(sender: UIButton) {
    manager.setCurrent(day: manager.dataSource?.currentWeek?.days[sender.tag])
    manager.setState(state: .round)
    if manager.getCurrentday()?.exercises.count != 0 {
      prepareForStrtTraining {
        self.performSegue(withIdentifier: "chooseExercisesForRoundTraining", sender: nil)
      }
    } else {
      AlertDialog.showAlert("Ты не можешь настроить тренировку!", message: "Сначала добавьте упражнения", viewController: self)
    }
  }
  
  @objc
  private func changeDate(sender: UIButton) {
    manager.setCurrent(day: manager.dataSource?.currentWeek?.days[sender.tag])
    datePickerTapped()
  }
  
  func datePickerTapped() {
    
    DatePickerDialog(buttonColor: lightBlue_).show("Выбери дату", doneButtonTitle: "Выбрать", cancelButtonTitle: "Отменить", datePickerMode: .date) {
      (date, int) -> Void in
      if let dt = date {
        let data = nowDateStringForCalendar(date: date!)
        let allDates =  self.manager.getAllDates()
        if allDates.contains(data) && int == "1" {
          let alert = UIAlertController(title: "Ошибка", message: "Тренировка в указанный день уже существует", preferredStyle: .alert)
          let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            self.datePickerTapped()
          }
          alert.addAction(okAction)
          self.present(alert, animated: true)
        } else {
          let formatter = DateFormatter()
          formatter.dateFormat = "dd.MM.yyyy"
          try! self.manager.realm.performWrite {
            if int == "2" {
              self.manager.dataSource?.currentDay?.date = ""
            } else if int == "1" {
              self.manager.dataSource?.currentDay?.date = formatter.string(from: dt)
            }
            self.manager.editTraining(wiht: self.manager.getCurrentTraining()?.id ?? -1, success: {})
          }
          self.tableView.reloadData()
        }
      }
    }
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
      case "showExerciseInTraining":
        guard let vc = segue.destination as? IterationsViewController else {return}
        vc.manager = self.manager
      case "showCalendar":
        guard let vc = segue.destination as? CalendarViewController else {return}
        vc.manager = self.manager
        vc.delegate = self
      case "createTemplate":
        guard let vc = segue.destination as? CreateTemplateViewController else {return}
        vc.manager = self.manager
      case "roundTraining":
        guard let vc = segue.destination as? CircleTrainingDayViewController else {return}
        vc.manager = self.manager
        vc.manager.trainedIterationsIDS.removeAll()
      case "chooseExercisesForRoundTraining":
        guard let vc = segue.destination as? MultipleChoicesViewController else {return}
        vc.delegate = self
        vc.dataSource = self
        vc.manager = self.manager
      
      case "addExercise":
        guard let vc = segue.destination as? ExercisesViewController else {return}
        vc.trainingManager = self.manager
      default:
        return
    }
  }
  
  func setupFirstWeek() {
    var dates: [Date] = []
    if let name = manager.dataSource?.currentWeek?.name {
      weekLabel.text = name
    }
    for training in manager.dataSource!.trainings {
      for weekq in training.weeks {
        for day in weekq.days {
          print("DAY: \(day.date)")
          if let getDate = day.date.getDate() {
            dates.append(getDate)
          }
        }
        print("Weeks: \(weekq)")
      }
      
      for weekq in training.weeks {
        for day in weekq.days {
          if day.date == nowDateStringForCalendar(date:Date()) {
            print("Dat = \(day.date) Week id = \(weekq.id)")
            let trId = training.weeks.index(of: weekq)!
            print("ttt: \(training.weeks)")
            manager.dataSource?.currentWeek = manager.dataSource?.currentTraining?.weeks[trId]
            weekNumber = trId
            return
          }
        }
      }
      
      if let closestDate = dates.sorted().last(where: {$0.timeIntervalSinceNow < 0}) {
        print(closestDate.description(with: .current))
        for weekq in training.weeks {
          for day in weekq.days {
            if day.date == nowDateStringForCalendar(date:closestDate) {
              let trId = training.weeks.index(of: weekq)!
              print("ttt: \(training.weeks)")
              manager.dataSource?.currentWeek = manager.dataSource?.currentTraining?.weeks[trId]
              weekNumber = trId
              return
            }
          }
        }
      }
    }
  }
  
  func changeWeek() {
    if let weeks = manager.dataSource?.currentTraining?.weeks, !weeks.isEmpty {
      if weeks.count <= weekNumber {
        manager.dataSource?.currentWeek = manager.dataSource?.currentTraining?.weeks.last
        weekNumber = (manager.dataSource?.currentTraining?.weeks.count ?? 1) - 1
      } else if let week = manager.dataSource?.currentTraining?.weeks[weekNumber] {
        manager.dataSource?.currentWeek = week
      } else {
        manager.dataSource?.currentWeek = manager.dataSource?.currentTraining?.weeks.last
      }
      
      
      if let name = manager.dataSource?.currentWeek?.name {
        weekLabel.text = name
      } else {
        weekLabel.text = "#\(weekNumber+1) Неделя"
      }
      nextWeekButton.isHidden = false
      prevWeekButton.isHidden = false
      if weekNumber == manager.dataSource?.currentTraining?.weeks.count ?? 1 {
        nextWeekButton.isHidden = true
      }
    } else {
      weekLabel.text = "Сначала добавьте неделю"
      nextWeekButton.isHidden = true
      prevWeekButton.isHidden = true
    }
    showHideButtons()
    self.tableView.reloadData()
  }
  
  private func showDeleteTrainingsAlert() {
    let alertController = UIAlertController(title: "Внимание!", message: "Ты уверен(а), что хочешь удалить все созданные тренировки?", preferredStyle: .alert)
    let yesAction = UIAlertAction(title: "Удалить", style: .destructive) { (action) in
      self.deleteTraining()
    }
    let cancelAction = UIAlertAction(title: "Отменить", style: .default) { (action) in }
    alertController.addAction(cancelAction)
    alertController.addAction(yesAction)
    self.present(alertController, animated: true, completion: nil)
  }
  private func showDeleteWeekAlert() {
    let alertController = UIAlertController(title: "Внимание!", message: "Ты уверен(а), что хочешь удалить все упражнения в неделе?", preferredStyle: .alert)
    let yesAction = UIAlertAction(title: "Удалить", style: .destructive) { (action) in
      self.deleteWeek()
    }
    let cancelAction = UIAlertAction(title: "Отменить", style: .default) { (action) in }
    alertController.addAction(cancelAction)
    alertController.addAction(yesAction)
    self.present(alertController, animated: true, completion: nil)
  }
  
  private func showNoInsert() {
    let alert = UIAlertController(title: "Ошибка", message: "Для копирования тренировочного дня/недели нажми и удерживай ячейку дня или название недели", preferredStyle: .alert)
    let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
    alert.addAction(okAction)
    present(alert, animated: true)
  }
  
  @objc func showDeleteDayAlert(sender: UIButton) {
    let alertController = UIAlertController(title: "Внимание!", message: "Ты уверен(а), что хочешь удалить день?", preferredStyle: .alert)
    let yesAction = UIAlertAction(title: "Удалить", style: .destructive) { (action) in
      self.manager.deleteDay(at: sender.tag)
      self.showHideButtons()
      self.setData()
    }
    let cancelAction = UIAlertAction(title: "Отменить", style: .default) { (action) in }
    alertController.addAction(cancelAction)
    alertController.addAction(yesAction)
    self.present(alertController, animated: true, completion: nil)
  }
  
  private func replaceExercisesAlert(of day: Int, from index: Int, to day_: Int, at index_: Int) {
    let alertController = UIAlertController(title: "Внимание!", message: "Изменение порядка приведет к отключению настройки режима круговой тренировки", preferredStyle: .alert)
    let yesAction = UIAlertAction(title: "Ok", style: .destructive) { (action) in
      self.manager.replaceExercises(of: day, from: index, to: day_, at: index_)
      self.tableView.reloadData()
    }
    let cancelAction = UIAlertAction(title: "Отменить", style: .default) { (action) in
      self.tableView.reloadData()
    }
    
    alertController.addAction(cancelAction)
    alertController.addAction(yesAction)
    self.present(alertController, animated: true, completion: nil)
  }
  
}

extension MyTranningsViewController: UITableViewDelegate, UITableViewDataSource {
  
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let daysCount = manager.dataSource?.currentWeek?.days.count ?? 0
    if section == daysCount {
      guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "addWeekDayView") as? addWeekDayView else {return nil}
      headerView.butt.addTarget(self, action: #selector(addWeekDayButtonAction(_:)), for: .touchUpInside)
      headerView.insertButton.addTarget(self, action: #selector(insertDayWeekButtonAction(_:)), for: .touchUpInside)
      mainAddWeekDayView = headerView
      if  CopyTrainingsManager.shared.copiedDay != nil {
        self.mainAddWeekDayView.insertButton.backgroundColor = .lightGREEN
      } else if CopyTrainingsManager.shared.copiedWeek != nil {
        self.mainAddWeekDayView.insertButton.backgroundColor = .lightGREEN
      } else {
        self.mainAddWeekDayView.insertButton.backgroundColor = .lightGray
      }
      return headerView
    } else {
      guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TrainingDayHeaderView") as? TrainingDayHeaderView else {return nil}
      if let day = manager.dataSource?.currentWeek?.days[section] {
        headerView.day = day
        headerView.tag = section
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action:  #selector(copyDay))
        headerView.addGestureRecognizer(longPressRecognizer)
        
        headerView.dateLabel.text = day.date == "" ? "Укажите дату" : day.date
        headerView.dateLabel.textColor = day.date == "" ? .placeholderLightGrey : .darkCyanGreen
        headerView.dayLabel.text = "День \(section + 1)"
        headerView.nameTextField.text = day.name
        headerView.nameTextField.tag = section
        headerView.nameTextField.delegate = self
        if day.roundExercisesIds.isEmpty || day.roundExercisesIds.first?.id == "" {
          headerView.sircleTrainingButton.setImage(UIImage(named: "roundtraining-default"), for: .normal)
        } else {
          headerView.sircleTrainingButton.setImage(UIImage(named: "roundtraining-active-32px"), for: .normal)
        }
      }
      headerView.sircleTrainingButton.tag = section
      headerView.startTrainingButton.tag = section
      headerView.changeDateButton.tag = section
      headerView.deleteButton.tag = section
      headerView.deleteButton.isHidden = !showDeleteDayButton
      headerView.deleteButton.addTarget(self, action: #selector(showDeleteDayAlert(sender:)), for: .touchUpInside)
      headerView.changeDateButton.addTarget(self, action: #selector(changeDate(sender:)), for: .touchUpInside)
      headerView.startTrainingButton.addTarget(self, action: #selector(startTraining(sender:)), for: .touchUpInside)
      headerView.sircleTrainingButton.addTarget(self, action: #selector(startRoundTraining(sender:)), for: .touchUpInside)
      return headerView
    }
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 85
    
  }
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == (manager.getExercisesOf(day: indexPath.section).count) {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddExerciseToDayTableViewCell", for: indexPath) as? AddExerciseToDayTableViewCell else {return UITableViewCell()}
      return cell
    } else {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseTableViewCell", for: indexPath) as? ExerciseTableViewCell else {return UITableViewCell()}
      
      
      let exercise = manager.getExercisesOf(day: indexPath.section)[indexPath.row]
      if let ex = manager.realm.getElement(ofType: Exercise.self, filterWith: NSPredicate(format: "id = %@", exercise.exerciseId)) {
        cell.exerciseNameLable.text = ex.name
        cell.exerciseImageView.sd_setImage(with: URL(string: ex.pictures.first?.url ?? ""), placeholderImage: nil, options: .allowInvalidSSLCertificates, completed: nil)
        tap = TapGesture(target: self, action: #selector(handleTap(sender:)))
        tap.indexPath = indexPath
        cell.exerciseImageView.addGestureRecognizer(tap)
        cell.exerciseImageView.tag = indexPath.row
      }
      return cell
    }
  }
  
  func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    if indexPath.row == (manager.dataSource?.currentWeek?.days[indexPath.section].exercises.count ?? 0) {
      return false
    } else {
      return true
    }
  }
  func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    return UITableViewCell.EditingStyle.none
  }
  func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
    return false
  }
  func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    if manager.checkForRoundTraining(at: sourceIndexPath, to: destinationIndexPath) {
      self.replaceExercisesAlert(of: sourceIndexPath.section, from: sourceIndexPath.row, to: destinationIndexPath.section, at: destinationIndexPath.row)
    } else {
      manager.replaceExercises(of: sourceIndexPath.section, from: sourceIndexPath.row, to: destinationIndexPath.section, at: destinationIndexPath.row)
      self.tableView.reloadData()
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let daysCount = manager.dataSource?.currentWeek?.days.count else {return 0}
    if section == daysCount {
      return 0
    } else {
      return (manager.getExercisesOf(day: section).count) + 1
    }
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    guard let daysCount = manager.dataSource?.currentWeek?.days.count else {return 1}
    if daysCount == 0 {
      return 1
    } else {
      return daysCount + 1
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let day = manager.dataSource?.currentWeek?.days[indexPath.section] else {return}
    manager.setCurrent(day: day)
    if indexPath.row != manager.getExercisesOf(day: indexPath.section).count {
      let ex = manager.getExercisesOf(day: indexPath.section)[indexPath.row]
      manager.setCurrent(exercise: ex)
      self.performSegue(withIdentifier: "showExerciseInTraining", sender: nil)
    } else {
      self.performSegue(withIdentifier: "addExercise", sender: nil)
    }
  }
  
  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    switch indexPath.row {
      case manager.getExercisesOf(day: indexPath.section).count:
        return false
      default:
        return true
    }
  }
  
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    let delete = getDeleteAction()
    return [delete]
  }
  
  private func getDeleteAction() -> UITableViewRowAction {
    let delete = UITableViewRowAction(style: .destructive, title: "Удалить") { (action, indexPath) in
      guard let object = self.manager.dataSource?.currentWeek?.days[indexPath.section].exercises[indexPath.row] else {return}
      self.manager.realm.deleteObject(object)
      self.manager.editTraining(wiht: self.manager.getCurrentTraining()?.id ?? -1, success: {})
      UIView.transition(with: self.tableView, duration: 0.35, options: .transitionCrossDissolve, animations: { self.tableView.reloadData() })
    }
    return delete
  }
  
}

extension MyTranningsViewController: FZAccordionTableViewDelegate {
  func tableView(_ tableView: FZAccordionTableView, willOpenSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
    guard let daysCount = manager.dataSource?.currentWeek?.days.count else {return}
    if section == daysCount {
      return
    }
    guard let sectionHeader = header as? TrainingDayHeaderView else { return }
    if sectionHeader.day?.id ==  self.manager.dataSource?.currentWeek?.days[section].id {
      sectionHeader.headerState.toggle()
    }
  }
  func tableView(_ tableView: FZAccordionTableView, willCloseSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
    guard let daysCount = manager.dataSource?.currentWeek?.days.count else {return}
    if section == daysCount {
      return
    }
    guard let sectionHeader = header as? TrainingDayHeaderView else { return }
    if sectionHeader.day?.id ==  self.manager.dataSource?.currentWeek?.days[section].id {
      sectionHeader.headerState.toggle()
    }
  }
}

extension MyTranningsViewController: TrainingsViewDelegate {
  
  func trainingDeleted() {
    manager.loadTrainingsFromRealm()
  }
  
  func synced() {
    manager.loadTrainings()
  }
  
  func trainingEdited() {
    if manager.sportsmanId == AuthModule.currUser.id {
      changeWeek()
      self.tableView.reloadData()
    }
  }
  
  func templatesLoaded() {}
  
  func templateCreated() {}
  
  func startLoading() {
    loadingView.isHidden = false
  }
  
  func finishLoading() {
    loadingView.isHidden = true
  }
  
  func trainingsLoaded() {
    if manager.sportsmanId == AuthModule.currUser.id {
        if !manager.firstLoad {
          if !trainingsShown {
            setupFirstWeek()
            changeWeek()
            if manager.dataSource!.trainings.count != 0 { trainingsShown = true }
          } else {
            self.tableView.reloadData()
          }
        } else {
          changeWeek()
          setupFirstWeek()
        }
    
    } else {
      if !trainingsShown {
        setupFirstWeek()
        changeWeek()
        trainingsShown = true
      } else {
        self.tableView.reloadData()
      }
    }
    self.refreshControl.endRefreshing()
    self.view.isUserInteractionEnabled = true
  }
  
  func errorOccurred(err: String) {
    print("Error")
  }
}

extension MyTranningsViewController: MultipleChoicesViewControllerDelegate, MultipleChoicesViewControllerDataSource {
  
  func selectedElements() -> ([ExerciseInTraining], [Int]) {
    guard let exercises = manager.getCurrentday()?.exercises else {return ([],[])}
    guard let IDS = manager.getCurrentday()?.roundExercisesIds else {return ([],[])}
    let ids = IDS.map{$0.id}
    var array = [ExerciseInTraining]()
    var idArr = [Int]()
    for (i,ex) in exercises.enumerated() {
      if ids.contains(ex.exerciseId) {
        array.append(ex)
        idArr.append(i)
      }
    }
    return (array,idArr)
  }
  
  func selectionWasDone(with result: [String]) {
    manager.setDayRoundExercises(with: result)
  }
  func allSelected() -> Bool {
    guard let exercises = manager.getCurrentday()?.exercises else {return false}
    guard let IDS = manager.getCurrentday()?.roundExercisesIds else {return false}
    return exercises.count == IDS.count
  }
  func elementsForMultipleChoiceController() -> [ExerciseInTraining]? {
    guard let exercies = manager.getCurrentday()?.exercises else {return nil}
    return Array(exercies)
  }
  
  func allowsMultipleSelection() -> Bool {
    return true
  }
  
  func elementsCanBeAdded() -> Bool {
    return false
  }
  
  
}

extension MyTranningsViewController: UITextFieldDelegate {
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    nextWeekButton.isEnabled = false
    prevWeekButton.isEnabled = false
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    switch textField.tag {
      case 999:
        textField.text  = (textField.text ?? "").capitalizingFirstLetter()
      default:
        try! manager.realm.performWrite {
          guard let object = manager.dataSource?.currentWeek?.days[textField.tag] else {return}
          object.name = (textField.text ?? "").capitalizingFirstLetter()
          self.tableView.reloadData()
          self.manager.editTraining(wiht: manager.dataSource?.currentTraining?.id ?? -1, success: {})
      }
    }
    nextWeekButton.isEnabled = true
    prevWeekButton.isEnabled = true
  }
}

extension MyTranningsViewController: TrainingCalendarProtocol {
  
  func setWeek(index: Int) {
    weekNumber = index
    if let name = manager.dataSource?.currentWeek?.name {
      weekLabel.text = name
    } else {
      weekLabel.text = "#\(weekNumber+1) Неделя"
    }
    self.tableView.reloadData()
  }
  
  func setDay(index: Int) {
    delay(sec: 0.5) {
      self.tableView.scrollToRow(at: IndexPath(row: NSNotFound, section: index), at: .top, animated: false)
      guard let header = self.tableView.headerView(forSection: index) as? TrainingDayHeaderView else {return}
      if header.headerState == .unselected {
        delay(sec: 0.2) {
          self.tableView.toggleSection(index)
        }
      }
    }
  }
  
}


extension ExercisesViewController: TrainingsViewDelegate {
    func synced() {}
    
    func trainingEdited() {}
    
    func trainingsLoaded() {}
    
    func templateCreated() {}
    
    func templatesLoaded() {}
}

extension MyTranningsViewController: CommunityListViewProtocol{
  func updateTableView() {
    
  }
  
  func configureFilterView(dataSource: [String], selectedFilterIndex: Int) {
    
  }
  
  func setCityFilterTextField(name: String?) {
    
  }
  
  func showAlertFor(user: UserVO, isTrainerEnabled: Bool) {
    
  }
  
  func setErrorViewHidden(_ isHidden: Bool) {
    
  }
  
  func setLoaderVisible(_ visible: Bool) {
    
  }
  
  func stopLoadingViewState() {
    
  }
  
  func showGeneralAlert() {
    
  }
  
  func showRestoreAlert() {
    
  }
  
  func showIAP() {
    
  }
  
  func hideAccessDeniedView() {
    
  }
}
