//
//  IAPViewController.swift
//  MSA
//
//  Created by Andrey Krit on 2/27/19.
//  Copyright © 2019 Pavlo Kharambura. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol IAPViewProtocol: class {
  func reloadView()
  func setLoaderVisible(_ visible: Bool)
  func showAlert(error: String)
}

class IAPViewController: UIViewController, IAPViewProtocol {
  
  //    @IBOutlet weak var promotionTextLabel: UILabel!
  //    @IBOutlet weak var tableView: UITableView!
  //    @IBOutlet weak var termsButton: UIButton!
  
  @IBOutlet weak var backgroundImageView: UIImageView!
  @IBOutlet weak var backgroundBluredView: UIView!
  @IBOutlet weak var closeButton: UIButton!
  @IBOutlet weak var iconImageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  
  @IBOutlet weak var firstAdvantageView: UIView!
  @IBOutlet weak var firstAdvantageLabel: UILabel!
  @IBOutlet weak var firstAdvantageImageView: UIImageView!
  @IBOutlet weak var secondAdvantageView: UIView!
  @IBOutlet weak var secondAdvantageLabel: UILabel!
  @IBOutlet weak var secondAdvantageImageView: UIImageView!
  @IBOutlet weak var thirdAdvantageView: UIView!
  @IBOutlet weak var thirdAdvantageLabel: UILabel!
  @IBOutlet weak var thirdAdvantageImageView: UIImageView!
  @IBOutlet weak var fourthAdvantageView: UIView!
  @IBOutlet weak var fourthAdvantageLabel: UILabel!
  @IBOutlet weak var fourthAdvantageImageView: UIImageView!
  
  var oneMonthSubscriptionButton = UIButton()
  var twelveMonthSubscriptionButton = UIButton()
  var fullSubscriptionButton = UIButton()
  var toolTipImageView = UIImageView()
  var subscribeButton = UIButton()
  var subscribeLabel = UILabel()

