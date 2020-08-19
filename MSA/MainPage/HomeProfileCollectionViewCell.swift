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
    @IBOutlet weak var titleLabel: UILabel!

    static let identifier = "HomeProfileCollectionViewCell"
    
    override func awakeFromNib() {
      super.awakeFromNib()
      setupUI()
    }
    
    func setupUI() {
      titleLabel.font = UIFont(name: Fonts.SFProDisplayBold, size: 24)
      titleLabel.textColor = UIColor.newBlack
    }
}
