//
//  EditProfileViewController.swift
//  MSA
//
//  Created by Nik on 18.04.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit
import FZAccordionTableView
import Firebase
import SkyFloatingLabelTextField


class EditTrainerProfileViewController: UIViewController {
  @IBOutlet weak var tableView: FZAccordionTableView!
  
  var skills = ["Бодибилдинг","Фитнес","Реабилитация","Бодифитнес","Фитнес Бикини","Men’s Physique","Силовые тренировки","Коррекция фигуры","Диетология","Функциональный тренинг","ВИТ","Crossfit","Тяжелая атлетика","Пауэрлифтинг","Strongman","Развитие гибкости","Единоборства","Фитнес для беременных"]
  var ranks = ["Заслуженный мастер спорта","Мастер спорта международного класса","Мастер спорта","Кандидат в мастера спорта","1 Взрослый разряд","2 Взрослый разряд","3 Взрослый разряд","1 Юношеский разряд","2 Юношеский разряд","3 Юношеский разряд"]
  var years: [String] = []
  var achieves: [String] = ["1","2","3","4","5","6","7","8","9","10"]
  var selectedSkills: [String] = []
  var selectedAchievements:[(id: String, name: String, rank: String, achieve: String, year: String)] = []
  var selectedEducation:[(id: String, name: String, yearFrom: String, yearTo: String)] = []
  var selectedCertificates:[(id: String, name: String)] = []
  var certificateName = ""
  var kindOfSportTextField: UITextField?
  var rankTextfield: UITextField?
  var competitionNameTextfield: UITextField?
  var yearTextField: UITextField?
  var yearToTextField: UITextField?
  var achieveTextField: UITextField?
  var instaTextField: SkyFloatingLabelTextField?
  var facebookTextField: SkyFloatingLabelTextField?
  var vkTextField: SkyFloatingLabelTextField?
  var count = 1
  var userRef = Database.database().reference().child("Users")
  var dataManager = UserDataManager()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.setNavigationBarHidden(false, animated: true)
    self.title = "Редактирование"
    setupUI()
    tableView.tableFooterView = UIView()
    let group = DispatchGroup()
    group.enter()
    fetchSpecialization(completion: { sucess in
      group.leave()
    })
    group.enter()
    fetchAchievements(completion: { sucess in
      group.leave()
    })
    group.enter()
    fetchEducation(completion: { sucess in
      group.leave()
    })
    group.enter()
    fetchCertificate(completion: { sucess in
      group.leave()
    })
    group.notify(queue: .main) {
      self.tableView.reloadData()
    }
  }
  
  func setupUI() {
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(UINib(nibName: "TrainerSkillsHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TrainerSkillsHeaderView")
    tableView.register(UINib(nibName: "ExerciseTableViewCell", bundle: nil), forCellReuseIdentifier: "ExerciseTableViewCell")
    tableView.register(UINib(nibName: "AchievmentCell", bundle: nil), forCellReuseIdentifier: "AchievmentCell")
    tableView.register(UINib(nibName: "CreateExerciseTableViewCell", bundle: nil), forCellReuseIdentifier: "CreateExerciseTableViewCell")

    tableView.register(UINib(nibName: "EducationCell", bundle: nil), forCellReuseIdentifier: "EducationCell")
    tableView.register(UINib(nibName: "SkyFloatingView", bundle: nil), forHeaderFooterViewReuseIdentifier: "SkyFloatingView")
    configureNavigationItem()
  }
  
  func configureNavigationItem() {
    let button1 = UIBarButtonItem(image: #imageLiteral(resourceName: "ok_blue"), style: .plain, target: self, action: #selector(self.save))
    self.navigationItem.rightBarButtonItem = button1  }
  
  @objc func save() {
    updateSocialLinks()
  }
  
  func showRankAlert() {
    
    let ac = UIAlertController(title: "Заполните данные", message: nil, preferredStyle: .alert)
    
    years = (1970...2020).map { String($0) }.reversed()
    
    ac.addTextField { (textField : UITextField!) -> Void in
      textField.delegate = self
      textField.placeholder = "Вид спорта"
      self.kindOfSportTextField = textField
    }
    ac.addTextField { (textField : UITextField!) -> Void in
      textField.delegate = self
      textField.keyboardType = UIKeyboardType.decimalPad
      textField.placeholder = "Звание"
      let thePicker = UIPickerView()
      thePicker.tag = 1
      thePicker.delegate = self
      textField.inputView = thePicker
      self.rankTextfield = textField
    }
    ac.addTextField { (textField : UITextField!) -> Void in
      textField.delegate = self
      textField.keyboardType = UIKeyboardType.decimalPad
      textField.placeholder = "Год"
      let thePicker = UIPickerView()
      thePicker.tag = 2
      thePicker.delegate = self
      textField.inputView = thePicker
      self.yearTextField = textField
    }
    
    ac.addAction(UIAlertAction(title: "Сохранить", style: .default, handler: { (action) in
      let kindOfSport = self.kindOfSportTextField?.text
      let rank = self.rankTextfield?.text
      let year = self.yearTextField?.text
      self.selectedAchievements.append((id: "",name: kindOfSport ?? "", rank: rank ?? "", achieve: "", year: year ?? ""))
      self.saveAchievements()
      ac.dismiss(animated: true, completion: nil)
    }))
    DispatchQueue.main.async {
      self.present(ac, animated: true, completion: nil)
    }
  }
  
  func showCompetitionAlert() {
    
    let ac = UIAlertController(title: "Заполните данные", message: nil, preferredStyle: .alert)
    years = (1970...2020).map { String($0) }.reversed()
    
    ac.addTextField { (textField : UITextField!) -> Void in
      textField.delegate = self
      textField.placeholder = "Вид спорта"
      self.kindOfSportTextField = textField
    }
    ac.addTextField { (textField : UITextField!) -> Void in
      textField.delegate = self
      textField.placeholder = "Название соревнования"
      self.competitionNameTextfield = textField
    }
    ac.addTextField { (textField : UITextField!) -> Void in
      textField.delegate = self
      textField.placeholder = "Год"
      let thePicker = UIPickerView()
      thePicker.tag = 2
      thePicker.delegate = self
      textField.inputView = thePicker
      self.yearTextField = textField
    }
    ac.addTextField { (textField : UITextField!) -> Void in
      textField.delegate = self
      textField.placeholder = "Занятое место"
      let thePicker = UIPickerView()
      thePicker.tag = 3
      thePicker.delegate = self
      textField.inputView = thePicker
      self.achieveTextField = textField
    }
    
    ac.addAction(UIAlertAction(title: "Сохранить", style: .default, handler: { (action) in
           let kindOfSport = self.kindOfSportTextField?.text
           let competitionName = self.competitionNameTextfield?.text
           let year = self.yearTextField?.text
           let achieve = self.achieveTextField?.text
           self.selectedAchievements.append((id: "",name: kindOfSport ?? "", rank: competitionName ?? "", achieve: achieve ?? "", year: year ?? ""))
           self.saveAchievements()
      ac.dismiss(animated: true, completion: nil)
    }))
    DispatchQueue.main.async {
      self.present(ac, animated: true, completion: nil)
    }
  }
  
  func showEducationAlert() {
    
    let ac = UIAlertController(title: "Заполните данные", message: nil, preferredStyle: .alert)
    years = (1970...2020).map { String($0) }.reversed()
    
    ac.addTextField { (textField : UITextField!) -> Void in
      textField.delegate = self
      textField.placeholder = "Учебное заведение"
      self.kindOfSportTextField = textField
    }
    ac.addTextField { (textField : UITextField!) -> Void in
      textField.delegate = self
      textField.placeholder = "Год начала обучения"
      let thePicker = UIPickerView()
      thePicker.tag = 2
      thePicker.delegate = self
      textField.inputView = thePicker
      self.yearTextField = textField
    }
    ac.addTextField { (textField : UITextField!) -> Void in
      textField.delegate = self
      textField.placeholder = "Год окончания обучения"
      let thePicker = UIPickerView()
      thePicker.tag = 4
      thePicker.delegate = self
      textField.inputView = thePicker
      self.yearToTextField = textField
    }
    
    let saveAction = UIAlertAction(title: "Сохранить", style: .default, handler: { (action) in
      ac.dismiss(animated: true, completion: nil)
      let name = self.kindOfSportTextField?.text
      let yearFrom = self.yearTextField?.text
      let yearTo = self.yearToTextField?.text
      self.selectedEducation.append((id: "", name: name ?? "", yearFrom: yearFrom ?? "", yearTo: yearTo ?? ""))
      self.saveEducation()
    })
    let cancelAction = UIAlertAction(title: "Отменить", style: .cancel, handler: { (action) in
    })
    
    ac.addAction(saveAction)
    ac.addAction(cancelAction)
    DispatchQueue.main.async {
      self.present(ac, animated: true, completion: nil)
    }
  }
  
  func choseAchieveTypeAlert() {
    let ac = UIAlertController(title: "Выберите тип достижения", message: nil, preferredStyle: .actionSheet)
    let rankAction = UIAlertAction(title: "Звание", style: .default, handler: { (action) in
      self.showRankAlert()
    })
    let competitionAction = UIAlertAction(title: "Соревнование", style: .default, handler: { (action) in
      self.showCompetitionAlert()
    })
    let cancelAction = UIAlertAction(title: "Отменить", style: .cancel, handler: { (action) in
    })
    
    ac.addAction(rankAction)
    ac.addAction(competitionAction)
    ac.addAction(cancelAction)
    DispatchQueue.main.async {
      self.present(ac, animated: true, completion: nil)
    }
  }
  
  func presentCertification() {
    let alert = UIAlertController(style: .actionSheet, title: "Укажите сертификат")
    let config: TextField.Config = { textField in
      textField.becomeFirstResponder()
      textField.textColor = .black
      textField.placeholder = "Название сертификата"
      textField.leftViewPadding = 12
      textField.borderWidth = 1
      textField.cornerRadius = 8
      textField.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
      textField.backgroundColor = nil
      textField.keyboardAppearance = .default
      textField.keyboardType = .default
      textField.isSecureTextEntry = false
      textField.returnKeyType = .done
      textField.action { textField in
        self.certificateName = textField.text ?? ""
      }
    }
    alert.addOneTextField(configuration: config)
    alert.addAction(UIAlertAction(title: "Сохранить", style: .default, handler: { (action) in
      self.selectedCertificates.append((id: "", name: self.certificateName))
      self.saveCertificate()
    }))
    alert.show()
  }
  func addTagAlert() {
    let ac = UIAlertController(title: "Добавить специализацию", message: nil, preferredStyle: .alert)
    
    ac.addTextField { (textField : UITextField!) -> Void in
      textField.delegate = self
      textField.placeholder = "Название"
    }
    ac.addAction(UIAlertAction(title: "Сохранить", style: .default, handler: { (action) in
      self.selectedSkills.append(ac.textFields![0].text ?? "")
      self.saveSpecialization()
      self.tableView.reloadData()
      ac.dismiss(animated: true, completion: nil)
    }))
    ac.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: { (action) in
        ac.dismiss(animated: true, completion: nil)
      }))
    DispatchQueue.main.async {
      self.present(ac, animated: true, completion: nil)
    }
  }
}

