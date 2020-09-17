//
//  UserSettingsViewController.swift
//  MSA
//
//  Created by Nik on 26.08.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit
import SVProgressHUD

class UserSettingsViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var nextButton: UIButton!
  
  var selectedTextField: UITextField?
  
  var viewModel: ProfileViewModel?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = viewModel?.editSettingsControllerType == .userInfo ? "Данные о вас" : "Внесите данные"
    setupUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    navigationController?.setNavigationBarHidden(false, animated: true)
    let backButton = UIBarButtonItem(image: UIImage(named: "backIcon"), style: .plain, target: self, action: #selector(self.backAction))
    self.navigationItem.leftBarButtonItem = backButton
    self.navigationController?.navigationBar.tintColor = .newBlack
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    navigationController?.setNavigationBarHidden(true, animated: true)
    viewModel!.resetSelectedValues()
    
  }
  
  func setupUI() {
    setupConstraints()
    tableView.dataSource = self
    tableView.delegate = self
    tableView.separatorStyle = .none
    tableView.tableFooterView = UIView()
    
    nextButton.titleLabel?.font = NewFonts.SFProDisplayRegular16
    nextButton.setTitleColor(UIColor.white, for: .normal)
    nextButton.setTitle("Сохранить", for: .normal)
    nextButton.setBackgroundColor(color: UIColor.newBlue, forState: .normal)
    nextButton.layer.cornerRadius = screenSize.height * (12/iPhoneXHeight)
    nextButton.maskToBounds = true
    nextButton.titleLabel?.textAlignment = .center
    nextButton.addTarget(self, action: #selector(saveButton), for: .touchUpInside)
  }
  
  func setupConstraints() {
    nextButton.snp.makeConstraints { (make) in
      make.bottom.equalTo(self.view.snp.bottom).offset(screenSize.height * (-33/iPhoneXHeight))
      make.right.equalTo(self.view.snp.right).offset(screenSize.height * (-16/iPhoneXHeight))
      make.left.equalTo(self.view.snp.left).offset(screenSize.height * (16/iPhoneXHeight))
      make.height.equalTo(screenSize.height * (54/iPhoneXHeight))
    }
    self.view.bringSubviewToFront(nextButton)
  }
  
  @objc func saveButton(_ sender: UIButton) {
    if viewModel!.editSettingsControllerType == .userInfo {
      SVProgressHUD.show()
      viewModel!.updateUserProfile(callback: { (value, error) in
        SVProgressHUD.dismiss()
        self.navigationController?.popViewController(animated: true)
      })
    } else {
      if viewModel!.achevementType == .rank || viewModel!.achevementType == .achieve {
        SVProgressHUD.show()
        viewModel!.saveAchievements(completion: { value in
          SVProgressHUD.dismiss()
          self.navigationController?.popViewController(animated: true)
        })
      }
      if viewModel!.achevementType == .education {
        SVProgressHUD.show()
        viewModel!.saveEducation(completion: { value in
          SVProgressHUD.dismiss()
          self.navigationController?.popViewController(animated: true)
        })
      }
      if viewModel!.achevementType == .certificate {
        SVProgressHUD.show()
         viewModel!.saveCertificate(completion: { value in
           SVProgressHUD.dismiss()
           self.navigationController?.popViewController(animated: true)
         })
      }
    }
    
  }
  
  @objc func backAction() {
    self.navigationController?.popViewController(animated: true)
  }
  
}

// MARK: - TableViewDataSource
extension UserSettingsViewController: UITableViewDataSource, UITableViewDelegate {
  
//  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//    if section == 1 {
//      let vw = UIView()
//         vw.backgroundColor = UIColor.white
//         return vw
//    } else {
//      return nil
//    }
//  }
  
