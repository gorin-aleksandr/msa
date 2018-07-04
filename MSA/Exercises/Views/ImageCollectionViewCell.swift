//
//  ImageCollectionViewCell.swift
//  MSA
//
//  Created by Pavlo Kharambura on 7/1/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var bgView: UIView! {
        didSet {
//            bgView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var image: UIImageView! {
        didSet {
            image.clipsToBounds = true
            image.layer.cornerRadius = 10
            setShadow(outerView: image, shadowOpacity: 0.7)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    func setShadow(outerView: UIView, shadowOpacity: Float) {
//        outerView.clipsToBounds = false
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOpacity = shadowOpacity
        outerView.layer.shadowOffset = CGSize.zero
        outerView.layer.shadowRadius = 4
        outerView.layer.shadowPath = UIBezierPath(roundedRect: outerView.bounds, cornerRadius: 10).cgPath
    }
    
}