extension EditTrainerProfileViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
    guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TrainerSkillsHeaderView") as? TrainerSkillsHeaderView else {return nil}
    headerView.tag = section
    headerView.titleLabel.font = UIFont(name: "Rubik-Regular", size: 17)
    headerView.textLabel?.textColor = lightBlue_
    switch section {
      case 0:
        headerView.titleLabel.text = "Специализация"
        headerView.logoImageView.image = UIImage(named: "noun_personaltrainer")
      case 1:
        headerView.titleLabel.text = "Спортивные достижения"
        headerView.logoImageView.image = UIImage(named: "noun_champion")
      case 2:
        headerView.titleLabel.text = "Образование"
        headerView.logoImageView.image = UIImage(named: "noun_education")
      case 3:
        headerView.titleLabel.text = "Сертификация"
        headerView.logoImageView.image = UIImage(named: "noun_strong")
      default:
        headerView.titleLabel.text = "Сертификация"
      
    }
    
    if section == 4 || section == 5 || section == 6 {
      guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SkyFloatingView") as? SkyFloatingView else {return nil}
      switch section {
        case 4:
          headerView.floatingTextField.placeholder = "Instagram (ник или ссылка)"
          headerView.floatingTextField.text = AuthModule.currUser.instagramLink
          instaTextField = headerView.floatingTextField
          
        case 5:
          headerView.floatingTextField.placeholder = "Facebook (ник или ссылка)"
          headerView.floatingTextField.text = AuthModule.currUser.facebookLink
          facebookTextField = headerView.floatingTextField
        case 6:
          headerView.floatingTextField.placeholder = "ВКонтакте (ник или ссылка)"
          headerView.floatingTextField.text = AuthModule.currUser.vkLink
          vkTextField = headerView.floatingTextField
        default:
          break
      }
      return headerView
    }
    print("Section = \(section)")
    
    return headerView
    
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == 4 || section == 5 || section == 6 {
      return 50
    }
    return 85
    
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch indexPath.section {
      case 0:
        if indexPath.row == 1 {
          return 60
        }
        return UITableView.automaticDimension
      case 1:
        if indexPath.row != selectedAchievements.count {
          return 80
        } else {
          return 60
      }
      case 2:
        if indexPath.row != selectedEducation.count {
          return 70
        } else {
          return 60
      }
      case 3:
        if indexPath.row != selectedCertificates.count {
          return 50
        } else {
          return 60
      }
      default: return UITableView.automaticDimension
    }
    
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if indexPath.section == 0 {
      if indexPath.row == 0 {
        return tagCell()
      } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateExerciseTableViewCell", for:  indexPath) as! CreateExerciseTableViewCell
        cell.icon.image = nil
        cell.textLabelMess.text = "Добавить свой вариант"
        cell.selectionStyle = .none
        return cell
      }
    }
    
    if indexPath.section == 1 {
      if selectedAchievements.count > 0 && indexPath.row != selectedAchievements.count {
        return achievementCell(indexPath: indexPath)
      } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateExerciseTableViewCell", for:  indexPath) as! CreateExerciseTableViewCell
        cell.icon.image = nil
        cell.textLabelMess.text = "Добавить достижение"
        cell.selectionStyle = .none
        return cell
      }
    }
    
    if indexPath.section == 2 {
      if selectedEducation.count > 0 && indexPath.row != selectedEducation.count {
        return educationCell(indexPath: indexPath)
      } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateExerciseTableViewCell", for:  indexPath) as! CreateExerciseTableViewCell
        cell.icon.image = nil
        cell.textLabelMess.text = "Добавить образование"
        cell.selectionStyle = .none
        return cell
      }
    }
    
    if indexPath.section == 3 {
        if selectedCertificates.count > 0 && indexPath.row != selectedCertificates.count {
          return certificationCell(indexPath: indexPath)
        } else {
          let cell = tableView.dequeueReusableCell(withIdentifier: "CreateExerciseTableViewCell", for:  indexPath) as! CreateExerciseTableViewCell
          cell.icon.image = nil
          cell.textLabelMess.text = "Добавить сертификацию"
          cell.selectionStyle = .none
          return cell
        }
      }
    let cell = tableView.dequeueReusableCell(withIdentifier: "CreateExerciseTableViewCell", for:  indexPath) as! CreateExerciseTableViewCell
    cell.icon.image = nil
    cell.textLabelMess.text = "Добавить свой вариант"
    cell.selectionStyle = .none
    return cell
  }
  
  func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
    return false
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
      case 0:
        return 2
      case 1:
        return selectedAchievements.count + 1
      case 2:
        return selectedEducation.count + 1
      case 3:
        return selectedCertificates.count + 1
      default:
        return 0
    }
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 7
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath.section {
      case 0:
        if indexPath.row == 1 {
          addTagAlert()
        }
      case 1:
        if indexPath.row == selectedAchievements.count {
          choseAchieveTypeAlert()
        }
      case 2:
        if indexPath.row == selectedEducation.count {
          showEducationAlert()
        }
      case 3:
        if indexPath.row == selectedCertificates.count {
        presentCertification()
        }
      default:
        choseAchieveTypeAlert()
    }
    
  }
  
  func tagCell() -> ProductCategoriesCell{
    let cell: ProductCategoriesCell! = tableView.dequeueReusableCell(withIdentifier: ProductCategoriesCell.identifier) as? ProductCategoriesCell
    cell.tagList.removeAllTags()
    
    for item in skills {
      cell.tagList.addTag(item)
    }
    
    for item in selectedSkills {
      var added = false
      for tag in cell!.tagList.tagViews {
        if item == tag.titleLabel?.text {
          added = true
        }
      }
      if !added {
        cell.tagList.addTag(item)
      }
    }
    
    for tag in cell!.tagList.tagViews {
      for item in selectedSkills {
        if item == tag.titleLabel?.text {
          tag.isSelected = true
        }
      }
    }
    
    cell.addTag = { (title,added) in
        if added {
          self.selectedSkills.append(title)
        } else {
          self.selectedSkills.removeAll(title)
        }
        self.saveSpecialization()
      }
  
    cell.selectionStyle = .none
    return cell
  }
  
  func achievementCell(indexPath: IndexPath) -> AchievmentCell{
    let cell: AchievmentCell! = tableView.dequeueReusableCell(withIdentifier: AchievmentCell.identifier) as? AchievmentCell
    let achieve = selectedAchievements[indexPath.row]
    cell.nameLabel.text = achieve.name
    cell.rankLabel.text = achieve.rank
    cell.yearLabel.text = achieve.year
    cell.achieveLabel.text = achieve.achieve != "" ? "\(achieve.achieve) \nместо" : ""
    cell.removeAchievement = {
      self.removeAchievement(index: indexPath.row, completion: {_ in})
    }
    cell.selectionStyle = .none
    return cell
  }
  
  func educationCell(indexPath: IndexPath) -> EducationCell{
    let cell: EducationCell! = tableView.dequeueReusableCell(withIdentifier: EducationCell.identifier) as? EducationCell
    let education = selectedEducation[indexPath.row]
    cell.nameLabel.text = education.name
    cell.yearFromLabel.text = education.yearFrom
    cell.yearToLabel.text = education.yearTo
    cell.removeEducation = {
      self.removeEducation(index: indexPath.row, completion: {_ in})
    }
    cell.selectionStyle = .none
    return cell
  }
  
  func certificationCell(indexPath: IndexPath) -> EducationCell{
    let cell: EducationCell! = tableView.dequeueReusableCell(withIdentifier: EducationCell.identifier) as? EducationCell
    let certificate = selectedCertificates[indexPath.row]
    cell.nameLabel.text = certificate.name
    cell.yearToLabel.isHidden = true
    cell.yearFromLabel.isHidden = true
    cell.removeEducation = {
      self.removeCertificate(index: indexPath.row, completion: {_ in})
    }
    cell.selectionStyle = .none
    return cell
  }
}

