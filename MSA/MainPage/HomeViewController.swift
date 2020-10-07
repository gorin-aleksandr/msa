//
//  HomeViewController.swift
//  
//
//  Created by Nik on 17.08.2020.
//

import UIKit
import SVProgressHUD
import Bugsnag
import Firebase
import SwiftRater
import AVKit
import SPPermissions


class HomeViewController: UIViewController {
  @IBOutlet weak var collectionView: UICollectionView!
  var images = ["powerlifter","ruller","eat","statsIcon","team"]
  var titles = ["Тренировки","Замеры","Питание","Статистика","Мои спортсмены"]
  var descriptions = ["Работай на результат","Ваши параметры","Добавьте рацион","Ваши результаты","У вас 23 спортсмена"]
  var viewModel = ProfileViewModel()
  let pushManager = PushNotificationManager()
  private let presenter = GalleryDataPresenter(gallery: GalleryDataManager())
  let p = ExersisesTypesPresenter(exercises: ExersisesDataManager())
  var comunityPresenter: CommunityListPresenterProtocol!
  var permissionController: SPPermissionsDialogController?
  let defaults = UserDefaults.standard

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    comunityPresenter = CommunityListPresenter(view: self)
    setupPermissionAlert()

    InAppPurchasesService.shared.uploadReceipt { [weak self] loaded in
      self?.logInAppPurhaseRenewalEvent()
      if InAppPurchasesService.shared.currentSubscription != nil {
        print("Full acess")
      } else {
        print("Havent acess!")
      }
    }
    
    if viewModel.selectedUser == nil {
      SVProgressHUD.show()
      self.viewModel.getUser(success: {
         SVProgressHUD.dismiss()
         self.collectionView.reloadData()
       })
    }
  }
 
  override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
         SwiftRater.check()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    downloadExercises()

    if viewModel.selectedUser != nil {
      navigationController?.setNavigationBarHidden(false, animated: false)
      let backButton = UIBarButtonItem(image: UIImage(named: "backIcon"), style: .plain, target: self, action: #selector(self.backAction))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.navigationBar.tintColor = .newBlack
    } else {
      navigationController?.setNavigationBarHidden(true, animated: false)
    }
  }
  
  func setupPermissionAlert() {
    let defaults = UserDefaults.standard
    let mainPermission = defaults.bool(forKey: "allowedMainNotificationPermission")
    permissionController = SPPermissions.dialog([.notification])
    permissionController!.titleText = "Нужно разрешение"
    permissionController!.headerText = ""
    permissionController!.footerText = ""
    permissionController!.dataSource = self
    permissionController!.delegate = self
    let state = SPPermission.notification.isAuthorized
    if !state && !mainPermission {
      defaults.set(true, forKey: "allowedMainNotificationPermission")
      permissionController!.present(on: self)
    }
  }
  
  @objc func backAction() {
    self.navigationController?.popViewController(animated: true)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    navigationController?.setNavigationBarHidden(false, animated: false)
  }
  
  func setupUI() {
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.snp.makeConstraints { (make) in
      make.top.equalTo(self.view.snp.top)
      make.bottom.equalTo(self.view.snp.bottom)
      make.right.equalTo(self.view.snp.right)
      make.left.equalTo(self.view.snp.left)
    }
  }
  
  private func downloadExercises() {
    p.getExercisesFromRealm()
    p.getTypesFromRealm()
    p.getFiltersFromRealm()
    p.getMyExercisesFromRealm()
    
    p.getAllExersises()
    p.getAllTypes()
    p.getAllFilters()
    p.getMyExercises()
  }

  func logInAppPurhaseRenewalEvent() {
    let defaults = UserDefaults.standard
    if let lastExpireDate = defaults.object(forKey: "inAppPurchaseExpireDate") as? Date, let lastPurchaseisTrial = defaults.object(forKey: "inAppPurchaseIsTrial") as? String {
      if let expireDate = InAppPurchasesService.shared.currentSubscription?.expiresDate, let isTrial =  InAppPurchasesService.shared.currentSubscription?.isTrialPeriod, let purchaseName =  InAppPurchasesService.shared.currentSubscription?.productId {
        
        if lastPurchaseisTrial == "true" && isTrial == "false" {
          defaults.set("false", forKey: "inAppPurchaseIsTrial")
          defaults.set(expireDate, forKey: "inAppPurchaseExpireDate")
          switch purchaseName {
            case "s_one_month":
              Analytics.logEvent("app_store_subscription_convert_sportsman_1m", parameters: nil)
            case "s_twelve_month":
              Analytics.logEvent("app_store_subscription_convert_sportsman_1y", parameters: nil)
            case "t_one_month":
              Analytics.logEvent("app_store_subscription_convert_coach_1m", parameters: nil)
            case "t_twelve_month":
              Analytics.logEvent("app_store_subscription_convert_coach_1y", parameters: nil)
            case "s_fullAcess":
              Analytics.logEvent("app_store_subscription_convert_sportsman_fullAcess", parameters: nil)
            case "t_fullAcess":
              Analytics.logEvent("app_store_subscription_convert_coach_fullAcess", parameters: nil)
            default:
              return
          }
          return
        }
        
        if lastExpireDate < expireDate {
          defaults.set(expireDate, forKey: "inAppPurchaseExpireDate")
          switch purchaseName {
            case "s_one_month":
              Analytics.logEvent("app_store_subscription_convert_sportsman_1m", parameters: nil)
            case "s_twelve_month":
              Analytics.logEvent("app_store_subscription_convert_sportsman_1y", parameters: nil)
            case "t_one_month":
              Analytics.logEvent("app_store_subscription_renew_coach_1m", parameters: nil)
            case "t_twelve_month":
              Analytics.logEvent("app_store_subscription_renew_coach_1y", parameters: nil)
            case "s_fullAcess":
              Analytics.logEvent("app_store_subscription_renew_sportsman_fullAcess", parameters: nil)
            case "t_fullAcess":
              Analytics.logEvent("app_store_subscription_renew_coach_fullAcess", parameters: nil)
            default:
              return
          }
        }
      }
    } else {
      if let expireDate = InAppPurchasesService.shared.currentSubscription?.expiresDate {
        defaults.set(expireDate, forKey: "inAppPurchaseExpireDate")
        defaults.set(InAppPurchasesService.shared.currentSubscription!.isTrialPeriod, forKey: "inAppPurchaseIsTrial")
      }
    }
  }
}


extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch section {
      case 0:
        return 1
      case 1:
        if viewModel.selectedUser != nil {
          return 0
        }
        if let showDashboardShare = defaults.object(forKey: "showDashboardShare") as? Bool {
          if showDashboardShare == false {
            return 0
          }
        }
        return 1
      case 2:
        if AuthModule.currUser.userType == .trainer && viewModel.selectedUser == nil {
          return 5
        }
        if viewModel.selectedUser != nil {
          return 4
        }
        return 4
      default:
        return 6
    }
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 3
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 12, left: screenSize.width * (20/iPhoneXWidth), bottom: 0, right: screenSize.width * (20/iPhoneXWidth))
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    //    let padding: CGFloat =  1
    //    let collectionViewSizeWidth = collectionView.frame.size.width - padding
    //    let collectionViewSizeHeight = collectionView.frame.size.height - padding
    
    if indexPath.section == 0 {
      return CGSize(width: screenSize.width * (335/iPhoneXWidth), height: screenSize.height * (80/iPhoneXHeight))
    } else if indexPath.section == 1  {
      return CGSize(width: screenSize.width * (335/iPhoneXWidth), height: screenSize.height * (127/iPhoneXHeight))
    } else {
      if indexPath.row != 4 {
        return CGSize(width: screenSize.width * (162/iPhoneXWidth), height: screenSize.height * (124/iPhoneXHeight))
      } else {
        return CGSize(width: screenSize.width * (335/iPhoneXWidth), height: screenSize.height * (124/iPhoneXHeight))
        
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    if indexPath.section == 0 {
      let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeProfileCollectionViewCell", for: indexPath as IndexPath) as! HomeProfileCollectionViewCell
      if viewModel.selectedUser == nil {
        if let url = AuthModule.currUser.avatar {
          myCell.logoImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named:"Group-1"), options: .allowInvalidSSLCertificates, completed: nil)
        } else {
          myCell.logoImageView.image = UIImage(named:"Group-1")
        }
      } else {
        if let url = viewModel.selectedUser?.avatar {
          myCell.logoImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named:"Group-1"), options: .allowInvalidSSLCertificates, completed: nil)
        } else {
          myCell.logoImageView.image = UIImage(named:"Group-1")
        }
      }
      myCell.logoImageView.cornerRadius = myCell.logoImageView.frame.width/2
      if let selectedUser = viewModel.selectedUser  {
        myCell.titleLabel.text = "\(selectedUser.firstName ?? "") \(selectedUser.lastName ?? "")"
      } else {
        myCell.titleLabel.text = "\(AuthModule.currUser.firstName ?? "") \(AuthModule.currUser.lastName ?? "")"
      }
      myCell.layer.cornerRadius = screenSize.height * (16/iPhoneXHeight)
      myCell.layer.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.00).cgColor
      myCell.layer.masksToBounds = false
      return myCell
      
    } else if indexPath.section == 1 {
      let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShareAppCollectionViewCell", for: indexPath as IndexPath) as! ShareAppCollectionViewCell
      myCell.titleLabel.text = AuthModule.currUser.userType == .trainer ? "Поделись профилем MSA со своим спортсменом" : "Ходишь в зал с другом? Поделись MSA чтобы прогрессировать вместе!"
      myCell.shareTextButton.addTarget(self, action: #selector(shareProfileAction(_:)), for: .touchUpInside)
      myCell.shareImageButton.addTarget(self, action: #selector(shareProfileAction(_:)), for: .touchUpInside)
      myCell.notNowButton.addTarget(self, action: #selector(notNowShareProfileAction(_:)), for: .touchUpInside)
      return myCell
    } else {
      let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath as IndexPath) as! HomeCollectionViewCell
      myCell.logoImageView.image = UIImage(named: images[indexPath.row])
      myCell.titleLabel.text = titles[indexPath.row]

      if indexPath.row == 2 || indexPath.row == 3 {
        myCell.addBluredView()
      }
      
      if indexPath.row != 4 {
        myCell.descriptionLabel.text = descriptions[indexPath.row]
      } else {
        if let sportsmanCount = AuthModule.currUser.sportsmen?.count {
          myCell.descriptionLabel.text = "У вас \(sportsmanCount) спортсменов"
        } else {
          myCell.descriptionLabel.text = "У вас нет спортсменов"
        }
      }
      myCell.contentView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.00)
      myCell.contentView.cornerRadius = screenSize.height * (10/iPhoneXHeight)
      myCell.layer.masksToBounds = false
      return myCell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if indexPath.section == 0 {
      let vc = newProfileStoryboard.instantiateViewController(withIdentifier: "NewProfileViewController") as! NewProfileViewController
      vc.viewModel = viewModel
      let nc = UINavigationController(rootViewController: vc)
      nc.modalPresentationStyle = .fullScreen
      self.present(nc, animated: true, completion: nil)
    }
    
    if indexPath.section == 2 {
      switch indexPath.row {
        case 0:
          DispatchQueue.main.async {
            if let selectedUser = self.viewModel.selectedUser  {
            let destinationVC = UIStoryboard(name: "Trannings", bundle: nil).instantiateViewController(withIdentifier: "MyTranningsViewController") as! MyTranningsViewController
              destinationVC.manager.trainingType = .notMine(userId: selectedUser.id)
                   self.navigationController?.pushViewController(destinationVC, animated: true)
            } else {
              let vc = trainingStoryboard.instantiateViewController(withIdentifier: "MyTranningsViewController") as! MyTranningsViewController
              self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        case 1:
          DispatchQueue.main.async {
         let nextViewController = measurementsStoryboard.instantiateViewController(withIdentifier: "MeasurementsViewController") as! MeasurementsViewController
            nextViewController.viewModel = MeasurementViewModel()
            if let selectedUser = self.viewModel.selectedUser  {
              guard let userId = selectedUser.id else {return}
              nextViewController.viewModel!.selectedUserId = userId
            } else {
              guard let userId = AuthModule.currUser.id else {return}
              nextViewController.viewModel!.selectedUserId = userId
            }
            self.navigationController?.pushViewController(nextViewController, animated: true)
            }
        case 2:
            AlertDialog.showAlert("Спасибо, что ты с нами 💪", message: "Мы активно разрабатываем этот блок👨‍💻", viewController: self)
        case 3:
            AlertDialog.showAlert("Спасибо, что ты с нами 💪", message: "Мы активно разрабатываем этот блок👨‍💻", viewController: self)
         case 4:
          DispatchQueue.main.async {
          let vc = newProfileStoryboard.instantiateViewController(withIdentifier: "UsersSportsmansViewController") as! UsersSportsmansViewController
          vc.showSearchBarForMySportsMan = true
          vc.viewModel = CommunityViewModel()
          self.navigationController?.pushViewController(vc, animated: true)
        }
        default:
          return
      }
    }
    
  }
  
  @objc func notNowShareProfileAction(_ sender: UIButton) {
    defaults.set(false, forKey: "showDashboardShare")
    collectionView.reloadData()
  }
  
  @objc func shareProfileAction(_ sender: UIButton) {
    
    guard let sharelink = URL(string: "https://msafitnessapp.com/users=\(AuthModule.currUser.id ?? "")") else { return }
    guard let dynLink = DynamicLinkComponents.init(link: sharelink, domainURIPrefix: "https://easyapps.page.link") else { return }
    let options = DynamicLinkComponentsOptions()
    options.pathLength = .short
    dynLink.options = options
    var shortUrl = dynLink.url
    if let bundleID = Bundle.main.bundleIdentifier {
        dynLink.iOSParameters = DynamicLinkIOSParameters(bundleID: bundleID)
        dynLink.iOSParameters!.appStoreID = "1440506128"
        dynLink.iOSParameters!.fallbackURL = URL(string: "https://apps.apple.com/ua/app/msa-my-sport-assistant/id1440506128?l=ru")
        dynLink.androidParameters = DynamicLinkAndroidParameters(packageName: bundleID)
    }
    dynLink.otherPlatformParameters = DynamicLinkOtherPlatformParameters()
    dynLink.otherPlatformParameters?.fallbackUrl = URL(string: "https://apps.apple.com/ua/app/msa-my-sport-assistant/id1440506128?l=ru")
    dynLink.navigationInfoParameters = DynamicLinkNavigationInfoParameters()
    dynLink.navigationInfoParameters?.isForcedRedirectEnabled = true
    dynLink.shorten() { url, warnings, error in
          guard let url = url, error != nil else { return }
          shortUrl = url
          print("The short URL is: \(url)")
    }
    
    let firstActivityItem = "Найди меня в MSA"
    let secondActivityItem : NSURL = NSURL(string: "https://apps.apple.com/ua/app/msa-my-sport-assistant/id1440506128?l=ru")!
    let activityViewController : UIActivityViewController = UIActivityViewController(
      activityItems: [firstActivityItem, shortUrl], applicationActivities: nil)
    activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
    activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
    if #available(iOS 13.0, *) {
      activityViewController.activityItemsConfiguration = [
        UIActivity.ActivityType.message,.addToReadingList,.mail,.postToFacebook,.postToTwitter
        ] as? UIActivityItemsConfigurationReading
    } else {
      // Fallback on earlier versions
    }
    
    // Anything you want to exclude
    activityViewController.excludedActivityTypes = [
        UIActivity.ActivityType.postToWeibo,
        UIActivity.ActivityType.print,
        UIActivity.ActivityType.assignToContact,
        UIActivity.ActivityType.saveToCameraRoll,
        UIActivity.ActivityType.addToReadingList,
        UIActivity.ActivityType.postToFlickr,
        UIActivity.ActivityType.postToVimeo,
        UIActivity.ActivityType.postToTencentWeibo,
        UIActivity.ActivityType.postToFacebook
    ]
    
    if #available(iOS 13.0, *) {
      activityViewController.isModalInPresentation = true
    } else {
      // Fallback on earlier versions
    }
    DispatchQueue.main.async {
      self.present(activityViewController, animated: true, completion: nil)
    }
  }
  
}

