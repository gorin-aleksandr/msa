//
//  CreateTemplateViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 8/19/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import RealmSwift

class CreateTemplateViewController: UIViewController {

    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewWithPicker: UIView!{
        didSet{viewWithPicker.alpha = 0}
    }
    @IBOutlet weak var picker: UIPickerView!
    
    var manager = TrainingManager(type: .my)
    var createTapped = false
    var selectedRow = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialConfigurations()

    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        back()
    }
    @IBAction func okButtonAction(_ sender: Any) {
        createTemplate()
    }
    
    private func back() {
        navigationController?.popViewController(animated: true)
    }

    private func initialConfigurations() {
        manager.initView(view: self)
        initialDataFill()
        configureTableView()
        picker.delegate = self
        loadingView.isHidden = true
    }
    
    func initialDataFill() {
        var daysAmount = 0
        if let weeks = manager.getCurrentTraining()?.weeks {
            for week in weeks {
                daysAmount += week.days.count
            }
        }
        manager.dataSource?.newTemplate?.name = manager.getCurrentTraining()?.name ?? ""
        manager.dataSource?.newTemplate?.days = daysAmount
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(UINib(nibName: "TextViewViewCounterTableViewCell", bundle: nil), forCellReuseIdentifier: "TextViewViewCounterTableViewCell")
        self.tableView.register(UINib(nibName: "ChoosingItemTableViewCell", bundle: nil), forCellReuseIdentifier: "ChoosingItemTableViewCell")
        self.tableView.register(UINib(nibName: "CreateExerciseTableViewCell", bundle: nil), forCellReuseIdentifier: "CreateExerciseTableViewCell")

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorColor = .clear
        tableView.showsVerticalScrollIndicator = false
    }
    @IBAction func doneButton(_ sender: Any) {
        hide()
        tableView.reloadData()
    }
    
    func hide() {
        UIView.animate(withDuration: 0.3) {
            self.viewWithPicker.alpha = 0
        }
    }
}

extension CreateTemplateViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        hide()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        switch textView.tag {
        case 1:
            guard let cell = tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? TextViewViewCounterTableViewCell else {return}
            cell.numOfSymbuls.text = "\(textView.text.count)"
            cell.infoTextView.text = textView.text
            manager.dataSource?.newTemplate?.name = textView.text
        case 2:
            guard let cell = tableView.cellForRow(at: IndexPath(item: 1, section: 0)) as? TextViewViewCounterTableViewCell else {return}
            cell.numOfSymbuls.text = "\(textView.text.count)"
            cell.infoTextView.text = textView.text
            manager.dataSource?.newTemplate?.days = Int(textView.text) ?? 0
        default: return
        }
        
        tableView.endUpdates()
        textView.becomeFirstResponder()
    }
    
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        switch textView.tag {
        case 1: return numberOfChars < 151
        case 2: return numberOfChars < 4
        default: return false
        }
    }

}

