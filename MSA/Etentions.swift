//
//  Etentions.swift
//  MSA
//
//  Created by Pavlo Kharambura on 4/4/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import Foundation
import UIKit

private var maxLengths = [UITextField: Int]()

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension String {
    
    var length: Int {
        return self.characters.count
    }
    
    subscript (i: Int) -> String {
        return self[Range(i ..< i + 1)]
    }
    
    func substring(from: Int) -> String {
        return self[Range(min(from, length) ..< length)]
    }
    
    func substring(to: Int) -> String {
        return self[Range(0 ..< max(0, to))]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[Range(start ..< end)])
    }
    
}

extension UIImage {
    func scaleImage(toSize newSize: CGSize) -> UIImage? {
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            context.interpolationQuality = .high
            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
            context.concatenate(flipVertical)
            context.draw(self.cgImage!, in: newRect)
            let newImage = UIImage(cgImage: context.makeImage()!)
            UIGraphicsEndImageContext()
            return newImage
        }
        return nil
    }
    
    func scaleAndRotateImage() -> UIImage {
        let maxSize = self.size.width
        guard let imgRef = self.cgImage
            else { return self }
        
        let width = CGFloat(imgRef.width)
        let height = CGFloat(imgRef.height)
        
        var transform: CGAffineTransform = .identity
        
        var bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        if width > maxSize || height < maxSize {
            let ratio = width / height
            
            if ratio > 1 {
                bounds.size.width = maxSize
                bounds.size.height = bounds.size.width / ratio
            } else {
                bounds.size.height = maxSize
                bounds.size.width = bounds.size.height * ratio
            }
        }
        
        let scaleRatio = bounds.size.width / width
        let imageSize = CGSize(width: width, height: height)
        var boundHeight : CGFloat = 0.0
        
        let ori = self.imageOrientation
        
        switch(ori) {
        case .up:
            transform = .identity
            break
            
        case .down:
            transform = CGAffineTransform(translationX: imageSize.width, y: imageSize.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
            break
            
        case .left:
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransform(translationX: 0.0, y: imageSize.width)
            transform = transform.rotated(by: CGFloat(3.0 * Double.pi / 2.0))
            break
            
        case .right:
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransform(translationX: imageSize.height, y: 0.0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2.0))
            break
            
        case .upMirrored:
            transform = CGAffineTransform(translationX: imageSize.width, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: -1.0)
            break
            
        case .downMirrored:
            transform = CGAffineTransform(translationX: 0.0, y: imageSize.height)
            transform = transform.scaledBy(x: 1.0, y: -1.0)
            break
            
        case .leftMirrored:
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransform(translationX: imageSize.height, y: imageSize.width)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
            transform = transform.rotated(by: CGFloat(3.0 * Double.pi / 2.0))
            break
            
        case .rightMirrored:
            boundHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = boundHeight
            transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            transform = transform.rotated(by: CGFloat(Double.pi / 2.0))
            break
        }
        
        UIGraphicsBeginImageContext(bounds.size)
        
        guard let context = UIGraphicsGetCurrentContext()
            else { return self }
        
        if ori == UIImageOrientation.right || ori == UIImageOrientation.left {
            context.scaleBy(x: -scaleRatio, y: scaleRatio)
            context.translateBy(x: -height, y: 0.0)
        } else {
            context.scaleBy(x: scaleRatio, y: -scaleRatio)
            context.translateBy(x: 0.0, y: -height)
        }
        
        context.concatenate(transform)
        context.draw(imgRef, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image ?? self
    }
}

extension UITextField {
    
    @IBInspectable var maxLength: Int {
        get {
            // 4
            guard let length = maxLengths[self] else {
                return Int.max
            }
            return length
        }
        set {
            maxLengths[self] = newValue
            // 5
            addTarget(
                self,
                action: #selector(limitLength),
                for: UIControlEvents.editingChanged
            )
        }
    }
    
    @objc func limitLength(textField: UITextField) {
        // 6
        guard let prospectiveText = textField.text,
            prospectiveText.characters.count > maxLength
            else {
                return
        }
        
        let selection = selectedTextRange
        // 7
        let maxCharIndex = prospectiveText.index(prospectiveText.startIndex, offsetBy: maxLength)
        text = prospectiveText.substring(to: maxCharIndex)
        selectedTextRange = selection
    }
    
}
