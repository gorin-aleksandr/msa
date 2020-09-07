//
//  UserAchievementsViewController.swift
//  MSA
//
//  Created by Nik on 31.08.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit

class UserAchievementsViewController: UIViewController {
  @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      setupUI()
    }
  
  func setupUI() {
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(UINib(nibName: "UserInfoTableHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "UserInfoTableHeaderView")

  }


}

// MARK: - TableViewDataSource
extension UserAchievementsViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
     let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "UserInfoTableHeaderView") as! UserInfoTableHeaderView
    switch section {
      case 0:
        headerView.titleLabel.text = "Специализация"
        headerView.logoImageView.image = UIImage(named: "noun_personaltrainer")
      case 1:
        headerView.titleLabel.text = "Спортивные достижения"
        headerView.logoImageView.image = UIImage(named: "noun_champion")
      case 2:
        headerView.titleLabel.text = "Образование"
        headerView.logoImageView.image = UIImage(named: "noun_education")
      case 3:
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
    return 4
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 81//viewModel!.heightForMenuCellController(indexPath)
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3 //viewModel!.numberOfRowsInSectionForMenuOrder(section)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row != 2 {
      let cell = tableView.dequeueReusableCell(withIdentifier: SkillTableViewCell.identifier) as! SkillTableViewCell
      cell.nameLabel.text = "Биатлон"
      cell.descriptionLabel.text = "Декабрь 1995"
      cell.descriptionLabel.text = "Декабрь 1995"
      cell.achievementLabel.text = "Мастер спорта"
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: AddAchevementTableViewCell.identifier) as! AddAchevementTableViewCell
        cell.nameLabel.text = "Добавить достижение"
        return cell
    }

  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //viewModel!.selectMenu(indexPath)
    if indexPath.row == 1 {
      let vc = newProfileStoryboard.instantiateViewController(withIdentifier: "UserSettingsViewController") as! UserSettingsViewController
      vc.viewModel = ProfileViewModel()
      vc.viewModel!.editSettingsControllerType = .newAchievement
      self.navigationController?.pushViewController(vc, animated: true)
    }
  }
}
