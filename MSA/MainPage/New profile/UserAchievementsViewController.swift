//
//  UserAchievementsViewController.swift
//  MSA
//
//  Created by Nik on 31.08.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit
import SVProgressHUD

class UserAchievementsViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!
  var viewModel = ProfileViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    setupUI()
  }
  
  func setupUI() {
    tableView.dataSource = self
    tableView.delegate = self
    tableView.separatorStyle = .none
    tableView.tableFooterView = UIView()
    tableView.register(UINib(nibName: "UserInfoTableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "UserInfoTableHeaderView")
    let group = DispatchGroup()
    SVProgressHUD.show()
    group.enter()
    viewModel.fetchAchievements(completion: { sucess in
      group.leave()
    })
    group.enter()
    viewModel.fetchEducation(completion: { sucess in
      group.leave()
    })
    group.enter()
    viewModel.fetchCertificate(completion: { sucess in
      group.leave()
    })
    group.notify(queue: .main) {
      SVProgressHUD.dismiss()
      self.tableView.reloadData()
    }
  }
  
  
}

// MARK: - TableViewDataSource
extension UserAchievementsViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
    let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "UserInfoTableHeaderView") as! UserInfoTableHeaderView
    switch section {
      case 0:
        headerView.titleLabel.text = "Спортивные достижения"
        headerView.logoImageView.image = UIImage(named: "noun_champion")
      case 1:
        headerView.titleLabel.text = "Образование"
        headerView.logoImageView.image = UIImage(named: "noun_education")
      case 2:
        headerView.titleLabel.text = "Сертификация"
        headerView.logoImageView.image = UIImage(named: "noun_strong")
      default:
        headerView.titleLabel.text = "Сертификация"
      
    }
    return headerView
    
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 63
  }
  
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 3
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return CGFloat(viewModel.heightForRow(indexPath: indexPath))
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.numberOfRowsInSectionForAchevements(section: section)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if indexPath.section == 0 && indexPath.row != viewModel.selectedAchievements.count {
      let cell = tableView.dequeueReusableCell(withIdentifier: SkillTableViewCell.identifier) as! SkillTableViewCell
      let achieve = viewModel.selectedAchievements[indexPath.row]
      cell.nameLabel.text = achieve.name
      cell.descriptionLabel.text = achieve.year
      cell.achievementLabel.text = achieve.rank
      cell.editButton.isHidden = viewModel.selectedUser != nil ? true : false
      cell.selectionStyle = .none
      return cell
    }
    
    if indexPath.section == 1 && indexPath.row != viewModel.selectedEducation.count {
      let cell = tableView.dequeueReusableCell(withIdentifier: SkillTableViewCell.identifier) as! SkillTableViewCell
      let achieve = viewModel.selectedEducation[indexPath.row]
      cell.nameLabel.text = achieve.name
      cell.descriptionLabel.text = "\(achieve.yearFrom) - \(achieve.yearTo)"
      cell.achievementLabel.text = ""
      cell.editButton.isHidden = viewModel.selectedUser != nil ? true : false
      cell.selectionStyle = .none
      cell.nameLabel.snp.makeConstraints { (make) in
             make.top.equalTo(cell.mainView.snp.top).offset(screenSize.height * (16/iPhoneXHeight))
             make.left.equalTo(cell.mainView.snp.left).offset(screenSize.width * (16/iPhoneXWidth))
             make.right.equalTo(cell.editButton.snp.left).offset(screenSize.width * (-5/iPhoneXWidth))
        }
      return cell
    }
    
    if indexPath.section == 2 && indexPath.row != viewModel.selectedCertificates.count{
      let cell = tableView.dequeueReusableCell(withIdentifier: SkillTableViewCell.identifier) as! SkillTableViewCell
      let achieve = viewModel.selectedCertificates[indexPath.row]
      cell.nameLabel.text = achieve.name
      cell.descriptionLabel.text = ""
      cell.achievementLabel.text = ""
      cell.editButton.isHidden = viewModel.selectedUser != nil ? true : false
      cell.selectionStyle = .none
      return cell
    }
    
    let cell = tableView.dequeueReusableCell(withIdentifier: AddAchevementTableViewCell.identifier) as! AddAchevementTableViewCell
    cell.nameLabel.text = "Добавить достижение"
    cell.editButton.addTarget(self, action: #selector(trainerButtonAction(_:)), for: .touchUpInside)

    cell.selectionStyle = .none
    return cell
  }
  
  @objc func trainerButtonAction(_ sender: UIButton) {
      print("add butom!")
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //viewModel!.selectMenu(indexPath)
      let vc = newProfileStoryboard.instantiateViewController(withIdentifier: "UserSettingsViewController") as! UserSettingsViewController
               vc.viewModel = ProfileViewModel()
      switch indexPath.section {
        case 0:
          if indexPath.row == viewModel.selectedAchievements.count {
            vc.viewModel!.editSettingsControllerType = .newAchievement
            vc.viewModel!.achevementType = .achieve
          } else {
            vc.viewModel!.editSettingsControllerType = .editAchievement
            vc.viewModel!.achevementType = .achieve
            vc.viewModel!.currentAchievement = viewModel.selectedAchievements[indexPath.row]
          }
        case 1:
          if indexPath.row == viewModel.selectedEducation.count {
          vc.viewModel!.editSettingsControllerType = .newAchievement
          vc.viewModel!.achevementType = .education
        } else {
          vc.viewModel!.editSettingsControllerType = .editAchievement
          vc.viewModel!.achevementType = .education
          vc.viewModel!.currentEducation = viewModel.selectedEducation[indexPath.row]
        }
        case 2:
           if indexPath.row == viewModel.selectedCertificates.count {
           vc.viewModel!.editSettingsControllerType = .newAchievement
           vc.viewModel!.achevementType = .certificate
         } else {
           vc.viewModel!.editSettingsControllerType = .editAchievement
           vc.viewModel!.achevementType = .certificate
           vc.viewModel!.currentCertificates = viewModel.selectedCertificates[indexPath.row]
         }
        default:
        return
      }
      self.navigationController?.pushViewController(vc, animated: true)

    
  }
}
