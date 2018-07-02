//
//  NewExerciseViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 7/1/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import RealmSwift

class NewExerciseViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewWithPicker: UIView!{
        didSet{viewWithPicker.alpha = 0}
    }
    @IBOutlet weak var picker: UIPickerView!
    
    var selectedRow = -1
    let exercManager = NewExerciseManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        picker.delegate = self
        configureTableView()
    }

    @IBAction func pickerDoneButton(_ sender: Any) {
        viewWithPicker.alpha = 0
        tableView.reloadData()
    }
    
    
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(UINib(nibName: "infoTextTableViewCell", bundle: nil), forCellReuseIdentifier: "infoTextTableViewCell")
        self.tableView.register(UINib(nibName: "TextViewViewCounterTableViewCell", bundle: nil), forCellReuseIdentifier: "TextViewViewCounterTableViewCell")
        self.tableView.register(UINib(nibName: "ChoosingItemTableViewCell", bundle: nil), forCellReuseIdentifier: "ChoosingItemTableViewCell")
        self.tableView.register(UINib(nibName: "CreateExerciseTableViewCell", bundle: nil), forCellReuseIdentifier: "CreateExerciseTableViewCell")
        self.tableView.register(UINib(nibName: "AddImagesTableViewCell", bundle: nil), forCellReuseIdentifier: "AddImagesTableViewCell")
        self.tableView.register(UINib(nibName: "LoadVideoTableViewCell", bundle: nil), forCellReuseIdentifier: "LoadVideoTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorColor = .clear
        tableView.showsVerticalScrollIndicator = false
    }

    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func done(_ sender: Any) {
        
    }
}

extension NewExerciseViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        switch textView.tag {
            case 1: exercManager.setName(name: textView.text)
            case 2: exercManager.setDescription(description: textView.text)
            case 3: exercManager.setHowToDo(howToDo: textView.text)
            default: return
        }
        tableView.endUpdates()
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        tableView.reloadData()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        switch textView.tag {
            case 1: return numberOfChars < 151
            case 2: return numberOfChars < 601
            case 3: return numberOfChars < 601
            default: return false
        }
    }
}

extension NewExerciseViewController: UITableViewDelegate, UITableViewDataSource {
    
    func configureTextInfo(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoTextTableViewCell", for:  indexPath) as! infoTextTableViewCell
        cell.label.text = "Что бы создать упражнения вам необходимо заполнить все поля и загрузить фото/видео."
        return cell
    }
    func configureTypeCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChoosingItemTableViewCell", for:  indexPath) as! ChoosingItemTableViewCell
        cell.headerLabel.text = "Группа мышц / вид спорта"
        cell.elementChoosed.text = "\(RealmManager().getArray(ofType: ExerciseType.self, filterWith: NSPredicate(format: "id = %d", exercManager.dataSource.typeId)).first?.name ?? "-")"
        return cell
    }
    func configureInventarCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChoosingItemTableViewCell", for:  indexPath) as! ChoosingItemTableViewCell
        cell.headerLabel.text = "Инвентарь"
        cell.elementChoosed.text = "\(RealmManager().getArray(ofType: ExerciseTypeFilter.self, filterWith: NSPredicate(format: "id = %d", exercManager.dataSource.filterId)).first?.name ?? "-")"
        return cell
    }
    func configureNameCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewViewCounterTableViewCell", for:  indexPath) as! TextViewViewCounterTableViewCell
        cell.HeaderLabel.text = "Название"
        cell.infoTextView.delegate = self
        cell.infoTextView.tag = 1
        cell.infoTextView.text = exercManager.dataSource.name
        cell.maxLenght.text = "150"
        let c = exercManager.dataSource.name.count
        if c == 0 {
            cell.numOfSymbuls.text = ""
        } else {
            cell.numOfSymbuls.text = "\(c)"
        }
        return cell
    }
    func configureDescriptionCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewViewCounterTableViewCell", for:  indexPath) as! TextViewViewCounterTableViewCell
        cell.HeaderLabel.text = "Описание"
        cell.infoTextView.delegate = self
        cell.infoTextView.tag = 2
        cell.infoTextView.text = "\(exercManager.dataSource.descript)"
        cell.maxLenght.text = "600"
        let c = exercManager.dataSource.descript.count
        if c == 0 {
            cell.numOfSymbuls.text = ""
        } else {
            cell.numOfSymbuls.text = "\(c)"
        }
        return cell
    }
    func configureTechnicCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewViewCounterTableViewCell", for:  indexPath) as! TextViewViewCounterTableViewCell
        cell.HeaderLabel.text = "Техника"
        cell.infoTextView.delegate = self
        cell.infoTextView.tag = 3
        cell.infoTextView.text = "\(exercManager.dataSource.howToDo)"
        cell.maxLenght.text = "600"
        let c = exercManager.dataSource.howToDo.count
        if c == 0 {
            cell.numOfSymbuls.text = ""
        } else {
            cell.numOfSymbuls.text = "\(c)"
        }
        return cell
    }
    
    func configureImagesCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddImagesTableViewCell", for:  indexPath) as! AddImagesTableViewCell
        cell.delegate = self
        cell.images = [Data(),Data(),Data(),Data(),Data()]
        return cell
    }
    
    func configureVideoCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LoadVideoTableViewCell", for:  indexPath) as! LoadVideoTableViewCell
        cell.deleteVideoButt.addTarget(self, action: #selector(self.deleteVideo(_:)), for: .touchUpInside)
        return cell
    }
    
    func configureFinalCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateExerciseTableViewCell", for:  indexPath) as! CreateExerciseTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return configureTextInfo(indexPath: indexPath)
        case 1:
            return configureNameCell(indexPath: indexPath)
        case 2:
            return configureTypeCell(indexPath: indexPath)
        case 3:
            return configureInventarCell(indexPath: indexPath)
        case 4:
            return configureDescriptionCell(indexPath: indexPath)
        case 5:
            return configureTechnicCell(indexPath: indexPath)
        case 6:
            return configureImagesCell(indexPath: indexPath)
        case 7:
            return configureVideoCell(indexPath: indexPath)
        case 8:
            return configureFinalCell(indexPath: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 6:
            return UITableViewAutomaticDimension + 160
        case 8:
            return 60
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        if selectedRow == 2 || selectedRow == 3 {
            picker.reloadAllComponents()
            viewWithPicker.alpha = 1
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
  
}

extension NewExerciseViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if selectedRow == 2 {
            return RealmManager.shared.getArray(ofType: ExerciseType.self).count
        } else if selectedRow == 3 {
            return RealmManager.shared.getArray(ofType: ExerciseTypeFilter.self).count
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if selectedRow == 2 {
            return RealmManager.shared.getArray(ofType: ExerciseType.self)[row].name
        } else if selectedRow == 3 {
            return RealmManager.shared.getArray(ofType: ExerciseTypeFilter.self)[row].name
        } else {
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if selectedRow == 2 {
            exercManager.setType(type: RealmManager.shared.getArray(ofType: ExerciseType.self)[row].id)
        } else if selectedRow == 3 {
            exercManager.setFilter(filter: RealmManager.shared.getArray(ofType: ExerciseTypeFilter.self)[row].id)
        }
    }
}

extension NewExerciseViewController: ImagesProtocol {
    @objc func deleteVideo(_ sender: UIButton) {
        print("Delete Video")
    }
    func deleteImage(at index: Int) {
        print(index)
    }
}
