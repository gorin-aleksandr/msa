//
//  UserInfoTableHeaderView.swift
//  MSA
//
//  Created by Nik on 02.09.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit
import FZAccordionTableView

class UserInfoTableHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!    
    
  override func awakeFromNib() {
    titleLabel.font = NewFonts.SFProDisplayBold16
  }

}
