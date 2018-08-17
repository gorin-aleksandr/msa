//
//  TimeView.swift
//  MSA
//
//  Created by Pavlo Kharambura on 8/17/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

class TimeView: UIView {

    let greenCol = UIColor(red: 4/255, green: 232/255, blue: 36/255, alpha: 0.75)
    let redColler = UIColor(red: 255/255, green: 94/255, blue: 115/255, alpha: 1)
    let greyColl = UIColor(red: 163/255, green: 173/255, blue: 175/255, alpha: 1.00)
    
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var mainView: UIView! {didSet {self.mainView.layer.cornerRadius = 16}}
    @IBOutlet weak var whiteView: UIView! {didSet {self.whiteView.layer.cornerRadius = 15}}
    @IBOutlet weak var redView: UIView! {didSet {self.redView.layer.cornerRadius = 16}}
    
    @IBOutlet weak var workMinutes: UILabel!
    @IBOutlet weak var workSeconds: UILabel!
    @IBOutlet weak var workLabel: UILabel!
    @IBOutlet weak var workDevider: UILabel!
    @IBOutlet weak var restMinutes: UILabel!
    @IBOutlet weak var restSeconds: UILabel!
    @IBOutlet weak var restDevider: UILabel!
    @IBOutlet weak var restButton: UIButton!
    @IBOutlet weak var workButton: UIButton!
    @IBOutlet weak var restLabel: UILabel!
    
    @IBOutlet weak var workHelpView: UIView!
    @IBOutlet weak var restHelpView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("TimeView", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        workButton.addTarget(self, action: #selector(setWorkActive), for: .touchUpInside)
        restButton.addTarget(self, action: #selector(setRestActive), for: .touchUpInside)
        setWorkActive()
    }
    
    @objc
    private func setWorkActive() {
        whiteView.backgroundColor = greenCol
        workHelpView.backgroundColor = greenCol
        workLabel.textColor = .black
        workDevider.textColor = .black
        workMinutes.textColor = .black
        workSeconds.textColor = .black
        redView.backgroundColor = .white
        restLabel.textColor = greyColl
        restHelpView.backgroundColor = .white
        restDevider.textColor = greyColl
        restMinutes.textColor = greyColl
        restSeconds.textColor = greyColl
    }
    
    @objc
    private func setRestActive() {
        whiteView.backgroundColor = .white
        workHelpView.backgroundColor = .white
        workLabel.textColor = greyColl
        workDevider.textColor = greyColl
        workMinutes.textColor = greyColl
        workSeconds.textColor = greyColl
        redView.backgroundColor = redColler
        restHelpView.backgroundColor = redColler
        restLabel.textColor = .black
        restDevider.textColor = .black
        restMinutes.textColor = .black
        restSeconds.textColor = .black
    }
    
}
