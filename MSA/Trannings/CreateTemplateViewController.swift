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

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewWithPicker: UIView!{
        didSet{viewWithPicker.alpha = 0}
    }
    @IBOutlet weak var picker: UIPickerView!
    
    var selectedRow = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        picker.delegate = self
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        back()
    }
    @IBAction func okButtonAction(_ sender: Any) {
        
    }
    
    private func back() {
        navigationController?.popViewController(animated: true)
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
        UIView.animate(withDuration: 0.3) {
            self.viewWithPicker.alpha = 0
        }
        tableView.reloadData()
    }
}

extension CreateTemplateViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        switch textView.tag {
        case 1:
            guard let cell = tableView.cellForRow(at: IndexPath(item: 0, section: 0)) as? TextViewViewCounterTableViewCell else {return}
            cell.numOfSymbuls.text = "\(textView.text.count)"
            cell.infoTextView.text = textView.text
        case 2:
            guard let cell = tableView.cellForRow(at: IndexPath(item: 1, section: 0)) as? TextViewViewCounterTableViewCell else {return}
            cell.numOfSymbuls.text = "\(textView.text.count)"
            cell.infoTextView.text = textView.text
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
        cell.infoTextView.text = ""
        cell.maxLenght.text = "150"
        let c = cell.numOfSymbuls.text?.count
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
        cell.infoTextView.text = ""
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
        cell.errorLabel.isHidden = true
        return cell
    }
    
    func configureFinalCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateExerciseTableViewCell", for:  indexPath) as! CreateExerciseTableViewCell
        cell.icon.image = #imageLiteral(resourceName: "gantelya")
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedRow = indexPath.row
        if selectedRow == 2{
            picker.reloadAllComponents()
            UIView.animate(withDuration: 0.3) {
                self.viewWithPicker.alpha = 1
            }
        } else if selectedRow == 3 {
            back()
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
        return RealmManager.shared.getArray(ofType: ExerciseTypeFilter.self).count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return RealmManager.shared.getArray(ofType: ExerciseType.self)[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
           let name = RealmManager.shared.getArray(ofType: ExerciseType.self)[row].name
           tableView.beginUpdates()
           guard let cell = tableView.cellForRow(at: IndexPath(item: 2, section: 0)) as? ChoosingItemTableViewCell else {return}
           cell.elementChoosed.text = name
           tableView.endUpdates()
    }
}
