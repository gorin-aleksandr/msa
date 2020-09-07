//
//  UserSettingsViewController.swift
//  MSA
//
//  Created by Nik on 26.08.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit

class UserSettingsViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var nextButton: UIButton!

  var viewModel: ProfileViewModel?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Данные о вас"
        setupUI()
    }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    navigationController?.setNavigationBarHidden(false, animated: true)
    let backButton = UIBarButtonItem(image: UIImage(named: "backIcon"), style: .plain, target: self, action: #selector(self.backAction))
    self.navigationItem.leftBarButtonItem = backButton
    self.navigationController?.navigationBar.tintColor = .newBlack
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
    nextButton.addTarget(self, action: #selector(signButtonAction), for: .touchUpInside)
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
  
  @objc func signButtonAction(_ sender: UIButton) {

  }
  
  @objc func backAction() {
    self.navigationController?.popViewController(animated: true)
  }
  

  
}

// MARK: - TableViewDataSource
extension UserSettingsViewController: UITableViewDataSource, UITableViewDelegate {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return screenSize.height * (70/iPhoneXHeight)
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel!.numberOfRowInSectionForDataController()
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if viewModel!.editSettingsControllerType == .userInfo {
      return viewModel!.editUserCell(indexPath: indexPath, tableView: tableView)
    } else {
      return viewModel!.editUserCell(indexPath: indexPath, tableView: tableView)
    }
    
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //viewModel!.selectMenu(indexPath)
  }
}
