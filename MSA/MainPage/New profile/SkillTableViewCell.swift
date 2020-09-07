//
//  SkillTableViewCell.swift
//  MSA
//
//  Created by Nik on 02.09.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit

class SkillTableViewCell: UITableViewCell {

  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var achievementLabel: UILabel!
  @IBOutlet weak var editButton: UIButton!
  @IBOutlet weak var mainView: UIView!

  static let identifier = "SkillTableViewCell"
  
    override func awakeFromNib() {
        super.awakeFromNib()
      nameLabel.font = NewFonts.SFProDisplayBold16
      nameLabel.textColor = UIColor.newBlack
      descriptionLabel.font = NewFonts.SFProDisplayRegular12
      descriptionLabel.textColor = UIColor.textGrey
      achievementLabel.font = NewFonts.SFProDisplayBold16
      achievementLabel.textColor = UIColor.newBlack
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
