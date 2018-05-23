//
//  ProfileImageView.swift
//  MSA
//
//  Created by Pavlo Kharambura on 4/4/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

class ProfileImageView: UIImageView {
    
    override func setNeedsLayout() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: self.frame.size.width/2, y: self.frame.size.height))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height*17/20))
        path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height*1/20))
        path.addLine(to: CGPoint(x: self.frame.size.width/2, y: 0))
        path.addLine(to: CGPoint(x: 0, y: self.frame.size.height*1/20))
        path.addLine(to: CGPoint(x: 0, y: self.frame.size.height*17/20))
        path.addLine(to: CGPoint(x: self.frame.size.width/2, y: self.frame.size.height))
        
        path.close()
        UIColor.red.setFill()
        path.stroke()
        path.reversing()
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = self.bounds
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.red.cgColor
        self.layer.mask = shapeLayer;
        self.layer.masksToBounds = true;
    }
    
}
