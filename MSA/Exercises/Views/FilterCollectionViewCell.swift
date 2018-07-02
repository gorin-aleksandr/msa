//
//  FilterCollectionViewCell.swift
//  MSA
//
//  Created by Pavlo Kharambura on 6/16/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var filterName: UILabel!
    @IBOutlet weak var bgView: UIView! {didSet{bgView.layer.cornerRadius = 25}}
    
}
