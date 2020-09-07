//
//  HomeProfileCollectionViewCell.swift
//  MSA
//
//  Created by Nik on 17.08.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit

class HomeProfileCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var rightDirectionImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    static let identifier = "HomeProfileCollectionViewCell"
    
    override func awakeFromNib() {
      super.awakeFromNib()
      setupUI()
    }
    
    func setupUI() {
      titleLabel.font = NewFonts.SFProDisplayBold24
      titleLabel.textColor = UIColor.newBlack
      logoImageView.snp.makeConstraints { (make) in
        make.centerY.equalTo(self.contentView.snp.centerY)
        make.left.equalTo(self.contentView.snp.left).offset(screenSize.height * (16/iPhoneXHeight))
        make.height.width.equalTo(screenSize.height * (48/iPhoneXHeight))
      }
      
      titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(logoImageView.snp.centerY)
            make.left.equalTo(logoImageView.snp.right).offset(screenSize.height * (16/iPhoneXHeight))
            make.right.equalTo(self.contentView.snp.right).offset(screenSize.height * (-35/iPhoneXHeight))
      }
      
      rightDirectionImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(logoImageView.snp.centerY)
            make.right.equalTo(self.contentView.snp.right).offset(screenSize.height * (-27/iPhoneXHeight))
            make.height.equalTo(screenSize.height * (13/iPhoneXHeight))
            make.width.equalTo(screenSize.height * (8/iPhoneXHeight))
      }
      
    }
}
