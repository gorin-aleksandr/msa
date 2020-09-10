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
  @IBOutlet weak var searchBar: UISearchBar!
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
    searchBar.delegate = self
    searchBar.snp.makeConstraints { (make) in
      make.top.equalTo(self.view.snp.top)
      make.right.equalTo(self.view.snp.right)
      make.left.equalTo(self.view.snp.left)
      make.height.equalTo(screenSize.height * (50/iPhoneXHeight))

    }
    tableView.snp.makeConstraints { (make) in
      make.top.equalTo(searchBar.snp.bottom)
      make.bottom.equalTo(self.view.snp.bottom)
      make.right.equalTo(self.view.snp.right)
      make.left.equalTo(self.view.snp.left)
    }
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
    return viewModel.sortedUsers.count 
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    return viewModel.mySportsmanCell(tableView,indexPath)
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let nextViewController = profileStoryboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
    nextViewController.viewModel.selectedUser = viewModel.sortedUsers[indexPath.row]
    self.navigationController?.pushViewController(nextViewController, animated: true)

  }
}

extension UsersSportsmansViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
      print("searchText \(searchText)")
    viewModel.sortUser(value: searchText)
    self.tableView.reloadData()
  }

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
      print("searchText \(searchBar.text)")
  }
}