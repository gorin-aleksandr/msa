//
//  ErrorView.swift
//  MSA
//
//  Created by Andrey Krit on 10/31/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

protocol ErrorViewDelegate: class {
    func tryAgainButtonDidTapped()
}

class ErrorView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var tryAgainButton: UIButton!
    
    weak var delegate: ErrorViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.main.loadNibNamed("ErrorView", owner: self, options: nil)
        addSubview(contentView)
        contentView.addSubview(errorMessageLabel)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        //self.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        Bundle.main.loadNibNamed("ErrorView", owner: self, options: nil)
        addSubview(contentView)
        contentView.addSubview(errorMessageLabel)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        configureButton()
    }
    
    private func configureButton() {
        tryAgainButton.layer.masksToBounds = true
        tryAgainButton.layer.cornerRadius = 12
        tryAgainButton.layer.borderWidth = 1
        tryAgainButton.layer.borderColor = UIColor.darkGreenColor.cgColor
    }
    
    @IBAction func tryAgainButtonDidTapped(_ sender: Any) {
        delegate?.tryAgainButtonDidTapped()
    }
    
}
