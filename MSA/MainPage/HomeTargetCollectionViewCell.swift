//
//  HomeTargetCollectionViewCell.swift
//  MSA
//
//  Created by Nik on 17.08.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit

class HomeTargetCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var leftImageView: UIImageView!
  @IBOutlet weak var rightImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  static let identifier = "HomeTargetCollectionViewCell"

  override func awakeFromNib() {
      super.awakeFromNib()
      setupUI()
  }
  
  func setupUI() {
    leftImageView.snp.makeConstraints { (make) in
      make.left.equalTo(self.contentView.snp.left).offset(screenSize.height * (18/iPhoneXHeight))
      make.height.width.equalTo(screenSize.height * (16/iPhoneXHeight))
      make.centerY.equalTo(self.contentView.snp.centerY)
    }
    
    titleLabel.snp.makeConstraints { (make) in
       make.left.equalTo(leftImageView.snp.right).offset(screenSize.height * (16/iPhoneXHeight))
       make.right.equalTo(self.contentView.snp.right).offset(screenSize.height * (-56/iPhoneXHeight))
       make.centerY.equalTo(self.contentView.snp.centerY)
     }
    
    rightImageView.snp.makeConstraints { (make) in
      make.right.equalTo(self.contentView.snp.right)
      make.centerY.equalTo(self.contentView.snp.centerY)
      make.height.equalTo(screenSize.height * (54/iPhoneXHeight))
      make.width.equalTo(screenSize.height * (40/iPhoneXHeight))
    }
    
  }
}