extension CreateTemplateViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return configureNameCell(indexPath: indexPath)
        case 1:
            return configureDaysCountCell(indexPath: indexPath)
        case 2:
            return configureTypeCell(indexPath: indexPath)
        case 3:
            return configureFinalCell(indexPath: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    func configureNameCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewViewCounterTableViewCell", for:  indexPath) as! TextViewViewCounterTableViewCell
        cell.HeaderLabel.text = "Название тренировки"
        cell.errorLabel.isHidden = true
        cell.infoTextView.delegate = self
        cell.infoTextView.tag = 1
        cell.infoTextView.text = manager.dataSource?.newTemplate?.name
        if createTapped && (manager.dataSource?.newTemplate?.name == ""){
            cell.errorLabel.isHidden = false
        } else {
            cell.errorLabel.isHidden = true
        }
        cell.maxLenght.text = "150"
        let c = cell.infoTextView.text?.count
        if c == 0 {
            cell.numOfSymbuls.text = ""
        } else {
            cell.numOfSymbuls.text = "\(c ?? 0)"
        }
        return cell
    }
    
    func configureDaysCountCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewViewCounterTableViewCell", for:  indexPath) as! TextViewViewCounterTableViewCell
        cell.HeaderLabel.text = "Количество дней"
        cell.errorLabel.isHidden = true
        cell.infoTextView.delegate = self
        cell.infoTextView.tag = 2
        cell.infoTextView.keyboardType = .numberPad
        cell.infoTextView.text = "\(manager.dataSource?.newTemplate?.days ?? 0)"
        if createTapped && (manager.dataSource?.newTemplate?.days == 0){
            cell.errorLabel.isHidden = false
        } else {
            cell.errorLabel.isHidden = true
        }
        cell.maxLenght.text = "3"
        let c = cell.numOfSymbuls.text?.count
        if c == 0 {
            cell.numOfSymbuls.text = ""
        } else {
            cell.numOfSymbuls.text = "\(c ?? 0)"
        }
        return cell
    }
    
    func configureTypeCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChoosingItemTableViewCell", for:  indexPath) as! ChoosingItemTableViewCell
        cell.headerLabel.text = "Вид спорта"
        if createTapped && (manager.dataSource?.newTemplate?.typeId == -1){
            cell.errorLabel.isHidden = false
        } else {
            if manager.dataSource?.newTemplate?.typeId != -1 {
                if let type = manager.realm.getElement(ofType: ExerciseType.self, filterWith: NSPredicate(format: "id = %d", (manager.dataSource?.newTemplate?.typeId)!)) {
                    cell.elementChoosed.text = type.name
                }
            }
            cell.errorLabel.isHidden = true
        }
        return cell
    }
    
    func configureFinalCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateExerciseTableViewCell", for:  indexPath) as! CreateExerciseTableViewCell
        cell.icon.image = #imageLiteral(resourceName: "gantelya")
        cell.textLabelMess.text = "Сохранить как шаблон"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedRow = indexPath.row
        switch indexPath.row {
        case 0,1:
            UIView.animate(withDuration: 0.3) {
                self.viewWithPicker.alpha = 0
            }
        case 2:
            picker.reloadAllComponents()
            UIView.animate(withDuration: 0.3) {
                self.view.endEditing(true)
                self.viewWithPicker.alpha = 1
            }
        default:
            self.createTemplate()
        }
    }
    
    private func createTemplate() {
        if manager.dataSource?.newTemplate?.name != "" && manager.dataSource?.newTemplate?.days != 0 && manager.dataSource?.newTemplate?.typeId != -1 {
            manager.saveTemplate()
            back()
        } else {
            createTapped = true
            AlertDialog.showAlert("Ошибка создания", message: "Введите все необходимые данные", viewController: self)
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 3:
            return 60
        default:
            return UITableViewAutomaticDimension
        }
    }
}

extension CreateTemplateViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return RealmManager.shared.getArray(ofType: ExerciseType.self).count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return RealmManager.shared.getArray(ofType: ExerciseType.self)[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
           let type = RealmManager.shared.getArray(ofType: ExerciseType.self)[row]
           tableView.beginUpdates()
           guard let cell = tableView.cellForRow(at: IndexPath(item: 2, section: 0)) as? ChoosingItemTableViewCell else {return}
           cell.elementChoosed.text = type.name
           manager.dataSource?.newTemplate?.typeId = type.id
           tableView.endUpdates()
    }
}

extension CreateTemplateViewController: TrainingsViewDelegate {
    func synced() {}
    
    func trainingEdited() {}
    
    func templatesLoaded() {}
    
    func templateCreated() {
        manager.dataSource?.templateCreated()
        back()
    }
    
    func startLoading() {
        loadingView.isHidden = false
    }
    
    func finishLoading() {
        loadingView.isHidden = true
    }
    
    func trainingsLoaded() {}
    
    func errorOccurred(err: String) {
        print("Error")
    }
    
    
}
