//
//  SkillTableViewCell.swift
//  MSA
//
//  Created by Nik on 02.09.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit
import SnapKit

class SportsmanTableViewCell: UITableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var logoImageView: UIImageView!
  @IBOutlet weak var mainView: UIView!
  
  static let identifier = "SportsmanTableViewCell"
  
  override func awakeFromNib() {
    super.awakeFromNib()
    nameLabel.font = NewFonts.SFProDisplayBold14
    nameLabel.textColor = UIColor.newBlack
    descriptionLabel.font = NewFonts.SFProDisplayRegular12
    descriptionLabel.textColor = UIColor.textGrey
    logoImageView.layer.cornerRadius = logoImageView.frame.height/2
    mainView.backgroundColor = UIColor.emailPasswordTextFieldGrey
    mainView.cornerRadius = screenSize.height * (16/screenSize.height)
    
    logoImageView.snp.makeConstraints { (make) in
      make.height.equalTo(screenSize.height * (50/screenSize.height))
      make.width.equalTo(screenSize.height * (50/screenSize.height))
      make.centerY.equalTo(mainView.snp.centerY)
      make.left.equalTo(mainView.snp.left).offset(screenSize.height * (20/screenSize.height))
    }
    
    mainView.snp.makeConstraints { (make) in
      make.top.equalTo(contentView.snp.top).offset(screenSize.height * (4/screenSize.height))
      make.bottom.equalTo(contentView.snp.bottom).offset(screenSize.height * (4/screenSize.height))
      make.left.equalTo(contentView.snp.left).offset(screenSize.height * (16/screenSize.height))
      make.right.equalTo(contentView.snp.right).offset(screenSize.height * (-16/screenSize.height))
    }
    
    nameLabel.snp.makeConstraints { (make) in
      make.top.equalTo(mainView.snp.top).offset(screenSize.height * (19/screenSize.height))
      make.left.equalTo(logoImageView.snp.right).offset(screenSize.height * (12/screenSize.height))
      make.right.equalTo(contentView.snp.right).offset(10)
    }
    
    descriptionLabel.snp.makeConstraints { (make) in
      make.top.equalTo(nameLabel.snp.bottom).offset(screenSize.height * (2/screenSize.height))
      make.left.equalTo(nameLabel.snp.left)
      make.right.equalTo(contentView.snp.right).offset(10)
    }
    
    
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
}
