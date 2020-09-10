//
//  DateMeasurementsTableViewCell.swift
//  MSA
//
//  Created by Nik on 08.09.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit

class MeasureTypeCell: UITableViewCell {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var iconImageView: UIImageView!
  @IBOutlet weak var selectedIconImageView: UIImageView!

  static let identifier = "MeasureTypeCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }


  func setupUI() {
    titleLabel.font = NewFonts.SFProDisplayBold16
    titleLabel.textColor = UIColor.newBlack
    
    iconImageView.snp.makeConstraints { (make) in
         make.centerY.equalTo(self.contentView.snp.centerY)
         make.left.equalTo(self.contentView.snp.left).offset(screenSize.height * (16/iPhoneXHeight))
         make.height.width.equalTo(screenSize.height * (48/iPhoneXHeight))
    }
    
    selectedIconImageView.image = UIImage(named: "Frame 2282")
    selectedIconImageView.snp.makeConstraints { (make) in
           make.right.equalTo(iconImageView.snp.right)
           make.bottom.equalTo(iconImageView.snp.bottom)
           make.height.width.equalTo(screenSize.height * (20/iPhoneXHeight))
      }
    
    titleLabel.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.contentView.snp.centerY)
      make.left.equalTo(self.iconImageView.snp.right).offset(screenSize.height * (20/iPhoneXHeight))
    }
    
  }
}
