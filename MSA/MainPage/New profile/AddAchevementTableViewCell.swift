//
//  AddAchevementTableViewCell.swift
//  MSA
//
//  Created by Nik on 03.09.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit

class AddAchevementTableViewCell: UITableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var editButton: UIButton!
  @IBOutlet weak var mainView: UIView!

  static let identifier = "AddAchevementTableViewCell"
  
  override func awakeFromNib() {
    super.awakeFromNib()
    nameLabel.font = NewFonts.SFProDisplayBold16
    nameLabel.textColor = UIColor.newBlack
    mainView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.00)

    setupUI()
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
       nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.mainView.snp.top).offset(screenSize.height * (16/iPhoneXHeight))
            make.left.equalTo(self.mainView.snp.left).offset(screenSize.width * (16/iPhoneXWidth))
       }
  
       editButton.snp.makeConstraints { (make) in
       make.centerY.equalTo(self.mainView.snp.centerY)
       make.right.equalTo(self.mainView.snp.right).offset(screenSize.width * (-12/iPhoneXWidth))
       make.width.height.equalTo(screenSize.height * (24/iPhoneXHeight))
       }
  }
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
}
