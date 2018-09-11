//
//  ExerciseTableViewCell.swift
//  MSA
//
//  Created by Pavlo Kharambura on 8/22/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

class ExerciseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var exerciseNameLable: UILabel!
    @IBOutlet weak var exerciseImageView: UIImageView! {
        didSet {
            exerciseImageView.layer.cornerRadius = 15
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