extension EditTrainerProfileViewController: FZAccordionTableViewDelegate {
  func tableView(_ tableView: FZAccordionTableView, willOpenSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
    guard let sectionHeader = header as? TrainerSkillsHeaderView else { return }
    sectionHeader.headerState.toggle()
    
  }
  func tableView(_ tableView: FZAccordionTableView, willCloseSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
    guard let sectionHeader = header as? TrainerSkillsHeaderView else { return }
    sectionHeader.headerState.toggle()
  }
}

extension EditTrainerProfileViewController: UITextFieldDelegate {
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    print("Чинаа!")
    return true
  }
}

// MARK: UIPickerView Delegation

extension EditTrainerProfileViewController: UIPickerViewDataSource, UIPickerViewDelegate {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    switch pickerView.tag {
      case 1:
        return ranks.count
      case 2:
        return years.count
      case 3:
        return achieves.count
      case 4:
        return years.count
      default:
        return ranks.count
    }
    
  }
  
  func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    switch pickerView.tag {
      case 1:
        return ranks[row]
      case 2:
        return years[row]
      case 3:
        return achieves[row]
      case 4:
        return years[row]
      default:
        return ranks[row]
    }
  }
  
  func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    switch pickerView.tag {
      case 1:
        rankTextfield!.text = ranks[row]
      case 2:
        yearTextField!.text = years[row]
      case 3:
        achieveTextField!.text = achieves[row]
      case 4:
        yearToTextField!.text = years[row]
      default:
        rankTextfield!.text = ranks[row]
    }
  }
}

