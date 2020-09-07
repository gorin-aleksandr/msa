//
//  HowToTrainigViewController.swift
//  MSA
//
//  Created by Nik on 06.08.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit

class HowToTrainigViewController: UIViewController {
  
  @IBOutlet weak var trainerButton: UIButton!
  @IBOutlet weak var sportsmanButton: UIButton!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var startButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  func setupUI() {
    trainerButton.titleLabel?.font = NewFonts.SFProDisplayRegular14
    trainerButton.setTitleColor(UIColor.newBlack, for: .normal)
    trainerButton.setTitleColor(.white, for: .selected)
    trainerButton.setBackgroundColor(color: UIColor.backgroundLightGrey, forState: .normal)
    trainerButton.setBackgroundColor(color: UIColor.newBlue, forState: .selected)
    trainerButton.setImage(UIImage(named: "athlet"), for: .normal)
    trainerButton.roundCorners(.allCorners, radius: 12)
    trainerButton.setTitle("Самостоятельно", for: .normal)
    //trainerButton.addTarget(self, action: #selector(trainerButtonAction(_:)), for: .touchUpInside)
    
    sportsmanButton.titleLabel?.font = NewFonts.SFProDisplayRegular14
    sportsmanButton.setTitleColor(UIColor.newBlack, for: .normal)
    sportsmanButton.setTitleColor(.white, for: .selected)
    sportsmanButton.setBackgroundColor(color: UIColor.backgroundLightGrey, forState: .normal)
    sportsmanButton.setBackgroundColor(color: UIColor.newBlue, forState: .selected)
    sportsmanButton.setImage(UIImage(named: "weight-lifter"), for: .normal)
    sportsmanButton.roundCorners(.allCorners, radius: 12)
    sportsmanButton.setTitle("С тренером", for: .normal)
    //sportsmanButton.addTarget(self, action: #selector(sportsmanButtonAction(_:)), for: .touchUpInside)
    
    titleLabel.font = NewFonts.SFProDisplayBold24
    titleLabel.textColor = UIColor.newBlack
    titleLabel.text = "Как будем тренироваться?"
    
    descriptionLabel.font = NewFonts.SFProDisplayRegular16
    descriptionLabel.textColor = UIColor.newBlack
    descriptionLabel.text = "Вы тренируетесь самостоятельно или хотите найти тренера?"
    
    startButton.setTitle("Продолжить", for: .normal)
    startButton.titleLabel?.font = NewFonts.SFProDisplayRegular14
    startButton.setTitleColor(UIColor.diasbledGrey, for: .normal)
    startButton.setTitleColor(.white, for: .selected)
    startButton.setBackgroundColor(color: UIColor.backgroundLightGrey, forState: .normal)
    startButton.setBackgroundColor(color: UIColor.newBlue, forState: .selected)
    startButton.setImage(nil, for: .normal)
    startButton.setImage(UIImage(named: "doubleChevron"), for: .selected)
    startButton.roundCorners(.allCorners, radius: 12)
    //startButton.addTarget(self, action: #selector(startButtonAction(_:)), for: .touchUpInside)
    
  }
  
}
