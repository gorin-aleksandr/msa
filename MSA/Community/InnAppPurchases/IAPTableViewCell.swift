//
//  IAPTAbleVeiwCell.swift
//  MSA
//
//  Created by Andrey Krit on 2/27/19.
//  Copyright © 2019 Pavlo Kharambura. All rights reserved.
//

import UIKit

class IAPTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var productContainerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        productContainerView.layer.cornerRadius = 8
        titleLabel.isHidden = true
    }
    
    func configureWith(product: Product) {
        titleLabel.text = product.product.localizedTitle
        priceLabel.text = product.formattedPrice + " / " + product.product.localizedTitle
        detailsLabel.text = product.product.localizedDescription
        
//        let gradient = CAGradientLayer()
//        gradient.frame = productContainerView.bounds
//        gradient.cornerRadius = 8
//        gradient.colors = [UIColor.startGradientColor.cgColor, UIColor.endGradientColor.cgColor]
//        productContainerView.layer.insertSublayer(gradient, at: 0)
    }

}
