//
//  SartOnboardingViewController.swift
//  MSA
//
//  Created by Nik on 26.07.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit
import SnapKit

class StartOnboardingViewController: UIViewController {
  
  @IBOutlet weak var backgroundView: UIView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var trainerButton: UIButton!
  @IBOutlet weak var sportsmanButton: UIButton!
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var privacyLabel: UILabel!
  @IBOutlet weak var promoScrollView: UIScrollView!
  @IBOutlet weak var promoPageControl: UIPageControl!
  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet weak var rightDirectionImageView: UIImageView!

  var viewModel = SignInViewModel()
  
  var slides: [PromoView] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    navigationController?.setNavigationBarHidden(true, animated: false)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    navigationController?.setNavigationBarHidden(false, animated: false)
  }
  
  func setupUI() {
    setupConstraints()
    backgroundView.cornerRadius = screenSize.height * (10/iPhoneXHeight)
    titleLabel.font = NewFonts.SFProDisplayBold24
    descriptionLabel.font = NewFonts.SFProDisplayRegular16
    trainerButton.titleLabel?.font = NewFonts.SFProDisplayRegular14
    sportsmanButton.titleLabel?.font = NewFonts.SFProDisplayRegular14
    startButton.titleLabel?.font = NewFonts.SFProDisplayRegular14
    privacyLabel.font = NewFonts.SFProDisplayRegular12
    titleLabel.textColor = UIColor.newBlack
    descriptionLabel.textColor = UIColor.newBlack
    trainerButton.setTitleColor(UIColor.newBlack, for: .normal)
    trainerButton.setTitleColor(.white, for: .selected)
    sportsmanButton.setTitleColor(UIColor.newBlack, for: .normal)
    sportsmanButton.setTitleColor(.white, for: .selected)
    startButton.setTitleColor(UIColor.diasbledGrey, for: .normal)
    startButton.setTitleColor(.white, for: .selected)
    privacyLabel.textColor = UIColor.textGrey
    trainerButton.setBackgroundColor(color: UIColor.backgroundLightGrey, forState: .normal)
    trainerButton.setBackgroundColor(color: UIColor.newBlue, forState: .selected)
    sportsmanButton.setBackgroundColor(color: UIColor.backgroundLightGrey, forState: .normal)
    sportsmanButton.setBackgroundColor(color: UIColor.newBlue, forState: .selected)
    startButton.setBackgroundColor(color: UIColor.backgroundLightGrey, forState: .normal)
    startButton.setBackgroundColor(color: UIColor.newBlue, forState: .selected)
    trainerButton.setImage(UIImage(named: "superhero_emoji"), for: .normal)
    sportsmanButton.setImage(UIImage(named: "weight"), for: .normal)
    startButton.setImage(nil, for: .normal)
    trainerButton.layer.cornerRadius = screenSize.height * (12/iPhoneXHeight)
    trainerButton.layer.masksToBounds = true
    sportsmanButton.layer.cornerRadius = screenSize.height * (12/iPhoneXHeight)
    sportsmanButton.layer.masksToBounds = true
    startButton.layer.cornerRadius = screenSize.height * (16/iPhoneXHeight)
    startButton.layer.masksToBounds = true

    trainerButton.setTitle("Тренер", for: .normal)
    sportsmanButton.setTitle("Спортсмен", for: .normal)
    privacyLabel.text = "Продолжая, вы соглашаетесь с Политикой конфедициальности и Условиями пользования."
    trainerButton.addTarget(self, action: #selector(trainerButtonAction(_:)), for: .touchUpInside)
    sportsmanButton.addTarget(self, action: #selector(sportsmanButtonAction(_:)), for: .touchUpInside)
    startButton.addTarget(self, action: #selector(startButtonAction(_:)), for: .touchUpInside)
    slides = createSlides()
    setupSlideScrollView(slides: slides)
    promoPageControl.numberOfPages = slides.count
    promoPageControl.currentPage = 0
    view.bringSubviewToFront(promoPageControl)
    promoScrollView.delegate = self
    promoScrollView.contentSize.height = 1.0 // disable vertical scroll
  }
  
  func setupConstraints() {
    backgroundImageView.snp.makeConstraints { (make) in
      make.top.equalTo(self.view.snp.top)
      make.bottom.equalTo(self.view.snp.bottom)
      make.right.equalTo(self.view.snp.right)
      make.left.equalTo(self.view.snp.left)
    }
    
    backgroundView.snp.makeConstraints { (make) in
      make.top.equalTo(screenSize.height * (342/iPhoneXHeight))
      make.bottom.equalTo(self.view.snp.bottom)
      make.right.equalTo(self.view.snp.right)
      make.left.equalTo(self.view.snp.left)
    }
    
    titleLabel.textAlignment = .center
    titleLabel.snp.makeConstraints { (make) in
      make.top.equalTo(backgroundView.snp.top).offset(screenSize.height * (28/iPhoneXHeight))
      make.right.equalTo(self.backgroundView.snp.right).offset(screenSize.height * (-16/iPhoneXHeight))
      make.left.equalTo(self.backgroundView.snp.left).offset(screenSize.height * (16/iPhoneXHeight))
    }
    
    descriptionLabel.textAlignment = .center
    descriptionLabel.snp.makeConstraints { (make) in
      make.top.equalTo(titleLabel.snp.bottom).offset(screenSize.height * (11/iPhoneXHeight))
      make.right.equalTo(self.backgroundView.snp.right).offset(screenSize.height * (-16/iPhoneXHeight))
      make.left.equalTo(self.backgroundView.snp.left).offset(screenSize.height * (16/iPhoneXHeight))
    }
    
    trainerButton.snp.makeConstraints { (make) in
      make.top.equalTo(descriptionLabel.snp.bottom).offset(screenSize.height * (28/iPhoneXHeight))
      make.left.equalTo(self.backgroundView.snp.left).offset(screenSize.height * (44/iPhoneXHeight))
      make.width.equalTo(screenSize.height * (136/iPhoneXHeight))
      make.height.equalTo(screenSize.height * (119/iPhoneXHeight))
    }
    
    sportsmanButton.snp.makeConstraints { (make) in
      make.top.equalTo(descriptionLabel.snp.bottom).offset(screenSize.height * (28/iPhoneXHeight))
      make.right.equalTo(self.backgroundView.snp.right).offset(screenSize.height * (-44/iPhoneXHeight))
      make.width.equalTo(screenSize.height * (136/iPhoneXHeight))
      make.height.equalTo(screenSize.height * (119/iPhoneXHeight))
    }
    
    
    startButton.snp.makeConstraints { (make) in
      make.top.equalTo(sportsmanButton.snp.bottom).offset(screenSize.height * (48/iPhoneXHeight))
      make.right.equalTo(self.backgroundView.snp.right).offset(screenSize.height * (-44/iPhoneXHeight))
      make.left.equalTo(self.backgroundView.snp.left).offset(screenSize.height * (44/iPhoneXHeight))
      make.height.equalTo(screenSize.height * (66/iPhoneXHeight))
    }
    
    privacyLabel.snp.makeConstraints { (make) in
      make.top.equalTo(startButton.snp.bottom).offset(screenSize.height * (40/iPhoneXHeight))
      make.right.equalTo(self.backgroundView.snp.right).offset(screenSize.height * (-20/iPhoneXHeight))
      make.left.equalTo(self.backgroundView.snp.left).offset(screenSize.height * (20/iPhoneXHeight))
    }
    
    promoPageControl.snp.makeConstraints { (make) in
      make.bottom.equalTo(backgroundView.snp.top).offset(screenSize.height * (-20/iPhoneXHeight))
      make.centerX.equalTo(backgroundView.snp.centerX)
    }
    
    promoScrollView.snp.makeConstraints { (make) in
      make.top.equalTo(self.view.snp.top)
      make.bottom.equalTo(backgroundView.snp.top)
      make.right.equalTo(self.backgroundView.snp.right)
      make.left.equalTo(self.backgroundView.snp.left)
    }
    promoScrollView.snp.makeConstraints { (make) in
      make.top.equalTo(self.view.snp.top)
      make.bottom.equalTo(backgroundView.snp.top)
      make.right.equalTo(self.backgroundView.snp.right)
      make.left.equalTo(self.backgroundView.snp.left)
    }
    
    rightDirectionImageView.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.startButton.snp.centerY)
      make.right.equalTo(self.startButton.snp.right).offset(screenSize.height * (-26/iPhoneXHeight))
      make.height.width.equalTo(screenSize.height * (28/iPhoneXHeight))
      
    }
    
    
  }
  
  @objc func trainerButtonAction(_ sender: UIButton) {
    let selected = trainerButton.isSelected
    sender.isSelected = !selected
    print("Trainer button:\(selected)")
    if sender.isSelected {
      sportsmanButton.isSelected = false
      startButton.isSelected = true
      viewModel.updateUserType(value: "ТРЕНЕР")
    }
  }
  
  @objc func sportsmanButtonAction(_ sender: UIButton) {
    let selected = sportsmanButton.isSelected
    sender.isSelected = !selected
    print("Sportsman button:\(selected)")
    if sender.isSelected {
      trainerButton.isSelected = false
      startButton.isSelected = true
      viewModel.updateUserType(value: "СПОРТСМЕН")
    }
  }
  
  @objc func startButtonAction(_ sender: UIButton) {
    if sender.isSelected {
      let nextViewController = signInStoryboard.instantiateViewController(withIdentifier: "OnboardingNameViewController") as! OnboardingNameViewController
      nextViewController.viewModel = viewModel
      nextViewController.viewModel?.signInDataControllerType = .name
      self.navigationController?.pushViewController(nextViewController, animated: true)
    }
  }
  
  func createSlides() -> [PromoView] {
    
    let slide1 = Bundle.main.loadNibNamed("PromoView", owner: self, options: nil)?.first as! PromoView
    slide1.titleLabel.text = "Создание персональных тренировок"
    slide1.descriptionLabel.text = "Находите ваших клиентов и создавайте персональный программы тренировок и питания"
    slide1.titleLabel.font = NewFonts.SFProDisplayBold32
    slide1.descriptionLabel.font = NewFonts.SFProDisplayRegular16
    slide1.titleLabel.textColor = .white
    slide1.descriptionLabel.textColor = .white
    
    let slide2 = Bundle.main.loadNibNamed("PromoView", owner: self, options: nil)?.first as! PromoView
    slide2.titleLabel.text = "A real-life bear"
    slide2.descriptionLabel.text = "Did you know that Winnie the chubby little cubby was based on a real, young bear in London"
    slide2.titleLabel.font = NewFonts.SFProDisplayBold32
    slide2.descriptionLabel.font = NewFonts.SFProDisplayRegular16
    slide2.titleLabel.textColor = .white
    slide2.descriptionLabel.textColor = .white
    
    let slide3 = Bundle.main.loadNibNamed("PromoView", owner: self, options: nil)?.first as! PromoView
    slide3.titleLabel.text = "A real-life bear"
    slide3.descriptionLabel.text = "Did you know that Winnie the chubby little cubby was based on a real, young bear in London"
    slide3.titleLabel.font = NewFonts.SFProDisplayBold32
    slide3.descriptionLabel.font = NewFonts.SFProDisplayRegular16
    slide3.titleLabel.textColor = .white
    slide3.descriptionLabel.textColor = .white
    return [slide1, slide2, slide3]
  }
  
  func setupSlideScrollView(slides : [PromoView]) {
    //promoScrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
    promoScrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
    promoScrollView.isPagingEnabled = true
    
    for i in 0 ..< slides.count {
      slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
      promoScrollView.addSubview(slides[i])
    }
  }
}

extension StartOnboardingViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
    promoPageControl.currentPage = Int(pageIndex)
  }
}

extension UIButton {
  
  func setBackgroundColor(color: UIColor, forState: UIControl.State) {
    
    UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
    UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
    UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
    let colorImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    self.setBackgroundImage(colorImage, for: forState)
  }
  
}
