//
//  MyAuthorizationAppleIdButton.swift
//  MSA
//
//  Created by Nik on 30.04.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit
import AuthenticationServices


@available(iOS 13.0, *)
@IBDesignable
class MyAuthorizationAppleIdButton: UIButton {
  override public init(frame: CGRect) {
      super.init(frame: frame)
  }
  
  var authorizationButton = ASAuthorizationAppleIDButton(authorizationButtonType: .default, authorizationButtonStyle: .black)
  
  required public init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
  }
  
  override public func draw(_ rect: CGRect) {
      super.draw(rect)

      // Create ASAuthorizationAppleIDButton
    if #available(iOS 13.0, *) {
      // Show authorizationButton
      
      addSubview(authorizationButton)

      // Use auto layout to make authorizationButton follow the MyAuthorizationAppleIDButton's dimension
      authorizationButton.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
          authorizationButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 0.0),
          authorizationButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0.0),
          authorizationButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0.0),
          authorizationButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0.0),
      ])
    } else {
      // Fallback on earlier versions
    }


  }
}
