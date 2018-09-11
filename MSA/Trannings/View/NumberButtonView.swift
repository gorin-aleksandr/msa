//
//  NumberButtonView.swift
//  MSA
//
//  Created by Pavlo Kharambura on 8/16/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

class NumberButtonView: UIView {

    @IBOutlet weak var whiteView: UIView! {didSet{self.whiteView.layer.cornerRadius = self.frame.size.height/9}}
    @IBOutlet weak var blackBiew: UIView! {didSet{self.blackBiew.layer.cornerRadius = self.frame.size.height/9}}
    @IBOutlet weak var numberButton: UIButton!
    @IBOutlet var contentView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("NumberButtonView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