extension EditTrainerProfileViewController {
  
  func saveSpecialization() {
    if let key = AuthModule.currUser.id {
      userRef.child(key).child("coachDetail").child("specialization").setValue(selectedSkills, andPriority: nil) { (error, ref) in
        print(ref)
      }
    }
  }
  
  func fetchSpecialization(completion: @escaping (Bool) -> Void) {
    if let key = AuthModule.currUser.id {
      userRef.child(key).child("coachDetail").child("specialization").observeSingleEvent(of: .value, with: { snapshot in
        for child in snapshot.children {
          let snap = child as! DataSnapshot
          let specialization = snap.value as! String
          self.selectedSkills.append(specialization)
        }
        completion(true)
        print(self.selectedSkills)
      })
    }
  }
  
  func saveAchievements() {
    let achieve:[String: Any] = [
      "name": selectedAchievements.last?.name ?? "",
      "rank": selectedAchievements.last?.rank ?? "",
      "year": selectedAchievements.last?.year ?? "",
      "achievement": selectedAchievements.last?.achieve ?? ""
    ]
    if selectedAchievements.count > 0 {
      let autoId = Database.database().reference().childByAutoId().key
      if let key = AuthModule.currUser.id {
        userRef.child(key).child("coachDetail").child("achievements").child("\(autoId)").setValue(achieve, andPriority: nil) { (error, ref) in
          var achievement = self.selectedAchievements.last
          achievement!.id = autoId
          self.selectedAchievements.removeLast()
          self.selectedAchievements.append(achievement!)
          self.tableView.reloadData()
        }
      }
    }
    print(self.selectedAchievements)
  }
  
