//
//  FilterButton.swift
//  MSA
//
//  Created by Andrey Krit on 7/6/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

extension UIButton {
    
    func setAsFilterButton() {
        let label = UILabel()
        label.text = item.name
        label.font = UIFont(name: "Rubik", size: 18)
        label.textColor = .black
        
        let width = label.intrinsicContentSize.width + 30
        
        button.setTitle(item.name, for: .normal)
        button.tag = filters.index(of: item) ?? -1
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.frame = CGRect(x: xOffset, y: buttonPadding, width: width, height: 30)
        button.addTarget(self, action: #selector(filterTapped(_:)), for: .touchUpInside)
        xOffset = xOffset + buttonPadding + button.frame.size.width
        scrollView.addSubview(button)
    }
}
