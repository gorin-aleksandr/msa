//
//  CircleTrainingExerciseTableViewCell.swift
//  MSA
//
//  Created by Pavlo Kharambura on 8/21/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

class CircleTrainingExerciseTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var circleButton: UIButton!
    @IBOutlet weak var podhodCountLabel: UILabel!
    @IBOutlet weak var kdButton: UIButton!
    @IBOutlet weak var counts: UIButton!
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
