//
//  AchievmentCell.swift
//  MSA
//
//  Created by Nik on 22.04.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit

class AchievmentCell: UITableViewCell {

  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var rankLabel: UILabel!
  @IBOutlet weak var yearLabel: UILabel!
  @IBOutlet weak var achieveLabel: UILabel!
  @IBOutlet weak var removeButton: UIButton!

  static let identifier = "AchievmentCell"
  var removeAchievement: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

  @IBAction func removAction(_ sender: Any) {
    removeAchievement?()
  }
}