  var presenter: IAPPresenterProtocol!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //        setPromotionText()
    //        presenter.fetchSubscriptions()
    //        configureTableView()
    //        configureNavigationBar()
    setupUI()
  }
  
  func setupUI() {
    backgroundImageView.snp.makeConstraints { (make) in
      make.top.equalTo(self.view.snp.top)
      make.bottom.equalTo(self.view.snp.bottom)
      make.right.equalTo(self.view.snp.right)
      make.left.equalTo(self.view.snp.left)
    }
    
    backgroundBluredView.backgroundColor = UIColor(red: 0.35, green: 0.45, blue: 0.60, alpha: 0.35)
    backgroundBluredView.snp.makeConstraints { (make) in
      make.top.equalTo(self.backgroundImageView.snp.top)
      make.bottom.equalTo(self.backgroundImageView.snp.bottom)
      make.right.equalTo(self.backgroundImageView.snp.right)
      make.left.equalTo(self.backgroundImageView.snp.left)
    }
    
    closeButton.snp.makeConstraints { (make) in
      make.top.equalTo(self.backgroundImageView.snp.top).offset(screenSize.height * (20/iPhoneXHeight))
      make.right.equalTo(self.backgroundImageView.snp.right).offset(screenSize.height * (-20/iPhoneXHeight))
      make.height.width.equalTo(24)
    }
    
    iconImageView.snp.makeConstraints { (make) in
      make.top.equalTo(self.backgroundImageView.snp.top).offset(screenSize.height * (20/iPhoneXHeight))
      make.centerX.equalTo(self.backgroundImageView.snp.centerX)
      make.height.width.equalTo(screenSize.height * (58/iPhoneXHeight))
    }
    
    titleLabel.text = "Получи доступ к полному функционалу для тренеров"
    titleLabel.font = NewFonts.SFProDisplayBold14
    titleLabel.textAlignment = .center
    titleLabel.textColor = .white
    titleLabel.numberOfLines = 0
    titleLabel.snp.makeConstraints { (make) in
      make.top.equalTo(self.iconImageView.snp.top).offset(screenSize.height * (12/iPhoneXHeight))
      make.right.equalTo(self.backgroundImageView.snp.right).offset(screenSize.height * (-64/iPhoneXHeight))
      make.left.equalTo(self.backgroundImageView.snp.left).offset(screenSize.height * (64/iPhoneXHeight))
    }
    
    firstAdvantageView.backgroundColor = UIColor(red: 0.365, green: 0.62, blue: 0.965, alpha: 0.76)
    firstAdvantageView.cornerRadius = screenSize.height * (16/iPhoneXHeight)
    firstAdvantageView.snp.makeConstraints { (make) in
      make.top.equalTo(self.titleLabel.snp.bottom).offset(screenSize.height * (21/iPhoneXHeight))
      make.right.equalTo(self.backgroundImageView.snp.right).offset(screenSize.height * (-16/iPhoneXHeight))
      make.left.equalTo(self.backgroundImageView.snp.left).offset(screenSize.height * (16/iPhoneXHeight))
      make.height.equalTo(screenSize.height * (48/iPhoneXHeight))
    }
    
    firstAdvantageImageView.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.firstAdvantageView.snp.centerY)
      make.left.equalTo(self.firstAdvantageView.snp.left).offset(screenSize.height * (8/iPhoneXHeight))
      make.height.width.equalTo(screenSize.height * (24/iPhoneXHeight))
    }
    
    firstAdvantageLabel.text = "Открытое сообщество — знакомься, общайся и делись опытом"
    firstAdvantageLabel.textColor = .white
    firstAdvantageLabel.font = NewFonts.SFProDisplayRegular14
    firstAdvantageLabel.numberOfLines = 0
    firstAdvantageLabel.snp.makeConstraints { (make) in
         make.top.equalTo(self.firstAdvantageView.snp.top).offset(screenSize.height * (7/iPhoneXHeight))
         make.top.equalTo(self.firstAdvantageView.snp.bottom).offset(screenSize.height * (-7/iPhoneXHeight))
         make.left.equalTo(self.firstAdvantageImageView.snp.right).offset(screenSize.height * (12/iPhoneXHeight))
        make.right.equalTo(self.firstAdvantageView.snp.right).offset(screenSize.height * (-13/iPhoneXHeight))

    }
    
    secondAdvantageView.backgroundColor = UIColor(red: 0.365, green: 0.62, blue: 0.965, alpha: 0.76)
    secondAdvantageView.cornerRadius = screenSize.height * (16/iPhoneXHeight)
    secondAdvantageView.snp.makeConstraints { (make) in
      make.top.equalTo(self.firstAdvantageView.snp.bottom).offset(screenSize.height * (8/iPhoneXHeight))
      make.right.equalTo(self.backgroundImageView.snp.right).offset(screenSize.height * (-16/iPhoneXHeight))
      make.left.equalTo(self.backgroundImageView.snp.left).offset(screenSize.height * (16/iPhoneXHeight))
      make.height.equalTo(screenSize.height * (48/iPhoneXHeight))
    }
    
    secondAdvantageImageView.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.secondAdvantageView.snp.centerY)
      make.left.equalTo(self.secondAdvantageView.snp.left).offset(screenSize.height * (8/iPhoneXHeight))
      make.height.width.equalTo(screenSize.height * (24/iPhoneXHeight))
    }
    
    secondAdvantageLabel.text = "Создавай неограниченное количество тренировок для клиентов"
    secondAdvantageLabel.textColor = .white
    secondAdvantageLabel.font = NewFonts.SFProDisplayRegular14
    secondAdvantageLabel.numberOfLines = 0
    secondAdvantageLabel.snp.makeConstraints { (make) in
         make.top.equalTo(self.secondAdvantageView.snp.top).offset(screenSize.height * (7/iPhoneXHeight))
         make.top.equalTo(self.secondAdvantageView.snp.bottom).offset(screenSize.height * (-7/iPhoneXHeight))
         make.left.equalTo(self.secondAdvantageImageView.snp.right).offset(screenSize.height * (12/iPhoneXHeight))
         make.right.equalTo(self.fourthAdvantageView.snp.right).offset(screenSize.height * (-13/iPhoneXHeight))

    }
    
    thirdAdvantageView.backgroundColor = UIColor(red: 0.365, green: 0.62, blue: 0.965, alpha: 0.76)
    thirdAdvantageView.cornerRadius = screenSize.height * (16/iPhoneXHeight)
    thirdAdvantageView.snp.makeConstraints { (make) in
      make.top.equalTo(self.secondAdvantageView.snp.bottom).offset(screenSize.height * (8/iPhoneXHeight))
      make.right.equalTo(self.backgroundImageView.snp.right).offset(screenSize.height * (-16/iPhoneXHeight))
      make.left.equalTo(self.backgroundImageView.snp.left).offset(screenSize.height * (16/iPhoneXHeight))
      make.height.equalTo(screenSize.height * (48/iPhoneXHeight))
    }
    
    thirdAdvantageImageView.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.thirdAdvantageView.snp.centerY)
      make.left.equalTo(self.thirdAdvantageView.snp.left).offset(screenSize.height * (8/iPhoneXHeight))
      make.height.width.equalTo(screenSize.height * (24/iPhoneXHeight))
    }
    
    thirdAdvantageLabel.text = "Контролируй параметры — все изменения тела в удобном графике"
    thirdAdvantageLabel.textColor = .white
    thirdAdvantageLabel.font = NewFonts.SFProDisplayRegular14
    thirdAdvantageLabel.numberOfLines = 0
    thirdAdvantageLabel.snp.makeConstraints { (make) in
         make.top.equalTo(self.thirdAdvantageView.snp.top).offset(screenSize.height * (7/iPhoneXHeight))
         make.top.equalTo(self.thirdAdvantageView.snp.bottom).offset(screenSize.height * (-7/iPhoneXHeight))
         make.left.equalTo(self.thirdAdvantageImageView.snp.right).offset(screenSize.height * (12/iPhoneXHeight))
        make.right.equalTo(self.thirdAdvantageView.snp.right).offset(screenSize.height * (-13/iPhoneXHeight))
    }
    
    fourthAdvantageView.backgroundColor = UIColor(red: 0.365, green: 0.62, blue: 0.965, alpha: 0.76)
    fourthAdvantageView.cornerRadius = screenSize.height * (16/iPhoneXHeight)
    fourthAdvantageView.snp.makeConstraints { (make) in
      make.top.equalTo(self.thirdAdvantageView.snp.bottom).offset(screenSize.height * (8/iPhoneXHeight))
      make.right.equalTo(self.backgroundImageView.snp.right).offset(screenSize.height * (-16/iPhoneXHeight))
      make.left.equalTo(self.backgroundImageView.snp.left).offset(screenSize.height * (16/iPhoneXHeight))
      make.height.equalTo(screenSize.height * (48/iPhoneXHeight))
    }
    
    fourthAdvantageImageView.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.fourthAdvantageView.snp.centerY)
      make.left.equalTo(self.fourthAdvantageView.snp.left).offset(screenSize.height * (8/iPhoneXHeight))
      make.height.width.equalTo(screenSize.height * (24/iPhoneXHeight))
    }
    
    fourthAdvantageLabel.text = "Включай креатив и добавляй собственные упражнения с фото и видео"
    fourthAdvantageLabel.textColor = .white
    fourthAdvantageLabel.font = NewFonts.SFProDisplayRegular14
    fourthAdvantageLabel.numberOfLines = 0
    fourthAdvantageLabel.snp.makeConstraints { (make) in
         make.top.equalTo(self.fourthAdvantageView.snp.top).offset(screenSize.height * (7/iPhoneXHeight))
         make.top.equalTo(self.fourthAdvantageView.snp.bottom).offset(screenSize.height * (-7/iPhoneXHeight))
         make.left.equalTo(self.fourthAdvantageImageView.snp.right).offset(screenSize.height * (12/iPhoneXHeight))
        make.right.equalTo(self.fourthAdvantageView.snp.right).offset(screenSize.height * (-13/iPhoneXHeight))
    }
    
 
    self.view.addSubview(twelveMonthSubscriptionButton)
    twelveMonthSubscriptionButton.setImage(UIImage(named:"twelveMonthNormal"), for: .normal)
    twelveMonthSubscriptionButton.setImage(UIImage(named:"twelveMonthSelected"), for: .selected)
    twelveMonthSubscriptionButton.addTarget(self, action: #selector(twelveMonthSelected), for: .touchUpInside)
    twelveMonthSubscriptionButton.snp.makeConstraints { (make) in
         make.top.equalTo(self.fourthAdvantageView.snp.bottom).offset(screenSize.height * (76/iPhoneXHeight))
         make.centerX.equalTo(self.view.snp.centerX)
         make.height.equalTo(screenSize.height * (140/iPhoneXHeight))
         make.width.equalTo(screenSize.height * (115/iPhoneXHeight))
    }
    
    self.view.addSubview(oneMonthSubscriptionButton)
     oneMonthSubscriptionButton.setImage(UIImage(named:"oneMonthNormal"), for: .normal)
     oneMonthSubscriptionButton.setImage(UIImage(named:"oneMonthSelected"), for: .selected)
     oneMonthSubscriptionButton.addTarget(self, action: #selector(oneMonthSelected), for: .touchUpInside)
     oneMonthSubscriptionButton.snp.makeConstraints { (make) in
          make.top.equalTo(self.fourthAdvantageView.snp.bottom).offset(screenSize.height * (88/iPhoneXHeight))
          make.right.equalTo(self.twelveMonthSubscriptionButton.snp.left).offset(screenSize.height * (-10/iPhoneXHeight))
          make.height.equalTo(screenSize.height * (117/iPhoneXHeight))
          make.width.equalTo(screenSize.height * (96/iPhoneXHeight))
     }
     
    
    self.view.addSubview(fullSubscriptionButton)
    fullSubscriptionButton.setImage(UIImage(named:"fullSubscriptionNormal"), for: .normal)
    fullSubscriptionButton.setImage(UIImage(named:"fullSubscriptionMonthSelected"), for: .selected)
    fullSubscriptionButton.addTarget(self, action: #selector(fullSubscriptionSelected), for: .touchUpInside)
    fullSubscriptionButton.snp.makeConstraints { (make) in
         make.top.equalTo(self.fourthAdvantageView.snp.bottom).offset(screenSize.height * (88/iPhoneXHeight))
         make.left.equalTo(self.twelveMonthSubscriptionButton.snp.right).offset(screenSize.height * (10/iPhoneXHeight))
         make.height.equalTo(screenSize.height * (117/iPhoneXHeight))
         make.width.equalTo(screenSize.height * (96/iPhoneXHeight))
    }
    
       self.view.addSubview(toolTipImageView)
       toolTipImageView.image = UIImage(named:"Tooltip")
       toolTipImageView.contentMode = .scaleAspectFill
       toolTipImageView.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.twelveMonthSubscriptionButton.snp.top)
            make.centerX.equalTo(self.twelveMonthSubscriptionButton.snp.centerX)
            make.height.equalTo(screenSize.height * (51/iPhoneXHeight))
            make.width.equalTo(screenSize.height * (241/iPhoneXHeight))
       }
    
    self.view.addSubview(subscribeButton)
    subscribeButton.setBackgroundColor(color: UIColor(red: 0.341, green: 0.6, blue: 0.361, alpha: 1), forState: .normal)
    subscribeButton.layer.cornerRadius = screenSize.height * (16/iPhoneXHeight)
    subscribeButton.maskToBounds = true
    subscribeButton.snp.makeConstraints { (make) in
          make.top.equalTo(self.fullSubscriptionButton.snp.bottom).offset(screenSize.height * (35/iPhoneXHeight))
          make.centerX.equalTo(self.twelveMonthSubscriptionButton.snp.centerX)
          make.height.equalTo(screenSize.height * (66/iPhoneXHeight))
          make.width.equalTo(screenSize.width * (335/iPhoneXWidth))
     }
    
    subscribeButton.addSubview(subscribeLabel)
    subscribeLabel.text = "Начать пробный период на 3 дня затем 5.99$ в месяц"
    subscribeLabel.numberOfLines = 0
    subscribeLabel.font = NewFonts.SFProDisplayBold14
    subscribeLabel.textAlignment = .center
    subscribeLabel.textColor = .white
    subscribeLabel.snp.makeConstraints { (make) in
           make.top.equalTo(self.subscribeButton.snp.top).offset(screenSize.height * (7/iPhoneXHeight))
           make.bottom.equalTo(self.subscribeButton.snp.bottom).offset(screenSize.height * (-7/iPhoneXHeight))
           make.left.equalTo(self.subscribeButton.snp.left).offset(screenSize.height * (10/iPhoneXHeight))
           make.right.equalTo(self.subscribeButton.snp.right).offset(screenSize.height * (-10/iPhoneXHeight))
    }
    
    var rightDirectionImageView = UIImageView()
    rightDirectionImageView.image = UIImage(named:"doubleChevron")
    subscribeButton.addSubview(rightDirectionImageView)
    rightDirectionImageView.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.subscribeButton.snp.centerY)
      make.right.equalTo(self.subscribeButton.snp.right).offset(screenSize.height * (-6/iPhoneXHeight))
      make.width.equalTo(screenSize.width * (36/iPhoneXWidth))
      make.height.equalTo(screenSize.width * (28/iPhoneXHeight))
    }
    
    
    
  }
  
  private func configureTableView() {
    //        tableView.delegate = self
    //        tableView.dataSource = self
  }
  
  private func configureNavigationBar() {
    let dismissButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ok_blue"), style: .plain, target: self, action: #selector(self.goBack))
    navigationItem.rightBarButtonItem = dismissButton
    self.navigationItem.title = "Покупки"
    let attrs = [NSAttributedString.Key.foregroundColor: UIColor.white,
                 NSAttributedString.Key.font: UIFont(name: "Rubik-Medium", size: 17)!]
    self.navigationController?.navigationBar.titleTextAttributes = attrs
    self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    self.navigationController?.navigationBar.isTranslucent = true
    self.navigationController?.view.backgroundColor = .clear
  }
  
  func showAlert(error: String) {
    let alertController = UIAlertController(title: "Ошибка при загрузке встроеных покупок", message: error, preferredStyle: .alert)
    let repeatAction = UIAlertAction(title: "Повторить", style: .default) { (action) in
      self.presenter.fetchSubscriptions()
    }
    let cancelAction = UIAlertAction(title: "Отменить", style: .default) { (action) in }
    alertController.addAction(repeatAction)
    alertController.addAction(cancelAction)
    self.present(alertController, animated: true, completion: nil)
  }
  
  
  private func setPromotionText() {
    //promotionTextLabel.text = "Саурде!"presenter.setPromotionText()
  }
  
  @objc func oneMonthSelected() {
    oneMonthSubscriptionButton.isSelected = !oneMonthSubscriptionButton.isSelected
  }
  
  @objc func twelveMonthSelected() {
    twelveMonthSubscriptionButton.isSelected = !twelveMonthSubscriptionButton.isSelected
  }
  
  @objc func fullSubscriptionSelected() {
    fullSubscriptionButton.isSelected = !fullSubscriptionButton.isSelected
  }
  
  @objc func goBack() {
    self.dismiss(animated: true, completion: nil)
  }
  
  func reloadView() {
    //tableView.reloadData()
  }
  
  func setLoaderVisible(_ visible: Bool) {
    // visible ? SVProgressHUD.show() : SVProgressHUD.dismiss()
  }
  
  @IBAction func temsButtonDidTapped(_ sender: Any) {
    // presenter.presentTermsAndConditions()
  }
}

//extension IAPViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return presenter.getProductsDataSource().count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "IAPTableViewCell") as! IAPTableViewCell
//        cell.configureWith(product: presenter.getProductsDataSource()[indexPath.row])
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        presenter.userSelectedProductAt(index: indexPath.row)
//    }
//
//
//}
