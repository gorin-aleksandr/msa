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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width/2
    }

    func configure(with person: UserVO) {
        guard var fullName = person.firstName else {
            return
        }
        if let secondName = person.lastName {
            fullName += " " + secondName
        }
        fullNameLabel.text = fullName
        cityLabel.text = person.city
        locationIcon.isHidden = person.city == nil
        if let stringUrl = person.avatar, !stringUrl.isEmpty, let url = URL(string: stringUrl) {
            avatarImageView.sd_setImage(with: url, completed: nil)
        }
    }
}
