//
//  ProductCollectionViewCell.swift
//  m2mMarket
//
//  Created by Nik on 5/14/18.
//  Copyright © 2018 m2mMarket. All rights reserved.
//

import UIKit

class UserDataCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    static let identifier = "UserDataCell"
    
    @IBOutlet weak var valueTextField: UITextField!

    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = ""
        accessoryType = .none
        setupUI()
    }
    
    func setupUI() {
      valueTextField.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.00)
      //mainView.backgroundColor = UIColor.backgroundLightGray()
      //mainView.roundCorners(corners: .allCorners, radius: 16)
    }
}

