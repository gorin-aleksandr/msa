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
  var currentUser: UserVO? {
    return AuthModule.currUser
  }
  
  init() {}
  
  func fetchMySportsmans(success: @escaping ()->(),failure: @escaping (String)->()) {
    dataLoader.loadAllUsers { [weak self] (users, error) in
      if let error = error {
        Errors.handleError(error, completion: { [weak self] message in
          if let _ = error as? MSAError {
            //self?.view.setErrorViewHidden(false)
            failure(message)
          } else {
            guard let `self` = self else { return }
            //  self.view.showGeneralAlert()
            failure(message)
          }
          //self?.view.stopLoadingViewState()
          
        })
      } else {
        self!.users = users.filter { $0.trainerId == self!.currentUser!.id }
        success()
      }
    }
  }
  
  func mySportsmanCell(_ tableView: UITableView, _ indexPath: IndexPath) -> SportsmanTableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: SportsmanTableViewCell.identifier) as! SportsmanTableViewCell
    let user = users[indexPath.row]
    cell.nameLabel.text = "\(user.firstName ?? "") \(user.lastName ?? "")"
    cell.descriptionLabel.text = user.purpose
    if let url = user.avatar {
      cell.logoImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named: "avatar-placeholder"), options: .allowInvalidSSLCertificates, completed: nil)
    } else {
      cell.logoImageView.image = UIImage(named: "avatar-placeholder")
    }
    return cell
  }
  
}
