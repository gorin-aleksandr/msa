//
//  NewMeasurementViewController.swift
//  MSA
//
//  Created by Nik on 09.09.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftRater
import Firebase

class NewMeasurementViewController: UIViewController, UITextFieldDelegate {
  var viewModel: MeasurementViewModel?
  
  @IBOutlet weak var mainView: UIView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var closeButton: UIButton!
  @IBOutlet weak var measureTypeImageView: UIImageView!
  @IBOutlet weak var measureTypeTitle: UILabel!
  @IBOutlet weak var lastValueLabel: UILabel!
  @IBOutlet weak var lastDateLabel: UILabel!
  @IBOutlet weak var dateTitleLabel: UILabel!
  @IBOutlet weak var dateValueButton: UIButton!
  @IBOutlet weak var valueTextField: UITextField!
  @IBOutlet weak var unitsLabel: UILabel!
  @IBOutlet weak var saveButton: UIButton!
  var comunityPresenter: CommunityListPresenterProtocol!

  override func viewDidLoad() {
    super.viewDidLoad()
    comunityPresenter = CommunityListPresenter(view: self)
    setupUI()
    view.backgroundColor = UIColor.black.withAlphaComponent(0.1)
    view.isOpaque = false
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    self.viewModel!.currentTypeId = self.viewModel!.newMeasurementId
    SVProgressHUD.show()
    self.viewModel?.fetchMeasurements(success: { (value) in
      SVProgressHUD.dismiss()
      self.setupUI()
    })
  }
  
