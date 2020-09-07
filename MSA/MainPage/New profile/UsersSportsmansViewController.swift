//
//  UserAchievementsViewController.swift
//  MSA
//
//  Created by Nik on 31.08.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit
import SVProgressHUD

class UsersSportsmansViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  var viewModel: CommunityViewModel = CommunityViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillDisappear(true)
    SVProgressHUD.show()
    viewModel.fetchMySportsmans(success: {
      SVProgressHUD.dismiss()
      self.tableView.reloadData()
    }) { error in
      SVProgressHUD.dismiss()
    }
  }
  
  func setupUI() {
    tableView.dataSource = self
    tableView.delegate = self
    tableView.separatorStyle = .none
  }
  
  
}

// MARK: - TableViewDataSource
extension UsersSportsmansViewController: UITableViewDataSource, UITableViewDelegate {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return screenSize.height * (78/screenSize.height)
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.users.count //viewModel!.numberOfRowsInSectionForMenuOrder(section)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return viewModel.mySportsmanCell(tableView,indexPath)
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //viewModel!.selectMenu(indexPath)
  }
}
