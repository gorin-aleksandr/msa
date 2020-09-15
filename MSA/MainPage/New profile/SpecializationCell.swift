//
//  ProductCollectionViewCell.swift
//  m2mMarket
//
//  Created by Nik on 5/14/18.
//  Copyright © 2018 m2mMarket. All rights reserved.
//

import UIKit

class SpecializationCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    static let identifier = "SpecializationCell"
    
   // @IBOutlet weak var nameLabel: UILabel!
   
    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = ""
        accessoryType = .none
    }
    
    func setupUI() {
    }
}