  func setupUI() {
    mainView.cornerRadius = screenSize.height * (16/iPhoneXHeight)
    mainView.snp.makeConstraints { (make) in
      make.top.equalTo(self.view.snp.top).offset(screenSize.height * (134/iPhoneXHeight))
      make.bottom.equalTo(self.view.snp.bottom).offset(screenSize.height * (-355/iPhoneXHeight))
      make.right.equalTo(self.view.snp.right).offset(screenSize.height * (-20/iPhoneXHeight))
      make.left.equalTo(self.view.snp.left).offset(screenSize.height * (20/iPhoneXHeight))
    }
    
    titleLabel.textAlignment = .center
    titleLabel.font = NewFonts.SFProDisplayBold17
    titleLabel.text = "Новый замер"
    
    titleLabel.snp.makeConstraints { (make) in
      make.top.equalTo(self.mainView.snp.top).offset(screenSize.height * (20/iPhoneXHeight))
      make.centerX.equalTo(self.mainView.snp.centerX)
    }
    
    closeButton.snp.makeConstraints { (make) in
      make.top.equalTo(self.mainView.snp.top).offset(screenSize.height * (20/iPhoneXHeight))
      make.right.equalTo(self.mainView.snp.right).offset(screenSize.height * (-20/iPhoneXHeight))
      make.height.width.equalTo(screenSize.height * (24/iPhoneXHeight))
    }
    
    let separatorView = UIView()
    separatorView.backgroundColor = .separatorGray
    mainView.addSubview(separatorView)
    separatorView.snp.makeConstraints { (make) in
      make.top.equalTo(self.closeButton.snp.bottom).offset(screenSize.height * (12/iPhoneXHeight))
      make.right.equalTo(self.mainView.snp.right)
      make.left.equalTo(self.mainView.snp.left)
      make.height.width.equalTo(0.5)
    }
    
    measureTypeImageView.image = UIImage(named: viewModel!.icons[viewModel!.newMeasurementId])
    measureTypeImageView.snp.makeConstraints { (make) in
      make.top.equalTo(separatorView.snp.bottom).offset(screenSize.height * (15/iPhoneXHeight))
      make.left.equalTo(self.mainView.snp.left).offset(screenSize.height * (16/iPhoneXHeight))
      make.height.width.equalTo(screenSize.height * (48/iPhoneXHeight))
    }
    
    measureTypeTitle.text = viewModel!.titles[viewModel!.newMeasurementId]
    measureTypeTitle.font = NewFonts.SFProDisplayBold16
    measureTypeTitle.snp.makeConstraints { (make) in
      make.centerY.equalTo(measureTypeImageView.snp.centerY)
      make.left.equalTo(self.measureTypeImageView.snp.right).offset(screenSize.height * (12/iPhoneXHeight))
      make.right.equalTo(self.mainView.snp.right).offset(screenSize.height * (-20/iPhoneXHeight))
      make.height.width.equalTo(screenSize.height * (48/iPhoneXHeight))
    }
    
    for mes in self.viewModel!.selectedMeasurements {
      print(mes.createdDate)
    }
    
    if let lastMeasurement = self.viewModel!.selectedMeasurements.last {
      lastValueLabel.text = "\(lastMeasurement.value) \(self.viewModel!.measureUnits[self.viewModel!.currentTypeId])"
    } else {
      lastValueLabel.text = ""
    }
    lastValueLabel.font = NewFonts.SFProDisplayBold16
    lastValueLabel.snp.makeConstraints { (make) in
      make.top.equalTo(measureTypeTitle.snp.top).offset(screenSize.height * (22/iPhoneXHeight))
      make.right.equalTo(self.mainView.snp.right).offset(screenSize.height * (-16/iPhoneXHeight))
    }
    
    if let lastMeasurement = self.viewModel!.selectedMeasurements.last {
      lastDateLabel.text = "Предыдущий замер \(DateFormatter.sharedDateFormatter.string(from: lastMeasurement.createdDate))"
    } else {
      lastDateLabel.text = ""
    }
    lastDateLabel.font = NewFonts.SFProDisplayRegular10
    lastDateLabel.snp.makeConstraints { (make) in
      make.top.equalTo(lastValueLabel.snp.bottom).offset(screenSize.height * (2/iPhoneXHeight))
      make.right.equalTo(self.mainView.snp.right).offset(screenSize.height * (-16/iPhoneXHeight))
    }
    
    let separatorViewSecond = UIView()
    separatorViewSecond.backgroundColor = .separatorGray
    mainView.addSubview(separatorViewSecond)
    separatorViewSecond.snp.makeConstraints { (make) in
      make.top.equalTo(self.measureTypeImageView.snp.bottom).offset(screenSize.height * (15/iPhoneXHeight))
      make.right.equalTo(self.mainView.snp.right)
      make.left.equalTo(self.mainView.snp.left)
      make.height.width.equalTo(0.5)
    }
    
    dateTitleLabel.text = "Дата замера"
    dateTitleLabel.font = NewFonts.SFProDisplayBold16
    dateTitleLabel.snp.makeConstraints { (make) in
      make.top.equalTo(separatorViewSecond.snp.bottom).offset(screenSize.height * (24/iPhoneXHeight))
      make.left.equalTo(self.mainView.snp.left).offset(screenSize.height * (16/iPhoneXHeight))
    }
    
    dateValueButton.setTitle(DateFormatter.sharedDateFormatter.string(from: viewModel!.newMeasurementDate), for: .normal)
    dateValueButton.titleLabel?.font = NewFonts.SFProDisplayBold16
    dateValueButton.snp.makeConstraints { (make) in
      make.top.equalTo(separatorViewSecond.snp.bottom).offset(screenSize.height * (20/iPhoneXHeight))
      make.right.equalTo(self.mainView.snp.right).offset(screenSize.height * (-16/iPhoneXHeight))
      dateValueButton.addTarget(self, action: #selector(showPicker), for: .touchUpInside)
      
    }
    
    let separatorViewThird = UIView()
    separatorViewThird.backgroundColor = .separatorGray
    mainView.addSubview(separatorViewThird)
    separatorViewThird.snp.makeConstraints { (make) in
      make.top.equalTo(self.dateTitleLabel.snp.bottom).offset(screenSize.height * (24/iPhoneXHeight))
      make.right.equalTo(self.mainView.snp.right)
      make.left.equalTo(self.mainView.snp.left)
      make.height.width.equalTo(0.5)
    }
    
    valueTextField.placeholder = "Введите данные"
    valueTextField.backgroundColor = .textFieldBackgroundGrey
    valueTextField.delegate = self
    valueTextField.keyboardType = .decimalPad
    let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: self.valueTextField.frame.height))
    valueTextField.leftView = paddingView
    valueTextField.leftViewMode = .always
    valueTextField.snp.makeConstraints { (make) in
      make.top.equalTo(separatorViewThird.snp.bottom).offset(screenSize.height * (19/iPhoneXHeight))
      make.left.equalTo(self.mainView.snp.left).offset(screenSize.height * (16/iPhoneXHeight))
      make.width.equalTo(screenSize.height * (239/iPhoneXHeight))
      make.height.equalTo(screenSize.height * (64/iPhoneXHeight))
    }
    
