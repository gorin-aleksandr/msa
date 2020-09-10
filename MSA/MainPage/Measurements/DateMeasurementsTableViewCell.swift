//
//  DateMeasurementsTableViewCell.swift
//  MSA
//
//  Created by Nik on 08.09.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit

class DateMeasurementsTableViewCell: UITableViewCell {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var leftButton: UIButton!
  @IBOutlet weak var rightButton: UIButton!
  @IBOutlet weak var calendarButton: UIButton!
  static let identifier = "DateMeasurementsTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

  func setupUI() {
    titleLabel.font = NewFonts.SFProDisplayBold20
    titleLabel.textColor = UIColor.newBlack
   
    titleLabel.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.contentView.snp.centerY)
      make.left.equalTo(self.contentView.snp.left).offset(screenSize.height * (16/iPhoneXHeight))
    }
    
    calendarButton.snp.makeConstraints { (make) in
         make.centerY.equalTo(self.contentView.snp.centerY)
         make.left.equalTo(titleLabel.snp.right).offset(screenSize.height * (11/iPhoneXHeight))
         make.height.width.equalTo(screenSize.height * (36/iPhoneXHeight))
       }
    
    rightButton.snp.makeConstraints { (make) in
    make.right.equalTo(self.contentView.snp.right).offset(screenSize.height * (-25/iPhoneXHeight))
      make.centerY.equalTo(self.contentView.snp.centerY)
      make.height.equalTo(screenSize.height * (28/iPhoneXHeight))
      make.width.equalTo(screenSize.height * (28/iPhoneXHeight))
    }
    
     leftButton.snp.makeConstraints { (make) in
       make.right.equalTo(rightButton.snp.right).offset(screenSize.height * (-30/iPhoneXHeight))
         make.centerY.equalTo(self.contentView.snp.centerY)
         make.height.equalTo(screenSize.height * (28/iPhoneXHeight))
         make.width.equalTo(screenSize.height * (28/iPhoneXHeight))
       }
    
  }
  
}
