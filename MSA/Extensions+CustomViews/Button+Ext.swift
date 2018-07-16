//
//  FilterButton.swift
//  MSA
//
//  Created by Andrey Krit on 7/6/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

extension UIButton {
    func configureAsFilterButton(title: String, xOffset: CGFloat, padding: CGFloat) {
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = UIFont(name: "Rubik-Medium", size: 13)
        let width = self.intrinsicContentSize.width + 30
        self.setTitleColor(.white, for: .normal)
        self.layer.cornerRadius = 15
        if self.isSelected {
            self.backgroundColor = .lightBlue
        } else {
            self.backgroundColor = .lightGray
        }
        self.frame = CGRect(x: xOffset, y: padding, width: width, height: 30)
    }
}
