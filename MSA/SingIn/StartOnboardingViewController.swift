//
//  SartOnboardingViewController.swift
//  MSA
//
//  Created by Nik on 26.07.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit

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
  
  var slides: [PromoView] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  func setupUI() {
    backgroundView.roundCorners([.topLeft,.topRight], radius: 10)
    titleLabel.font = UIFont(name: Fonts.SFProDisplayBold, size: 24)
    descriptionLabel.font = UIFont(name: Fonts.SFProDisplayRegular, size: 16)
    trainerButton.titleLabel?.font = UIFont(name: Fonts.SFProDisplayRegular, size: 14)
    sportsmanButton.titleLabel?.font = UIFont(name: Fonts.SFProDisplayRegular, size: 14)
    startButton.titleLabel?.font = UIFont(name: Fonts.SFProDisplayRegular, size: 14)
    privacyLabel.font = UIFont.systemFont(ofSize: 13)//UIFont(name: Fonts.SFProDisplayRegular, size: 50)
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
    startButton.setImage(UIImage(named: "doubleChevron"), for: .selected)
    trainerButton.roundCorners(.allCorners, radius: 12)
    sportsmanButton.roundCorners(.allCorners, radius: 12)
    startButton.roundCorners(.allCorners, radius: 12)
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
  
  @objc func trainerButtonAction(_ sender: UIButton) {
    let selected = trainerButton.isSelected
    sender.isSelected = !selected
    print("Trainer button:\(selected)")
    if sender.isSelected {
      sportsmanButton.isSelected = false
      startButton.isSelected = true
    }
  }
  
  @objc func sportsmanButtonAction(_ sender: UIButton) {
    let selected = sportsmanButton.isSelected
    sender.isSelected = !selected
    print("Sportsman button:\(selected)")
    if sender.isSelected {
      trainerButton.isSelected = false
      startButton.isSelected = true
    }
  }
  
  @objc func startButtonAction(_ sender: UIButton) {
    if sender.isSelected {
      let nextViewController = signInStoryboard.instantiateViewController(withIdentifier: "OnboardingNameViewController") as! OnboardingNameViewController
      self.navigationController?.pushViewController(nextViewController, animated: true)
    }
  }
  
  func createSlides() -> [PromoView] {
    
    let slide1 = Bundle.main.loadNibNamed("PromoView", owner: self, options: nil)?.first as! PromoView
    slide1.titleLabel.text = "Создание персональных тренировок"
    slide1.descriptionLabel.text = "Находите ваших клиентов и создавайте персональный программы тренировок и питания"
    slide1.titleLabel.font = UIFont(name: Fonts.SFProDisplayBold, size: 36)
    slide1.descriptionLabel.font = UIFont(name: Fonts.SFProDisplayRegular, size: 16)
    slide1.titleLabel.textColor = .white
    slide1.descriptionLabel.textColor = .white
    
    let slide2 = Bundle.main.loadNibNamed("PromoView", owner: self, options: nil)?.first as! PromoView
    slide2.titleLabel.text = "A real-life bear"
    slide2.descriptionLabel.text = "Did you know that Winnie the chubby little cubby was based on a real, young bear in London"
    slide2.titleLabel.font = UIFont(name: Fonts.SFProDisplayBold, size: 36)
    slide2.descriptionLabel.font = UIFont(name: Fonts.SFProDisplayRegular, size: 16)
    slide2.titleLabel.textColor = .white
    slide2.descriptionLabel.textColor = .white
    
    let slide3 = Bundle.main.loadNibNamed("PromoView", owner: self, options: nil)?.first as! PromoView
    slide3.titleLabel.text = "A real-life bear"
    slide3.descriptionLabel.text = "Did you know that Winnie the chubby little cubby was based on a real, young bear in London"
    slide3.titleLabel.font = UIFont(name: Fonts.SFProDisplayBold, size: 36)
    slide3.descriptionLabel.font = UIFont(name: Fonts.SFProDisplayRegular, size: 16)
    slide3.titleLabel.textColor = .white
    slide3.descriptionLabel.textColor = .white
    return [slide1, slide2, slide3]
  }
  
  func setupSlideScrollView(slides : [PromoView]) {
    promoScrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
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
