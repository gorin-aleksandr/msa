
//
//  ApproachTableViewCell.swift
//  MSA
//
//  Created by Pavlo Kharambura on 8/20/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

class ApproachTableViewCell: UITableViewCell {

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var weightAndCountsLabel: UILabel!
    @IBOutlet weak var workTimeLabel: UILabel!
    @IBOutlet weak var restTimeLabel: UILabel!
    @IBOutlet weak var restButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
