//
//  ExercisesCollectionViewCell.swift
//  MSA
//
//  Created by Pavlo Kharambura on 6/14/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

class ExercisesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var viewForImage: UIView! {didSet{viewForImage.layer.cornerRadius = 12 }}
    @IBOutlet weak var imageView: UIImageView! {didSet{imageView.layer.cornerRadius = 10 }}
    @IBOutlet weak var nameLabel: UILabel!
    
    func configureCell(with exerciseType: ExerciseType) {
        imageView.sd_setImage(with: URL(string: exerciseType.picture), placeholderImage: nil, options: .allowInvalidSSLCertificates, completed: nil)
        nameLabel.text = exerciseType.name
    }
    
}
