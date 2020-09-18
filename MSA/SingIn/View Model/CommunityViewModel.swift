//
//  CommunityViewModel.swift
//  MSA
//
//  Created by Nik on 04.09.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit

class CommunityViewModel {
  private var dataLoader = UserDataManager()
  var users: [UserVO] = []
  var sortedUsers: [UserVO] = []
  var currentUser: UserVO? {
    return AuthModule.currUser
  }
  var selectedUser: UserVO?
  
  init() {}
  
  
  func sortUser(value: String) {
    if value != "" {
      sortedUsers = users.filter{ "\($0.firstName ?? "") \($0.lastName ?? "")".contains(value) }
    } else {
      sortedUsers = users
    }
  }
  
  func fetchSportsmans(success: @escaping ()->(),failure: @escaping (String)->()) {
    dataLoader.loadAllUsers { [weak self] (users, error) in
      if let error = error {
        Errors.handleError(error, completion: { [weak self] message in
          if let _ = error as? MSAError {
            failure(message)
          } else {
            guard let `self` = self else { return }
            failure(message)
          }
        })
      } else {
        let trainerId = self!.selectedUser?.id != nil ? self!.selectedUser!.id : self!.currentUser!.id
        self!.users = users.filter { $0.trainerId == trainerId }
        self!.users = self!.users.sorted { $0.lastName < $1.lastName }
        self!.sortedUsers = self!.users
        success()
      }
    }
  }
  
  func mySportsmanCell(_ tableView: UITableView, _ indexPath: IndexPath) -> SportsmanTableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: SportsmanTableViewCell.identifier) as! SportsmanTableViewCell
    let user = sortedUsers[indexPath.row]
    cell.nameLabel.text = "\(user.lastName ?? "") \(user.firstName ?? "")"
    cell.descriptionLabel.text = user.purpose
    if let url = user.avatar {
      cell.logoImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "avatar-placeholder"), options: .allowInvalidSSLCertificates, completed: nil)
    } else {
      cell.logoImageView.image = UIImage(named: "avatar-placeholder")
    }
    cell.selectionStyle = .none
    return cell
  }
  
}