    let separatorVertical = UIView()
    separatorVertical.backgroundColor = .separatorGray
    mainView.addSubview(separatorVertical)
    separatorVertical.snp.makeConstraints { (make) in
      make.top.equalTo(self.valueTextField.snp.top)
      make.bottom.equalTo(self.valueTextField.snp.bottom)
      make.width.equalTo(0.5)
      make.left.equalTo(self.valueTextField.snp.right)
    }
    
    let unitView = UIView()
    unitView.backgroundColor = .textFieldBackgroundGrey
    mainView.addSubview(unitView)
    unitView.snp.makeConstraints { (make) in
      make.top.equalTo(self.valueTextField.snp.top)
      make.bottom.equalTo(self.valueTextField.snp.bottom)
      make.left.equalTo(separatorVertical.snp.right)
      make.right.equalTo(self.mainView.snp.right).offset(screenSize.height * (-16/iPhoneXHeight))
    }
    
    unitView.addSubview(unitsLabel)
    unitsLabel.text = viewModel!.measureUnits[viewModel!.newMeasurementId]
    unitsLabel.font = NewFonts.SFProDisplayRegular16
    unitsLabel.snp.makeConstraints { (make) in
      make.centerX.equalTo(unitView.snp.centerX)
      make.centerY.equalTo(unitView.snp.centerY)
    }
    
    
    saveButton.titleLabel?.font = NewFonts.SFProDisplayBold16
    saveButton.setTitleColor(UIColor.white, for: .normal)
    saveButton.setTitle("Сохранить", for: .normal)
    saveButton.setBackgroundColor(color: UIColor.newBlue, forState: .normal)
    saveButton.layer.cornerRadius = screenSize.height * (16/iPhoneXHeight)
    saveButton.layer.masksToBounds = true
    saveButton.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
    saveButton.snp.makeConstraints { (make) in
      make.top.equalTo(self.mainView.snp.bottom).offset(screenSize.height * (30/iPhoneXHeight))
      make.left.equalTo(mainView.snp.left)
      make.right.equalTo(self.mainView.snp.right)
      make.height.equalTo(screenSize.height * (54/iPhoneXHeight))
    }
    closeButton.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
  }
  
  @objc func signInButtonAction(_ sender: UIButton) {
  }
  
  
  @objc func saveAction(_ sender: UIButton) {

    //IAP uncomment
    //  if InAppPurchasesService.shared.currentSubscription == nil && viewModel?.selectedMeasurements.count > 2 {
        let destinationVC = UIStoryboard(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "IAPViwController") as! IAPViewController
        destinationVC.presenter = self.comunityPresenter.createIAPPresenter(for: destinationVC)
        self.present(destinationVC, animated: true, completion: nil)
//      } else {
//        if let value = valueTextField.text!.toDouble() {
//          SwiftRater.incrementSignificantUsageCount()
//          viewModel!.saveMeasure(value: value, date: self.viewModel!.newMeasurementDate)
//          self.dismiss(animated: true, completion: nil)
//        }
//      }
    
  }
  
  @objc func closeButtonAction(_ sender: UIButton) {
    self.dismiss(animated: true, completion: nil)
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    guard CharacterSet(charactersIn: "1234567890.,").isSuperset(of: CharacterSet(charactersIn: string)) else {
      return false
    }
    if string == "." && textField.text!.contains(".") {
      return false
    }
    if string == "," && textField.text!.contains(",") {
      return false
    }
    if string == "." && textField.text!.isEmpty {
      return false
    }
    if string == "," && textField.text!.isEmpty {
      return false
    }
    return true
  }
  
  @objc func showPicker() {
    
    DatePickerDialog(buttonColor: lightBlue_).show("Выбери дату", doneButtonTitle: "Выбрать", cancelButtonTitle: "Отменить", datePickerMode: .date) {
      (date, int) -> Void in
      if date != nil {
        self.dateValueButton.setTitle(date?.dateString(), for: .normal)
        self.viewModel!.newMeasurementDate = date!
      }
    }
  }
  
}

extension NewMeasurementViewController: CommunityListViewProtocol{
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
