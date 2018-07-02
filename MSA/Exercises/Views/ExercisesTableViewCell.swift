//
//  ExercisesTableViewCell.swift
//  MSA
//
//  Created by Pavlo Kharambura on 6/14/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import SDWebImage

class ExercisesTableViewCell: UITableViewCell {

    @IBOutlet weak var exerciseImage: UIImageView! {didSet{exerciseImage.layer.cornerRadius = 10}}
    @IBOutlet weak var exercisename: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(with exercise: Exercise) {
        exerciseImage.sd_setImage(with: URL(string: exercise.pictures.first?.url ?? ""), placeholderImage: nil, options: .allowInvalidSSLCertificates, completed: nil)
        exercisename.text = exercise.name
    }
    
}
