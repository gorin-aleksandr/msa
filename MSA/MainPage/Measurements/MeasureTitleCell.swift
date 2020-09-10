//
//  DateMeasurementsTableViewCell.swift
//  MSA
//
//  Created by Nik on 08.09.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit

class MeasureTitleCell: UITableViewCell {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var iconImageView: UIImageView!

  static let identifier = "MeasureTitleCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

  func setupUI() {
    titleLabel.font = NewFonts.SFProDisplayRegular12
    titleLabel.textColor = UIColor.newBlack
    
    iconImageView.image = UIImage(named: "Ellipse 14")
    iconImageView.snp.makeConstraints { (make) in
         make.centerY.equalTo(self.contentView.snp.centerY)
        make.left.equalTo(self.contentView.snp.left).offset(screenSize.height * (16/iPhoneXHeight))
         make.height.width.equalTo(screenSize.height * (16/iPhoneXHeight))
    }
    
    titleLabel.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.contentView.snp.centerY)
      make.left.equalTo(self.iconImageView.snp.right).offset(screenSize.height * (12/iPhoneXHeight))
    }
    
  }
}
