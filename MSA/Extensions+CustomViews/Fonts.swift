//
//  UIFont+Extension.swift
//  MSA
//
//  Created by Andrey Krit on 8/25/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import Foundation
import UIKit

struct Fonts {

    static func medium(_ size: CGFloat) -> UIFont {
        guard let font = UIFont(name: "Rubik-Medium", size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }

}
