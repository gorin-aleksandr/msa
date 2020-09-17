//
//  SkillTableViewCell.swift
//  MSA
//
//  Created by Nik on 02.09.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit

class SkillTableViewCell: UITableViewCell {

  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var achievementLabel: UILabel!
  @IBOutlet weak var editButton: UIButton!
  @IBOutlet weak var mainView: UIView!

  static let identifier = "SkillTableViewCell"
  
    override func awakeFromNib() {
        super.awakeFromNib()
      nameLabel.font = NewFonts.SFProDisplayBold13
      nameLabel.textColor = UIColor.newBlack
      descriptionLabel.font = NewFonts.SFProDisplayRegular12
      descriptionLabel.textColor = UIColor.textGrey
      achievementLabel.font = NewFonts.SFProDisplayBold13
      achievementLabel.textColor = UIColor.newBlack
      mainView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.00)
      setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
  
  func setupUI() {
    mainView.cornerRadius = screenSize.height * (8/iPhoneXHeight)
    mainView.snp.makeConstraints { (make) in
      make.top.equalTo(self.contentView.snp.top).offset(screenSize.height * (4/iPhoneXHeight))
      make.bottom.equalTo(self.contentView.snp.bottom).offset(screenSize.height * (-4/iPhoneXHeight))
      make.left.equalTo(self.contentView.snp.left).offset(screenSize.width * (16/iPhoneXWidth))
      make.right.equalTo(self.contentView.snp.right).offset(screenSize.width * (-16/iPhoneXWidth))
       }
    nameLabel.numberOfLines = 0
    descriptionLabel.textAlignment = .center
    nameLabel.snp.makeConstraints { (make) in
         make.top.equalTo(self.mainView.snp.top).offset(screenSize.height * (16/iPhoneXHeight))
         make.left.equalTo(self.mainView.snp.left).offset(screenSize.width * (16/iPhoneXWidth))
    }
    descriptionLabel.numberOfLines = 0
    descriptionLabel.textAlignment = .center
    descriptionLabel.snp.makeConstraints { (make) in
         make.top.equalTo(self.nameLabel.snp.bottom).offset(screenSize.height * (2/iPhoneXHeight))
         make.left.equalTo(self.nameLabel.snp.left)
    }
    editButton.snp.makeConstraints { (make) in
    make.centerY.equalTo(self.mainView.snp.centerY)
    make.right.equalTo(self.mainView.snp.right).offset(screenSize.width * (-12/iPhoneXWidth))
    make.width.height.equalTo(screenSize.height * (24/iPhoneXHeight))
    }
    achievementLabel.numberOfLines = 0
    achievementLabel.textAlignment = .right
    achievementLabel.snp.makeConstraints { (make) in
    //make.centerY.equalTo(self.contentView.snp.centerY)
    make.top.equalTo(self.contentView.snp.top).offset(screenSize.height * (5/iPhoneXHeight))
    make.bottom.equalTo(self.contentView.snp.bottom).offset(screenSize.height * (-5/iPhoneXHeight))
    make.right.equalTo(self.editButton.snp.left).offset(screenSize.width * (-16/iPhoneXWidth))
    make.left.equalTo(self.nameLabel.snp.right).offset(screenSize.width * (10/iPhoneXWidth))

    }
  }

}
