//
//  CreateExerciseTableViewCell.swift
//  MSA
//
//  Created by Pavlo Kharambura on 7/1/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

class CreateExerciseTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var textLabelMess: UILabel!
    @IBOutlet weak var bgView: UIView! {didSet{bgView.layer.cornerRadius = 12}}
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
