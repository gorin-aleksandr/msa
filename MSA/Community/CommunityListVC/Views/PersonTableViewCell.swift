//
//  PersonTableViewCell.swift
//  MSA
//
//  Created by Andrey Krit on 7/4/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import SDWebImage

enum PersonState {
    case friend, userTrainer, all
}

enum PersonTableViewCellState {
    case communityList, caseMyCommunity
}

typealias AddButtonHandler = () -> ()

class PersonTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var locationIcon: UIImageView!
    @IBOutlet weak var userTypeView: UIView!
    @IBOutlet weak var typeIconImage: UIImageView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var state: PersonTableViewCellState = .communityList
    
    var addButtonHandler: AddButtonHandler!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width/2
        userTypeView.layer.cornerRadius = userTypeView.frame.width/2
        addButton.setImage(  #imageLiteral(resourceName: "accept_disabled"), for: .disabled)
        acceptButton.layer.cornerRadius = 6
        selectionStyle = .none
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
        switch person.userType {
        case .sportsman:
            typeIconImage.image = #imageLiteral(resourceName: "athlet-icon")
        case .trainer:
            typeIconImage.image = #imageLiteral(resourceName: "coach-icon")
        }
        acceptButton.isHidden = state == .communityList
        deleteButton.isHidden = state == .communityList
        addButton.isHidden = state != .communityList

    }
    
    func setupCell(basedOn state: PersonState) {
        switch state {
        case .friend:
            setAvatarBorder(width: 2, color: UIColor.lightBlue.cgColor)
            userTypeView.backgroundColor = .lightBlue
            addButton.isEnabled = false
        case .userTrainer:
            setAvatarBorder(width: 2, color: UIColor.deepPink.cgColor)
            userTypeView.backgroundColor = .deepPink
            addButton.isEnabled = false
        default:
            setAvatarBorder(width: 0, color: nil)
            userTypeView.backgroundColor = .msaBlack
            addButton.isEnabled = true
        }
    }
    
    private func setAvatarBorder(width: CGFloat, color: CGColor?) {
        avatarImageView.layer.borderWidth = width
        avatarImageView.layer.borderColor = color
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        addButtonHandler()
    }
}