  func fetchAchievements(completion: @escaping (Bool) -> Void) {
    if let key = AuthModule.currUser.id {
      userRef.child(key).child("coachDetail").child("achievements").observeSingleEvent(of: .value, with: { snapshot in
        if let dict = snapshot.value as? Dictionary<String, Any> {
          print(dict)
          for key in dict.keys {
            let item = dict[key] as? Dictionary<String, Any>
            self.selectedAchievements.append((id: key, name: item?["name"] as! String, rank: item?["rank"] as! String, achieve: item?["achievement"] as! String, year: item?["year"] as! String))
          }
          completion(true)
        }
      })
    }
  }
  
  func removeAchievement(index: Int,completion: @escaping (Bool) -> Void) {
    let achieve = selectedAchievements[index]
    if let key = AuthModule.currUser.id {
      userRef.child(key).child("coachDetail").child("achievements").child("\(achieve.id)").setValue(nil, andPriority: nil) { (error, ref) in
             self.selectedAchievements.remove(at: index)
             self.tableView.reloadData()
           }
         }
  }
  
  func saveEducation() {
    let education:[String: Any] = [
      "name": selectedEducation.last?.name ?? "",
      "yearFrom": selectedEducation.last?.yearFrom ?? "",
      "yearTo": selectedEducation.last?.yearTo ?? "",
    ]
    if selectedAchievements.count > 0 {
      let autoId = Database.database().reference().childByAutoId().key
      if let key = AuthModule.currUser.id {
        userRef.child(key).child("coachDetail").child("education").child("\(autoId)").setValue(education, andPriority: nil) { (error, ref) in
          var lastEducation = self.selectedEducation.last
          lastEducation!.id = autoId
          self.selectedEducation.removeLast()
          self.selectedEducation.append(lastEducation!)
          self.tableView.reloadData()
        }
      }
    }
    print(self.selectedAchievements)
  }
  
