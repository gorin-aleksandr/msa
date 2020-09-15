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
        guard let font = UIFont(name: "SFProDisplay-Bold", size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }

  
}


struct NewFonts {
  
  //Regular
  static let SFProDisplayRegular10 = UIFont.systemFont(ofSize: screenSize.height * (10/iPhoneXHeight), weight: .regular)
  static let SFProDisplayRegular12 = UIFont.systemFont(ofSize: screenSize.height * (12/iPhoneXHeight), weight: .regular)
  static let SFProDisplayRegular13 = UIFont.systemFont(ofSize: screenSize.height * (13/iPhoneXHeight), weight: .regular)
  static let SFProDisplayRegular14 = UIFont.systemFont(ofSize: screenSize.height * (14/iPhoneXHeight), weight: .regular)
  static let SFProDisplayRegular16 = UIFont.systemFont(ofSize: screenSize.height * (16/iPhoneXHeight), weight: .regular)
  static let SFProDisplayRegular17 = UIFont.systemFont(ofSize: screenSize.height * (17/iPhoneXHeight), weight: .regular)
  static let SFProDisplayRegular20 = UIFont.systemFont(ofSize: screenSize.height * (20/iPhoneXHeight), weight: .regular)
  static let SFProDisplayRegular24 = UIFont.systemFont(ofSize: screenSize.height * (24/iPhoneXHeight), weight: .regular)
  static let SFProDisplayRegular36 = UIFont.systemFont(ofSize: screenSize.height * (36/iPhoneXHeight), weight: .regular)

  //Bold
  static let SFProDisplayBold10 = UIFont.systemFont(ofSize: screenSize.height * (10/iPhoneXHeight), weight: .bold)
  static let SFProDisplayBold12 = UIFont.systemFont(ofSize: screenSize.height * (12/iPhoneXHeight), weight: .bold)
  static let SFProDisplayBold13 = UIFont.systemFont(ofSize: screenSize.height * (13/iPhoneXHeight), weight: .bold)
  static let SFProDisplayBold14 = UIFont.systemFont(ofSize: screenSize.height * (14/iPhoneXHeight), weight: .bold)
  static let SFProDisplayBold16 = UIFont.systemFont(ofSize: screenSize.height * (16/iPhoneXHeight), weight: .bold)
  static let SFProDisplayBold17 = UIFont.systemFont(ofSize: screenSize.height * (17/iPhoneXHeight), weight: .bold)
  static let SFProDisplayBold20 = UIFont.systemFont(ofSize: screenSize.height * (20/iPhoneXHeight), weight: .bold)
  static let SFProDisplayBold24 = UIFont.systemFont(ofSize: screenSize.height * (24/iPhoneXHeight), weight: .bold)
  static let SFProDisplayBold32 = UIFont.systemFont(ofSize: screenSize.height * (32/iPhoneXHeight), weight: .bold)
  static let SFProDisplayBold36 = UIFont.systemFont(ofSize: screenSize.height * (36/iPhoneXHeight), weight: .bold)
}
