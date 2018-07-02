//
//  GalleryCollectionViewCell.swift
//  MSA
//
//  Created by Pavlo Kharambura on 4/17/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView! {
        didSet{
            photoImageView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var video: UIImageView!
    @IBOutlet weak var c: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
}
