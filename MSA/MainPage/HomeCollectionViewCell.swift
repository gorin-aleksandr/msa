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
  @IBOutlet weak var mainView: UIView!

  static let identifier = "HomeCollectionViewCell"
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupUI()
  }
  
  func setupUI() {
    titleLabel.font = UIFont(name: Fonts.SFProDisplayBold, size: 14)
    titleLabel.textColor = UIColor.newBlack

    descriptionLabel.font = UIFont(name: Fonts.SFProDisplayRegular, size: 10)
    descriptionLabel.textColor = UIColor.newBlack
  }

}
