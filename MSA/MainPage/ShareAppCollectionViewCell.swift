//
//  ShareAppCollectionViewCell.swift
//  MSA
//
//  Created by Nik on 05.10.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit

import UIKit

class ShareAppCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var mainView: UIView!
  @IBOutlet weak var shareButtonView: UIView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var notNowButton: UIButton!
  @IBOutlet weak var shareTextButton: UIButton!
  @IBOutlet weak var shareImageButton: UIButton!

  static let identifier = "ShareAppCollectionViewCell"

  override func awakeFromNib() {
      super.awakeFromNib()
      setupUI()
  }
  
  func setupUI() {
    mainView.backgroundColor = UIColor(red: 0.874, green: 0.912, blue: 0.962, alpha: 1)
    mainView.layer.cornerRadius = screenSize.height * (16/iPhoneXHeight)

    mainView.snp.makeConstraints { (make) in
      make.left.equalTo(self.contentView.snp.left)
      make.right.equalTo(self.contentView.snp.right)
      make.top.equalTo(self.contentView.snp.top)
      make.bottom.equalTo(self.contentView.snp.bottom)
    }
    
    titleLabel.text = ""
    titleLabel.font = NewFonts.SFProDisplaySemiBold14
    titleLabel.textColor = UIColor.newBlue
    titleLabel.numberOfLines = 0
    titleLabel.snp.makeConstraints { (make) in
      make.top.equalTo(self.mainView.snp.top).offset(screenSize.height * (16/iPhoneXHeight))
      make.left.equalTo(self.mainView.snp.left).offset(screenSize.width * (16/iPhoneXWidth))
      make.right.equalTo(self.mainView.snp.right).offset(screenSize.width * (-16/iPhoneXWidth))
    }
    
    notNowButton.setTitle("Не сейчас", for: .normal)
    notNowButton.titleLabel?.font = NewFonts.SFProDisplaySemiBold13
    notNowButton.setTitleColor(UIColor(red: 0.635, green: 0.702, blue: 0.8, alpha: 1), for: .normal)
    notNowButton.snp.makeConstraints { (make) in
      make.top.equalTo(self.titleLabel.snp.bottom).offset(screenSize.height * (8/iPhoneXHeight))
      make.left.equalTo(self.mainView.snp.left).offset(screenSize.width * (26/iPhoneXWidth))
      make.width.equalTo(screenSize.width * (110/iPhoneXWidth))
      make.height.equalTo(screenSize.height * (48/iPhoneXHeight))
    }
    
    shareButtonView.backgroundColor = .white
    shareButtonView.layer.cornerRadius = screenSize.height * (16/iPhoneXHeight)
    shareButtonView.snp.makeConstraints { (make) in
      make.top.equalTo(self.titleLabel.snp.bottom).offset(screenSize.height * (8/iPhoneXHeight))
      make.right.equalTo(self.mainView.snp.right).offset(screenSize.width * (-16/iPhoneXWidth))
      make.width.equalTo(screenSize.width * (155/iPhoneXWidth))
      make.height.equalTo(screenSize.height * (48/iPhoneXHeight))
    }
    
    shareTextButton.setTitle("Поделиться", for: .normal)
    shareTextButton.titleLabel?.font = NewFonts.SFProDisplayBold13
    shareTextButton.setTitleColor(UIColor.newBlue, for: .normal)
    shareTextButton.snp.makeConstraints { (make) in
        make.top.equalTo(self.shareButtonView.snp.top)
        make.left.equalTo(self.shareButtonView.snp.left)
        make.width.equalTo(screenSize.width * (110/iPhoneXWidth))
        make.height.equalTo(screenSize.height * (48/iPhoneXHeight))
    }
    
    shareImageButton.setBackgroundImage(UIImage(named: "share 1"), for: .normal)
    shareImageButton.setTitle("", for: .normal)
    shareImageButton.snp.makeConstraints { (make) in
        make.top.equalTo(self.shareButtonView.snp.top).offset(screenSize.height * (4/iPhoneXHeight))
        make.bottom.equalTo(self.shareButtonView.snp.bottom).offset(screenSize.height * (-4/iPhoneXHeight))
        make.right.equalTo(self.shareButtonView.snp.right).offset(screenSize.width * (-4/iPhoneXWidth))
        make.width.equalTo(screenSize.width * (40/iPhoneXWidth))
        make.height.equalTo(screenSize.height * (40/iPhoneXHeight))
    }
    
  }
}