  func fetchEducation(completion: @escaping (Bool) -> Void) {
    if let key = AuthModule.currUser.id {
      userRef.child(key).child("coachDetail").child("education").observeSingleEvent(of: .value, with: { snapshot in
        if let dict = snapshot.value as? Dictionary<String, Any> {
          print(dict)
          for key in dict.keys {
            let item = dict[key] as? Dictionary<String, Any>
            self.selectedEducation.append((id: key, name: item?["name"] as! String, yearFrom: item?["yearFrom"] as! String, yearTo: item?["yearTo"] as! String))
          }
          completion(true)
        }
      })
    }
  }
  
  func removeEducation(index: Int,completion: @escaping (Bool) -> Void) {
    let education = selectedEducation[index]
    if let key = AuthModule.currUser.id {
      userRef.child(key).child("coachDetail").child("education").child("\(education.id)").setValue(nil, andPriority: nil) { (error, ref) in
             self.selectedEducation.remove(at: index)
             self.tableView.reloadData()
           }
    }
  }
  
  func saveCertificate() {
    let certificate:[String: Any] = [
      "name": selectedCertificates.last?.name ?? "",
    ]
    if selectedCertificates.count > 0 {
      let autoId = Database.database().reference().childByAutoId().key
      if let key = AuthModule.currUser.id {
        userRef.child(key).child("coachDetail").child("certificates").child("\(autoId)").setValue(certificate, andPriority: nil) { (error, ref) in
          var lastCertificate = self.selectedCertificates.last
          lastCertificate!.id = autoId
          self.selectedCertificates.removeLast()
          self.selectedCertificates.append(lastCertificate!)
          self.tableView.reloadData()
        }
      }
    }
  }
  
