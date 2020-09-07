//
//  AddAchevementTableViewCell.swift
//  MSA
//
//  Created by Nik on 03.09.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit

class AddAchevementTableViewCell: UITableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var editButton: UIButton!
  @IBOutlet weak var mainView: UIView!

  static let identifier = "AddAchevementTableViewCell"
  
  override func awakeFromNib() {
    super.awakeFromNib()
    nameLabel.font = NewFonts.SFProDisplayBold16
    nameLabel.textColor = UIColor.newBlack
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
}
