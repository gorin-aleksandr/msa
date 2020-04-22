//
//  AchievmentCell.swift
//  MSA
//
//  Created by Nik on 22.04.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit

class EducationCell: UITableViewCell {

  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var yearFromLabel: UILabel!
  @IBOutlet weak var yearToLabel: UILabel!
  @IBOutlet weak var removeButton: UIButton!

  static let identifier = "EducationCell"
  var removeEducation: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

  @IBAction func removAction(_ sender: Any) {
    removeEducation?()
  }
}