  func fetchCertificate(completion: @escaping (Bool) -> Void) {
    if let key = AuthModule.currUser.id {
      userRef.child(key).child("coachDetail").child("certificates").observeSingleEvent(of: .value, with: { snapshot in
        if let dict = snapshot.value as? Dictionary<String, Any> {
          print(dict)
          for key in dict.keys {
            let item = dict[key] as? Dictionary<String, Any>
            self.selectedCertificates.append((id: key, name: item?["name"] as! String))
          }
          completion(true)
        }
      })
    }
  }
  
  func removeCertificate(index: Int,completion: @escaping (Bool) -> Void) {
    let certificate = selectedCertificates[index]
    if let key = AuthModule.currUser.id {
      userRef.child(key).child("coachDetail").child("certificates").child("\(certificate.id)").setValue(nil, andPriority: nil) { (error, ref) in
             self.selectedCertificates.remove(at: index)
             self.tableView.reloadData()
           }
    }
  }
  
  func updateSocialLinks() {
    if let key = AuthModule.currUser.id {
        let update = [
          "instagramLink": instaTextField?.text,
          "facebookLink": facebookTextField?.text,
          "vkLink": vkTextField?.text,
            ] as [String:Any]
        userRef.child(key).updateChildValues(update, withCompletionBlock: { (error, ref) in
          self.navigationController?.popViewController(animated: true)
        })
    }
  }
}
