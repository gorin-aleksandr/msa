//
//  HeartBeatDeviceTableViewCell.swift
//  MSA
//
//  Created by Andrey Krit on 11/13/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

class HeartBeatDeviceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var deviceStateImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCellWith(device: DeviceVO) {
        nameLabel.text = device.name.isEmpty ? "Без имени" : device.name
        idLabel.text = device.id
        deviceStateImageView.image = device.isConnected ? UIImage(imageLiteralResourceName: "checkbox-filled") : UIImage(imageLiteralResourceName: "info-image")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
