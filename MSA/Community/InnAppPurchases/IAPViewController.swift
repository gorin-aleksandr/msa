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
  
  let freeAccessLabel = UILabel()

  var oneMonthSubscriptionButton = UIButton()
  var twelveMonthSubscriptionButton = UIButton()
  var fullSubscriptionButton = UIButton()
  var toolTipImageView = UIImageView()
  var subscribeButton = UIButton()
  var subscribeLabel = UILabel()
  var selectedIndex = 1
  var presenter: IAPPresenterProtocol!
  var currentPrices:[NSDecimalNumber] = []
 
  override func viewDidLoad() {
    super.viewDidLoad()
    //        setPromotionText()
    SVProgressHUD.show()
    presenter.fetchSubscriptions()
    //        configureTableView()
    //        configureNavigationBar()
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(handlePurchaseSuccessfull(notification:)),
                                           name: InAppPurchasesService.purchaseSuccessfulNotification,
                                           object: nil)


    setupUI()
  }
  
   override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    SVProgressHUD.dismiss()
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
    
    closeButton.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
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
    
    titleLabel.text = AuthModule.currUser.userType == .trainer ? "Получи доступ к полному функционалу для тренера" : "Получи доступ к полному функционалу для спортсмена"
    titleLabel.font = NewFonts.SFProDisplayBold14
    titleLabel.textAlignment = .center
    titleLabel.textColor = .white
    titleLabel.numberOfLines = 0
    titleLabel.snp.makeConstraints { (make) in
      make.top.equalTo(self.iconImageView.snp.bottom).offset(screenSize.height * (12/iPhoneXHeight))
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
    
    firstAdvantageLabel.text = AuthModule.currUser.userType == .trainer ? "Открытое сообщество — знакомься, общайся и делись опытом" : "Открытое сообщество — найди своего персонального наставника"
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
    
    secondAdvantageLabel.text = AuthModule.currUser.userType == .trainer ? "Создавай неограниченное количество тренировок для клиентов" : "Программа тренировок в смартфоне — тренируйся, где тебе удобно"
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
    
    thirdAdvantageLabel.text = AuthModule.currUser.userType == .trainer ? "Контролируй параметры — все изменения тела в удобном графике" : "Отслеживай результат — все изменения тела в удобном графике"
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
    
    fourthAdvantageLabel.text = AuthModule.currUser.userType == .trainer ? "Включай креатив и добавляй собственные упражнения с фото и видео" : "Получай консультации — общайся с тренером во встроенном мессенджере"
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
    if AuthModule.currUser.userType == .trainer {
      twelveMonthSubscriptionButton.setImage(UIImage(named:"twelveMonthTrainer"), for: .normal)
      twelveMonthSubscriptionButton.setImage(UIImage(named:"twelveMonthTrainerSelected"), for: .selected)
      twelveMonthSubscriptionButton.isSelected = true
    } else {
      twelveMonthSubscriptionButton.setImage(UIImage(named:"twelveMonthSportsman"), for: .normal)
      twelveMonthSubscriptionButton.setImage(UIImage(named:"twelveMonthSportsmanSelected"), for: .selected)
      twelveMonthSubscriptionButton.isSelected = true
    }
    twelveMonthSubscriptionButton.addTarget(self, action: #selector(twelveMonthSelected), for: .touchUpInside)
    twelveMonthSubscriptionButton.snp.makeConstraints { (make) in
      make.top.equalTo(self.fourthAdvantageView.snp.bottom).offset(screenSize.height * (76/iPhoneXHeight))
      make.centerX.equalTo(self.view.snp.centerX)
      make.height.equalTo(screenSize.height * (140/iPhoneXHeight))
      make.width.equalTo(screenSize.height * (115/iPhoneXHeight))
    }
    
    self.view.addSubview(oneMonthSubscriptionButton)
    if AuthModule.currUser.userType == .trainer {
      oneMonthSubscriptionButton.setImage(UIImage(named:"oneMonthTrainer"), for: .normal)
      oneMonthSubscriptionButton.setImage(UIImage(named:"oneMonthTrainerSelected"), for: .selected)
    } else {
      oneMonthSubscriptionButton.setImage(UIImage(named:"oneMonthSportsman"), for: .normal)
      oneMonthSubscriptionButton.setImage(UIImage(named:"oneMonthSportsmanSelected"), for: .selected)
    }
    oneMonthSubscriptionButton.addTarget(self, action: #selector(oneMonthSelected), for: .touchUpInside)
    oneMonthSubscriptionButton.snp.makeConstraints { (make) in
      make.top.equalTo(self.fourthAdvantageView.snp.bottom).offset(screenSize.height * (88/iPhoneXHeight))
      make.right.equalTo(self.twelveMonthSubscriptionButton.snp.left).offset(screenSize.height * (-10/iPhoneXHeight))
      make.height.equalTo(screenSize.height * (117/iPhoneXHeight))
      make.width.equalTo(screenSize.height * (96/iPhoneXHeight))
    }
    
    
    self.view.addSubview(fullSubscriptionButton)
    if AuthModule.currUser.userType == .trainer {
      fullSubscriptionButton.setImage(UIImage(named:"fullAcessTrainer"), for: .normal)
      fullSubscriptionButton.setImage(UIImage(named:"fullAcessTrainerSelected"), for: .selected)
    } else {
      fullSubscriptionButton.setImage(UIImage(named:"fullAcessSportsman"), for: .normal)
      fullSubscriptionButton.setImage(UIImage(named:"fullAcessSportsmanSelected"), for: .selected)
    }
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
    
    subscribeButton.addTarget(self, action: #selector(purchaseAction), for: .touchUpInside)
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
    subscribeLabel.text = "Попробовать 3 дня бесплатно*"
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
    
    let rightDirectionImageView = UIImageView()
    rightDirectionImageView.image = UIImage(named:"doubleChevron")
    subscribeButton.addSubview(rightDirectionImageView)
    rightDirectionImageView.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.subscribeButton.snp.centerY)
      make.right.equalTo(self.subscribeButton.snp.right).offset(screenSize.height * (-6/iPhoneXHeight))
      make.width.equalTo(screenSize.width * (36/iPhoneXWidth))
      make.height.equalTo(screenSize.height * (28/iPhoneXHeight))
    }
    
    self.view.addSubview(freeAccessLabel)
    
    freeAccessLabel.text = "*Первые 3 дня — бесплатно, далее — $29,99/год"
    freeAccessLabel.font = NewFonts.SFProDisplayRegular10
    freeAccessLabel.numberOfLines = 0
    freeAccessLabel.textAlignment = .center
    freeAccessLabel.textColor = UIColor(red: 0.592, green: 0.592, blue: 0.592, alpha: 1)
    freeAccessLabel.snp.makeConstraints { (make) in
      make.top.equalTo(self.subscribeButton.snp.bottom).offset(screenSize.height * (8/iPhoneXHeight))
      make.centerX.equalTo(self.view.snp.centerX)
    }
    
    let detailAboutSubscription = UIButton()
       self.view.addSubview(detailAboutSubscription)
       detailAboutSubscription.setTitle("Детальнее про подписку    ", for: .normal)
       detailAboutSubscription.titleLabel?.font = NewFonts.SFProDisplayRegular13
       detailAboutSubscription.setTitleColor(UIColor(red: 0.592, green: 0.592, blue: 0.592, alpha: 1), for: .normal)
       detailAboutSubscription.addTarget(self, action: #selector(showDetailedSubscriptionInfo), for: .touchUpInside)
       detailAboutSubscription.snp.makeConstraints { (make) in
         make.top.equalTo(freeAccessLabel.snp.bottom).offset(screenSize.height * (40/iPhoneXHeight))
         make.centerX.equalTo(self.view.snp.centerX)
       }
    
    let detailRightDirectionImageView = UIImageView()
      detailAboutSubscription.addSubview(detailRightDirectionImageView)
       detailRightDirectionImageView.image = UIImage(named:"Vector-1")
       detailRightDirectionImageView.snp.makeConstraints { (make) in
         make.centerY.equalTo(detailAboutSubscription.snp.centerY)
         make.right.equalTo(detailAboutSubscription.snp.right)
//         make.width.equalTo(screenSize.width * (8/iPhoneXWidth))
//         make.height.equalTo(screenSize.height * (13/iPhoneXHeight))
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
    let repeatAction = UIAlertAction(title: "Повторить", style: .default) { (action) in   SVProgressHUD.show()
      self.presenter.fetchSubscriptions()
    }
    let cancelAction = UIAlertAction(title: "Отменить", style: .default) { (action) in }
    alertController.addAction(repeatAction)
    alertController.addAction(cancelAction)
    self.present(alertController, animated: true, completion: nil)
  }
  
  @objc func handlePurchaseSuccessfull(notification: Notification) {
      self.dismiss(animated: true, completion: nil)
  }
  
  
  private func setPromotionText() {
    //promotionTextLabel.text = "Саурде!"presenter.setPromotionText()
  }
  
  @objc func oneMonthSelected() {
    if !oneMonthSubscriptionButton.isSelected {
      oneMonthSubscriptionButton.isSelected = true
      twelveMonthSubscriptionButton.isSelected = false
      fullSubscriptionButton.isSelected = false
      freeAccessLabel.text = "*Первые 3 дня — бесплатно, далее — $\(currentPrices[0])/год"
      selectedIndex = 0
    }
  }
  
  @objc func twelveMonthSelected() {
    if !twelveMonthSubscriptionButton.isSelected {
      twelveMonthSubscriptionButton.isSelected = true
      oneMonthSubscriptionButton.isSelected = false
      fullSubscriptionButton.isSelected = false
      freeAccessLabel.text = "*Первые 3 дня — бесплатно, далее — $\(currentPrices[1])/год"
      selectedIndex = 1
    }
  }
  
  @objc func fullSubscriptionSelected() {
    if !fullSubscriptionButton.isSelected {
      fullSubscriptionButton.isSelected = true
      oneMonthSubscriptionButton.isSelected = false
      twelveMonthSubscriptionButton.isSelected = false
      freeAccessLabel.text = "*Первые 3 дня — бесплатно, далее — $\(currentPrices[2])/год"
      selectedIndex = 2
    }
  }
  
  @objc func closeButtonAction() {
    self.dismiss(animated: true, completion: nil)
  }
  
  @objc func purchaseAction() {
    presenter.userSelectedProductAt(index: selectedIndex)
  }
  
  func setupButtons() {
    currentPrices =  presenter.getProductsDataSource().map({ (item) -> NSDecimalNumber in
      return item.product.price
    })
    freeAccessLabel.text = "*Первые 3 дня — бесплатно, далее — $\(currentPrices[1])/год"
  }
  
  @objc func showDetailedSubscriptionInfo() {
    let alert = UIAlertController(title: "Информация о подписке", message: "В течении пробного трёх дневного периода плата не снимается. Отменить подписку можно в любое время .  Оплата будет снята с вашей учетной записи iTunes по истечению пробного периода. Подписка продлевается автоматически, если автоматическое продление не отключено по крайней мере за 24 часа до окончания текущего периода.  С вашей учетной записи будет взиматься плата за продление в течение 24 часов до окончания текущего периода из расчета 5,99$ долларов в месяц или 29,99$ в год.  Вы можете управлять своей  подпиской, посетив настройки учетной записи iTunes после покупки.  Любая неиспользованная часть бесплатного пробного периода, если таковая предлагается, будет аннулирована при покупке пожизненной подписки.", preferredStyle: .actionSheet)
      alert.addAction(UIAlertAction.init(title: "Понятно", style: .cancel, handler: { _ in
      }))
      self.present(alert, animated: true, completion: nil)
  }
  
  @objc func goBack() {
    self.dismiss(animated: true, completion: nil)
  }
  
  func reloadView() {
    //tableView.reloadData()
    SVProgressHUD.dismiss()
    setupButtons()
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
