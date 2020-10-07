//
//  HomeCollectionViewCell.swift
//  MSA
//
//  Created by Nik on 17.08.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit

class HomeCollectionViewCell: UICollectionViewCell {
  @IBOutlet weak var logoImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  let hideView = UIView()
  
  static let identifier = "HomeCollectionViewCell"
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupUI()
  }
  
  override func prepareForReuse()
  {
      super.prepareForReuse()
      hideView.removeFromSuperview()
  }
  
  func addBluredView() {
    contentView.addSubview(hideView)
    hideView.backgroundColor = UIColor(red: 0.971, green: 0.973, blue: 0.975, alpha: 0.56)

    hideView.cornerRadius = screenSize.height * (10/iPhoneXHeight)
    hideView.snp.makeConstraints { (make) in
      make.left.equalTo(contentView.snp.left)
      make.right.equalTo(contentView.snp.right)
      make.top.equalTo(contentView.snp.top)
      make.bottom.equalTo(contentView.snp.bottom)
     }
  }
  
  func setupUI() {
    titleLabel.font = NewFonts.SFProDisplayBold14
    titleLabel.textColor = UIColor.newBlack

    descriptionLabel.font = NewFonts.SFProDisplayRegular12
    descriptionLabel.textColor = UIColor.newBlack
    
    logoImageView.snp.makeConstraints { (make) in
      make.left.equalTo(self.contentView.snp.left).offset(screenSize.height * (16/iPhoneXHeight))
      make.top.equalTo(self.contentView.snp.top).offset(screenSize.height * (16/iPhoneXHeight))
      make.height.width.equalTo(screenSize.height * (40/iPhoneXHeight))
    }
    titleLabel.snp.makeConstraints { (make) in
         make.left.equalTo(logoImageView.snp.left)
         make.top.equalTo(logoImageView.snp.bottom).offset(screenSize.height * (16/iPhoneXHeight))
       }
    descriptionLabel.snp.makeConstraints { (make) in
      make.left.equalTo(titleLabel.snp.left)
      make.top.equalTo(titleLabel.snp.bottom).offset(screenSize.height * (4/iPhoneXHeight))
    }
  }

}