extension HomeViewController: CommunityListViewProtocol {
  func updateTableView() {
    
  }
  
  func configureFilterView(dataSource: [String], selectedFilterIndex: Int) {
    
  }
  
  func setCityFilterTextField(name: String?) {
    
  }
  
  func showAlertFor(user: UserVO, isTrainerEnabled: Bool) {
    
  }
  
  func setErrorViewHidden(_ isHidden: Bool) {
  }
  
  func setLoaderVisible(_ visible: Bool) {
  }
  
  func stopLoadingViewState() {
  }
  
  func showGeneralAlert() {
  }
  
  func showRestoreAlert() {
  }
  
  func showIAP() {
  }
  
  func hideAccessDeniedView() {
  }
}

extension HomeViewController: SPPermissionsDataSource, SPPermissionsDelegate{
  func configure(_ cell: SPPermissionTableViewCell, for permission: SPPermission) -> SPPermissionTableViewCell {
    cell.permissionDescriptionLabel.text = "Получайте уведомления о новых сообщениях в чате и новостях"
    cell.permissionTitleLabel.text = "Уведомления"
    cell.button.allowTitle = "Разрешить"
    cell.button.allowedTitle = "Разрешены"
    cell.iconView.color = .darkCyanGreen
    cell.button.allowTitleColor = .darkCyanGreen
    cell.button.allowedBackgroundColor = .darkCyanGreen
    return cell
  }
  
  func didAllow(permission: SPPermission) {
    pushManager.registerForPushNotifications()
  }
  
  func didDenied(permission: SPPermission) {
  }
  
  func didHide(permissions ids: [Int]) {
    
  }
  
  func deniedData(for permission: SPPermission) -> SPPermissionDeniedAlertData? {
    permissionController!.dismiss(animated: true, completion: nil)
    return nil
  }
}