  func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    let header = view as! UITableViewHeaderFooterView
    header.textLabel?.textColor = .black
    header.contentView.backgroundColor = .white
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 1 {
      return "Социальные сети"
    } else {
      return nil
    }
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    if viewModel!.editSettingsControllerType == .userInfo {
      return 2
    }
    return 1
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return screenSize.height * (70/iPhoneXHeight)
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel!.numberOfRowInSectionForDataController(section: section)
  }
    
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if viewModel!.editSettingsControllerType == .userInfo {
      let cell = viewModel!.editUserCell(indexPath: indexPath, tableView: tableView)
      cell.valueTextField.delegate = self
      cell.valueTextField.tag = indexPath.row
      cell.valueTextField.textInputView.tag = indexPath.section
      return cell
    } else {
      let cell = viewModel!.editCurrentAchevementUserCell(indexPath: indexPath, tableView: tableView)
      cell.valueTextField.delegate = self
      cell.valueTextField.tag = indexPath.row
      if viewModel!.achevementType == .rank {
        if indexPath.row == 1 {
          let thePicker = UIPickerView()
          thePicker.tag = 1
          thePicker.delegate = self
          cell.valueTextField.inputView = thePicker
        }
        if indexPath.row == 2 {
          let thePicker = UIPickerView()
          thePicker.tag = 2
          thePicker.delegate = self
          cell.valueTextField.inputView = thePicker
        }
        
      }
      if viewModel!.achevementType == .achieve {
        if indexPath.row == 2 {
          let thePicker = UIPickerView()
          thePicker.tag = 2
          thePicker.delegate = self
          cell.valueTextField.inputView = thePicker
        }
        if indexPath.row == 3 {
          let thePicker = UIPickerView()
          thePicker.tag = 3
          thePicker.delegate = self
          cell.valueTextField.inputView = thePicker
        }
      }
      if viewModel!.achevementType == .education {
        if indexPath.row == 1 {
          let thePicker = UIPickerView()
          thePicker.tag = 2
          thePicker.delegate = self
          cell.valueTextField.inputView = thePicker
        }
        if indexPath.row == 2 {
          let thePicker = UIPickerView()
          thePicker.tag = 2
          thePicker.delegate = self
          cell.valueTextField.inputView = thePicker
        }
      }
      
      return cell
    }
    
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //viewModel!.selectMenu(indexPath)
  }
}
extension UserSettingsViewController: UITextFieldDelegate {
  func textFieldDidChangeSelection(_ textField: UITextField) {
    viewModel!.updateTextValue(text: textField.text!,tag: textField.tag, section: textField.textInputView.tag)
  }
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    selectedTextField = textField
    return true
  }
}

// MARK: UIPickerView Delegation

extension UserSettingsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView( _ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    switch pickerView.tag {
      case 1:
        return viewModel!.ranks.count
      case 2:
      return viewModel!.years.count
      case 3:
      return viewModel!.achieves.count
      default:
        return 0
    }
    
  }
  
  func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    switch pickerView.tag {
      case 1:
        return viewModel!.ranks[row]
      case 2:
        return viewModel!.years[row]
      case 3:
        return viewModel!.achieves[row]
      default:
        return ""
    }
  }
  
  func pickerView( _ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if viewModel!.achevementType == .achieve || viewModel!.achevementType == .rank {
      switch pickerView.tag {
        case 1:
          selectedTextField?.text = viewModel!.ranks[row]
          viewModel!.currentAchievement.rank = viewModel!.ranks[row]
        case 2:
          selectedTextField?.text = viewModel!.years[row]
          viewModel!.currentAchievement.year = viewModel!.years[row]
        case 3:
            selectedTextField?.text = viewModel!.achieves[row]
            viewModel!.currentAchievement.achieve = viewModel!.achieves[row]
        default:
          return
      }
    }
    if viewModel!.achevementType == .education {
      switch pickerView.tag {
        case 2:
          if selectedTextField?.tag == 1 {
            selectedTextField?.text = viewModel!.years[row]
            viewModel!.currentEducation.yearFrom = viewModel!.years[row]
          } else {
            selectedTextField?.text = viewModel!.years[row]
            viewModel!.currentEducation.yearTo = viewModel!.years[row]
        }
        default:
          return
      }
    }

  }
}
