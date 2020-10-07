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
  var viewModel = ProfileViewModel() {
    didSet {
      self.viewModel.reloadAchievementsTable = {
        self.fetchAchievements()
      }
    }
  }
  
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
    fetchAchievements()
  }
  
  func fetchAchievements() {
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
      let cell = tableView.dequeueReusableCell(withIdentifier: SkillTableViewCell.identifier, for: indexPath) as! SkillTableViewCell
      let achieve = viewModel.selectedAchievements[indexPath.row]
      cell.nameLabel.text = achieve.name
      cell.descriptionLabel.text = achieve.year
      print("Rank = \(achieve.rank) Achieve( = \(achieve.achieve)")
      cell.achievementLabel.text = achieve.rank != "" ? achieve.rank : achieve.achieve
      cell.editButton.isHidden = viewModel.selectedUser != nil ? true : false
      cell.editButton.tag = indexPath.section
      cell.editButton.imageView?.tag = indexPath.row
      cell.selectionStyle = .none
      cell.editButton.addTarget(self, action: #selector(editButtonAction(_:)), for: .touchUpInside)
      return cell
    }
    
    if indexPath.section == 1 && indexPath.row != viewModel.selectedEducation.count {
      let cell = tableView.dequeueReusableCell(withIdentifier: SkillTableViewCell.identifier, for: indexPath) as! SkillTableViewCell
      let achieve = viewModel.selectedEducation[indexPath.row]
      cell.nameLabel.text = achieve.name
      cell.descriptionLabel.text = "\(achieve.yearFrom) - \(achieve.yearTo)"
      cell.editButton.isHidden = viewModel.selectedUser != nil ? true : false
      cell.achievementLabel.text = ""
      cell.selectionStyle = .none
      cell.editButton.tag = indexPath.section
      cell.editButton.imageView?.tag = indexPath.row
      cell.nameLabel.snp.makeConstraints { (make) in
        make.top.equalTo(cell.mainView.snp.top).offset(screenSize.height * (16/iPhoneXHeight))
        make.left.equalTo(cell.mainView.snp.left).offset(screenSize.width * (16/iPhoneXWidth))
        make.right.equalTo(cell.editButton.snp.left).offset(screenSize.width * (-5/iPhoneXWidth))
      }
      cell.editButton.addTarget(self, action: #selector(editButtonAction(_:)), for: .touchUpInside)
      return cell
    }
    
    if indexPath.section == 2 && indexPath.row != viewModel.selectedCertificates.count{
      let cell = tableView.dequeueReusableCell(withIdentifier: SkillTableViewCell.identifier, for: indexPath) as! SkillTableViewCell
      let achieve = viewModel.selectedCertificates[indexPath.row]
      cell.nameLabel.text = achieve.name
      cell.achievementLabel.text = ""
      cell.descriptionLabel.text = ""
      cell.editButton.isHidden = viewModel.selectedUser != nil ? true : false
      cell.selectionStyle = .none
      cell.editButton.tag = indexPath.section
      cell.editButton.imageView?.tag = indexPath.row
      cell.achievementLabel.text = ""
      // cell.editButton.addTarget(self, action: #selector(editButtonAction(_:)), for: .touchUpInside)
      return cell
    }
    
    let cell = tableView.dequeueReusableCell(withIdentifier: AddAchevementTableViewCell.identifier) as! AddAchevementTableViewCell
    if indexPath.section == 0 {
      cell.nameLabel.text = "Добавить достижение"
    } else if indexPath.section == 1 {
      cell.nameLabel.text = "Добавить образование"
    } else {
      cell.nameLabel.text = "Добавить сертификацию"
    }
    cell.selectionStyle = .none
    return cell
  }
  
  @objc func editButtonAction(_ sender: UIButton) {
    presentEditSheet(section: sender.tag, row: sender.imageView!.tag)
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let vc = newProfileStoryboard.instantiateViewController(withIdentifier: "UserSettingsViewController") as! UserSettingsViewController
    vc.viewModel = viewModel
    switch indexPath.section {
      case 0:
        if indexPath.row == viewModel.selectedAchievements.count {
          let ac = UIAlertController(title: "Выбери тип достижения", message: nil, preferredStyle: .actionSheet)
          let rankAction = UIAlertAction(title: "Звание", style: .default, handler: { (action) in
            vc.viewModel!.editSettingsControllerType = .newAchievement
            vc.viewModel!.achevementType = .rank
            self.navigationController?.pushViewController(vc, animated: true)
          })
          let competitionAction = UIAlertAction(title: "Соревнование", style: .default, handler: { (action) in
            vc.viewModel!.editSettingsControllerType = .newAchievement
            vc.viewModel!.achevementType = .achieve
            self.navigationController?.pushViewController(vc, animated: true)
            
          })
          let cancelAction = UIAlertAction(title: "Отменить", style: .cancel, handler: { (action) in
          })
          ac.addAction(rankAction)
          ac.addAction(competitionAction)
          ac.addAction(cancelAction)
          DispatchQueue.main.async {
            self.present(ac, animated: true, completion: nil)
          }
      }
      //          else {
      //            vc.viewModel!.currentAchievement = viewModel.selectedAchievements[indexPath.row]
      //            vc.viewModel!.editSettingsControllerType = .editAchievement
      //            if vc.viewModel!.currentAchievement.rank != nil {
      //              vc.viewModel!.achevementType = .rank
      //            } else {
      //              vc.viewModel!.achevementType = .achieve
      //            }
      //            self.navigationController?.pushViewController(vc, animated: true)
      //
      //          }
      
      case 1:
        if indexPath.row == viewModel.selectedEducation.count {
          vc.viewModel!.editSettingsControllerType = .newAchievement
          vc.viewModel!.achevementType = .education
          self.navigationController?.pushViewController(vc, animated: true)
      }
      //          else {
      //          vc.viewModel!.editSettingsControllerType = .editAchievement
      //          vc.viewModel!.achevementType = .education
      //          vc.viewModel!.currentEducation = viewModel.selectedEducation[indexPath.row]
      //        }
      case 2:
        if indexPath.row == viewModel.selectedCertificates.count {
          vc.viewModel!.editSettingsControllerType = .newAchievement
          vc.viewModel!.achevementType = .certificate
          self.navigationController?.pushViewController(vc, animated: true)
      }
      //           else {
      //           vc.viewModel!.editSettingsControllerType = .editAchievement
      //           vc.viewModel!.achevementType = .certificate
      //           vc.viewModel!.currentCertificates = viewModel.selectedCertificates[indexPath.row]
      //         }
      default:
        return
    }
  }
 
  func presentEditSheet(section: Int, row: Int) {
    let actionSheetController = UIAlertController(title: "Выберите действие", message: nil, preferredStyle: .actionSheet)
    let updateActionButton = UIAlertAction(title: "Изменить", style: .default) { action -> Void in
      print("Изменить")
      let vc = newProfileStoryboard.instantiateViewController(withIdentifier: "UserSettingsViewController") as! UserSettingsViewController
      vc.viewModel = self.viewModel
      if section == 0 {
        vc.viewModel!.currentAchievement = self.viewModel.selectedAchievements[row]
        vc.viewModel!.editSettingsControllerType = .editAchievement
        if self.viewModel.selectedAchievements[row].achieve != "" {
          vc.viewModel!.achevementType = .achieve
        } else {
          vc.viewModel!.achevementType = .rank
        }
      }
      if section == 1 {
        vc.viewModel!.currentEducation = self.viewModel.selectedEducation[row]
        vc.viewModel!.editSettingsControllerType = .editAchievement
        vc.viewModel!.achevementType = .education
      }
      if section == 2 {
        vc.viewModel!.currentCertificates = self.viewModel.selectedCertificates[row]
        vc.viewModel!.editSettingsControllerType = .editAchievement
        vc.viewModel!.achevementType = .certificate

      }
      self.navigationController?.pushViewController(vc, animated: true)
    }
    
    let deleteActionButton = UIAlertAction(title: "Удалить", style: .destructive) { action -> Void in
      print("Удалить")
      if section == 0 {
        SVProgressHUD.show()
        self.viewModel.removeAchievement(index: row) { (value) in
          SVProgressHUD.dismiss()
          self.tableView.reloadData()
        }
      }
      if section == 1 {
        SVProgressHUD.show()
        self.viewModel.removeEducation(index: row) { (value) in
          SVProgressHUD.dismiss()
          self.tableView.reloadData()
        }
      }
      if section == 2 {
        SVProgressHUD.show()
        self.viewModel.removeCertificate(index: row) { (value) in
          SVProgressHUD.dismiss()
          self.tableView.reloadData()
        }
      }
    }
    let cancelActionButton = UIAlertAction(title: "Отмена", style: .cancel) { action -> Void in
      print("Отмена")
    }
    actionSheetController.addAction(updateActionButton)
    actionSheetController.addAction(deleteActionButton)
    actionSheetController.addAction(cancelActionButton)
    self.present(actionSheetController, animated: true, completion: nil)
  }
}
