//
//  TimeView.swift
//  MSA
//
//  Created by Pavlo Kharambura on 8/17/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

class TimeView: UIView {

//    let greenCol = UIColor(red: 90/255, green: 223/255, blue: 38/255, alpha: 1)
//    let redColler = UIColor(red: 255/255, green: 94/255, blue: 115/255, alpha: 1)
    let greyColl = UIColor(red: 163/255, green: 173/255, blue: 175/255, alpha: 1)
    
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
        whiteView.backgroundColor = lightGREEN
        workHelpView.backgroundColor = lightGREEN
        workLabel.textColor = darkGreenColor
        workDevider.textColor = darkGreenColor
        workMinutes.textColor = darkGreenColor
        workSeconds.textColor = darkGreenColor
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
        redView.backgroundColor = lightRED
        restHelpView.backgroundColor = lightRED
        restLabel.textColor = darkGreenColor
        restDevider.textColor = darkGreenColor
        restMinutes.textColor = darkGreenColor
        restSeconds.textColor = darkGreenColor
    }
    
}
