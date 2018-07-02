//
//  TextViewViewCounterTableViewCell.swift
//  MSA
//
//  Created by Pavlo Kharambura on 7/1/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

class TextViewViewCounterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var HeaderLabel: UILabel!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var numOfSymbuls: UILabel!
    @IBOutlet weak var maxLenght: UILabel!
    @IBOutlet weak var lineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
