//
//  LoadVideoTableViewCell.swift
//  MSA
//
//  Created by Pavlo Kharambura on 7/1/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

class LoadVideoTableViewCell: UITableViewCell {
    @IBOutlet weak var addVideo: UIButton!
    @IBOutlet weak var log: UIImageView!
    @IBOutlet weak var lab: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var deleteVideoButt: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {didSet{activityIndicator.stopAnimating()}}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
