//
//  PersonTableViewCell.swift
//  MSA
//
//  Created by Andrey Krit on 7/4/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import SDWebImage

class PersonTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var locationIcon: UIImageView!
    
    

    func configure(with person: PersonVO) {
        var fullName = person.firstName
        if let secondName = person.secondName {
            fullName += " " + secondName
        }
        fullNameLabel.text = fullName
        cityLabel.text = person.city
        locationIcon.isHidden = person.city == nil
        avatarImageView.sd_setImage(with: URL(string: person.imageUrl ?? "" ), completed: nil)
    }

}
