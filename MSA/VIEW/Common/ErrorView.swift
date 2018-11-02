//
//  ErrorView.swift
//  MSA
//
//  Created by Andrey Krit on 10/31/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

class ErrorView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.main.loadNibNamed("ErrorView", owner: self, options: nil)
        addSubview(contentView)
        contentView.addSubview(errorMessageLabel)
        contentView.frame = self.bounds
        contentView.backgroundColor = .red
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        //self.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle.main.loadNibNamed("ErrorView", owner: self, options: nil)
        addSubview(contentView)
        contentView.addSubview(errorMessageLabel)
        contentView.frame = self.bounds
        contentView.backgroundColor = .red
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
}
