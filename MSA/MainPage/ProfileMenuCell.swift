//
//  ProductCollectionViewCell.swift
//  m2mMarket
//
//  Created by Nik on 5/14/18.
//  Copyright © 2018 m2mMarket. All rights reserved.
//

import UIKit

class ProfileMenuCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    static let identifier = "ProfileMenuCell"
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var logoImageVIew: UIImageView!
    @IBOutlet weak var rightDirectionImageVIew: UIImageView!
    @IBOutlet weak var mainView: UIView!

    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = ""
        accessoryType = .none
        setupUI()
    }
    
    func setupUI() {
      mainView.backgroundColor = .textFieldBackgroundGrey
      mainView.snp.makeConstraints { (make) in
        make.top.equalTo(self.contentView.snp.top).offset(screenSize.height * (6/iPhoneXHeight))
        make.bottom.equalTo(self.contentView.snp.bottom).offset(screenSize.height * (-6/iPhoneXHeight))
        make.right.equalTo(self.contentView.snp.right).offset(screenSize.height * (-20/iPhoneXHeight))
        make.left.equalTo(self.contentView.snp.left).offset(screenSize.height * (20/iPhoneXHeight))
      }
      
      logoImageVIew.snp.makeConstraints { (make) in
            make.centerY.equalTo(mainView.snp.centerY)
            make.left.equalTo(self.mainView.snp.left).offset(screenSize.height * (16/iPhoneXHeight))
          }
     
      nameLabel.snp.makeConstraints { (make) in
               make.centerY.equalTo(mainView.snp.centerY)
               make.left.equalTo(self.logoImageVIew.snp.right).offset(screenSize.height * (20/iPhoneXHeight))
      }
      
//      rightDirectionImageVIew.snp.makeConstraints { (make) in
//                 make.centerY.equalTo(mainView.snp.centerY)
//                 make.right.equalTo(self.mainView.snp.right).offset(screenSize.height * (-27/iPhoneXHeight))
//      }
    }
}

