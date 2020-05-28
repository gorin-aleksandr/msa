//
//  MainViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 2/18/18.
//  Copyright © 2018 easyapps.solutions. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import SDWebImage
import SPPermissions
import FBSDKLoginKit

protocol GalleryDataProtocol: class {
  func startLoading()
  func finishLoading()
  func galleryLoaded()
  func photoUploaded()
  func videoLoaded(url: String,and img: UIImage)
  func playVideo(url: String)
  func openImage(image: UIImage)
  func errorOccurred(err: String)
}

class MainViewController: BasicViewController, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
  
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
  @IBOutlet weak var levelView: UIView!
  
  @IBOutlet weak var profileView: UIView!
  @IBOutlet weak var buttViewHeight: NSLayoutConstraint!
  @IBOutlet weak var imagePreviewView: UIView!
  @IBOutlet weak var previewImage: UIImageView!
  @IBOutlet weak var goalImageView: UIImageView!
  @IBOutlet weak var viewWithButtons: UIView!
  
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!{didSet{activityIndicator.stopAnimating()}}
  @IBOutlet weak var galleryCollectionView: UICollectionView!
  @IBOutlet weak var galleryView: UIView! {didSet{galleryView.layer.cornerRadius = 10}}
  @IBOutlet weak var profileViewbg: UIView! {didSet{profileViewbg.layer.cornerRadius = 10}}
  @IBOutlet weak var userImage: UIView!
  @IBOutlet weak var coachIcon: UIImageView!
  @IBOutlet weak var trainerImage: UIImageView! {didSet{trainerImage.layer.cornerRadius = 16}}
  @IBOutlet weak var userName: UILabel!
  @IBOutlet weak var userCity: UILabel!
  @IBOutlet weak var userLevel: UILabel!
  @IBOutlet weak var dailyTraining: UILabel!
  @IBOutlet weak var dreamInsideView: UIView! {didSet {dreamInsideView.layer.cornerRadius = 9}}
  @IBOutlet weak var dreamView: UIView! { didSet{dreamView.layer.cornerRadius = 10 }}
  @IBOutlet weak var dreamViewButton: UIButton!
  @IBOutlet weak var editSkillsButton: UIButton!
  @IBOutlet weak var dailyTrainingLeading: NSLayoutConstraint!

  @IBOutlet weak var buttonsStackView: UIStackView!
  @IBOutlet weak var vkButton: UIButton!
  @IBOutlet weak var facebookButton: UIButton!
  @IBOutlet weak var instagramButton: UIButton!

  private let presenter = GalleryDataPresenter(gallery: GalleryDataManager())
  let p = ExersisesTypesPresenter(exercises: ExersisesDataManager())
  private let editProfilePresenter = EditProfilePresenter(profile: UserDataManager())
  let pushManager = PushNotificationManager() 
  var customImageViev = ProfileImageView()
  var myPicker = UIImagePickerController()
  
  var galleryUploadInProgress: Bool = false
  var pendingForUpload: [[UIImagePickerController.InfoKey : Any]] = []
  
  var trainer: UserVO?
  var comunityPresenter: CommunityListPresenterProtocol?
  var chatViewModel: ChatListViewModel = ChatListViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    downloadData()
    myPicker.delegate = self
    
    dreamViewButton.addTarget(self, action: #selector(presentInputStatus), for: .touchUpInside)
    editSkillsButton.isHidden = true
    if AuthModule.currUser.userType == .trainer {
      editSkillsButton.isHidden = false
      goalImageView.isHidden = true
      dailyTrainingLeading.constant = -27
    }
    fetchChats()
    setupPermissionAlert()
  }
  
  func fetchChats() {
    chatViewModel.getChatList(success: {
      self.setBadgeForChatCounter()
    }) {
    }
  }
  
  func setupPermissionAlert() {
    let defaults = UserDefaults.standard
    let mainPermission = defaults.bool(forKey: "allowedMainNotificationPermission")
    let controller = SPPermissions.dialog([.notification])
       controller.titleText = "Нужно разрешение"
       controller.headerText = ""
       controller.footerText = ""
       controller.dataSource = self
       controller.delegate = self
       let state = SPPermission.notification.isAuthorized
    if !state && !mainPermission {
       defaults.set(true, forKey: "allowedMainNotificationPermission")
          controller.present(on: self)
        }
  }
  
  func setBadgeForChatCounter() {
    var count = 0
    for chat in chatViewModel.chats {
      if chat.newMessages == true {
        count = count + 1
      }
    }
      super.tabBarController?.viewControllers![3].tabBarItem.badgeValue = count > 0 ? "\(count)" : nil
  }
  
  @objc func presentInputStatus() {
    let alert = UIAlertController(style: .actionSheet, title: "Укажите статус")
    let config: TextField.Config = { textField in
        textField.becomeFirstResponder()
        textField.textColor = .black
        if let dream = AuthModule.currUser.purpose, dream != "" {
           textField.text = dream
        }
        textField.placeholder = "Type something"
        //textField.left(image: image, color: .black)
        textField.leftViewPadding = 12
        textField.borderWidth = 1
        textField.cornerRadius = 8
        textField.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
        textField.backgroundColor = nil
        textField.keyboardAppearance = .default
        textField.keyboardType = .default
        textField.isSecureTextEntry = false
        textField.returnKeyType = .done
        textField.action { textField in
          if let purpose = textField.text, purpose != AuthModule.currUser.purpose {
            self.editProfilePresenter.setPurpose(purpose: purpose)
            self.dailyTraining.text = purpose
          }
        }
    }
    alert.addOneTextField(configuration: config)
    let saveAction = UIAlertAction(title: "Сохранить", style: .default) { (action) in
      if AuthModule.currUser.purpose == "" {
        self.dailyTraining.text = "Коротко о себе"
      }
    }
    alert.addAction(saveAction)
    alert.show()
  }
  
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
  
  private func downloadData() {
    downloadExercises()
    configureButtonsView()
    presenter.attachView(view: self)
    //        presenter.getGallery(context: context)
    presenter.getGallery(for: AuthModule.currUser.id)
    PushNotificationManager().updateFirestorePushTokenIfNeeded()
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
  
  override func viewWillAppear(_ animated: Bool) {
    downloadExercises()
    configureProfile()
    editProfilePresenter.getUser {
      UserSignInPresenter(auth: AuthModule()).saveUser(context: self.context, user: AuthModule.currUser)
      self.configureProfile()
    }
    navigationController?.setNavigationBarHidden(true, animated: true)
  }
  
  func configureButtonsView() {
    let w = CGFloat(self.view.frame.width - 32.0)
    buttViewHeight.constant = CGFloat(20.0 + (w*111.0/164.0))
  }
  
  func configureProfile() {
    editProfilePresenter.setupSubscriptionsFunctions()
    setShadow(outerView: profileView, shadowOpacity: 0.3)
    setShadow(outerView: viewWithButtons, shadowOpacity: 0.2)
    
    setProfileImage(image: nil, url: AuthModule.currUser.avatar)
    
    if let trainerId = AuthModule.currUser.trainerId {
      editProfilePresenter.getTrainerInfo(trainer: trainerId) { (trainer) in
        self.trainer = trainer
        self.coachIcon.isHidden = false
        self.trainerImage.isHidden = false
        self.trainerImage.sd_setImage(with: URL(string: trainer.avatar ?? ""), placeholderImage: UIImage(named: "avatar-placeholder"), options: .allowInvalidSSLCertificates, completed: nil)
      }
    } else {
      self.coachIcon.isHidden = true
      self.trainerImage.isHidden = true
    }
    if let name = AuthModule.currUser.firstName, let surname = AuthModule.currUser.lastName {
      userName.text = name + " " + surname
    }
    if let level = AuthModule.currUser.level {
      userLevel.text = level
      levelView.isHidden = false
      if level == "" {
        levelView.isHidden = true
      }
    } else {
      levelView.isHidden = true
    }
    if AuthModule.currUser.userType == .trainer {
      userLevel.text = "ТРЕНЕР"
      levelView.isHidden = false
    }
    if let city = AuthModule.currUser.city {
      userCity.text = city == "" ? "" : "г. " + city
    }
    if let dream = AuthModule.currUser.purpose, dream != "" {
      dailyTraining.text = dream
    } else {
      dailyTraining.text = "Коротко о себе"
    }
    
    vkButton.isHidden = true
    facebookButton.isHidden = true
    instagramButton.isHidden = true
    vkButton.frame = CGRect(x: vkButton.frame.origin.x, y: vkButton.frame.origin.y, width: 0, height: 0)
    vkButton.addTarget(self, action: #selector(showVkProfile), for: .touchUpInside)
    facebookButton.addTarget(self, action: #selector(showFacebookProfile), for: .touchUpInside)
    instagramButton.addTarget(self, action: #selector(showInstagramProfile), for: .touchUpInside)

    if let vkLink = AuthModule.currUser.vkLink {
      if vkLink != "" {
        vkButton.isHidden = false
      }
    }
    if let facebookLink = AuthModule.currUser.facebookLink {
      if facebookLink != "" {
        facebookButton.isHidden = false
      }
    }
    if let instagramLink = AuthModule.currUser.instagramLink {
      if instagramLink != "" {
        instagramButton.isHidden = false
      }
    }
  }
  
  @objc func showVkProfile() {
      if let vkLink = AuthModule.currUser.vkLink {
           let userName =  vkLink
          if let link = userName.detectedFirstLink {
            if let url = URL(string: link) {
                UIApplication.shared.open(url)
            }
          } else {
            let appURL = URL(string: "vk://vk.com/\(userName)")!
            let application = UIApplication.shared

            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                let webURL = URL(string: "https://vk.com/\(userName)")!
                application.open(webURL)
            }
          }
      }
    }
  
  @objc func showInstagramProfile() {
       if let instagramLink = AuthModule.currUser.instagramLink {
        
         let userName =  instagramLink // Your Instagram Username here
        
        if var link = userName.detectedFirstLink {
          if !link.contains("https://") {
              link = "https://\(link)"
          }
          if let url = URL(string: link) {
              UIApplication.shared.open(url)
          }
        } else {
          let appURL = URL(string: "instagram://user?username=\(userName)")!
          let application = UIApplication.shared

          if application.canOpenURL(appURL) {
              application.open(appURL)
          } else {
              let webURL = URL(string: "https://instagram.com/\(userName)")!
              application.open(webURL)
          }
        }
    }
  }
    
  @objc func showFacebookProfile() {
    if let facebookLink = AuthModule.currUser.facebookLink {
      let userName =  facebookLink.trimmingCharacters(in: .whitespaces)
      if let link = userName.detectedFirstLink {
        if let url = URL(string: link) {
          UIApplication.shared.open(url)
        }
      } else {
        let webURL = URL(string: "https://www.facebook.com/\(userName)")!
        UIApplication.shared.open(webURL)
      }
    }
  }
  
  @IBAction func goToTrainer(_ sender: Any) {
    if let trainer = trainer {
      let destinationVC = UIStoryboard(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
      
      comunityPresenter = CommunityListPresenter(view: self)
      if let presenter = comunityPresenter {
        navigationController?.setNavigationBarHidden(false, animated: true)
        destinationVC.profilePresenter = presenter.createProfilePresenter(user: trainer, for: destinationVC)
        navigationController?.pushViewController(destinationVC, animated: true)
      }
    }
  }
  
  func setProfileImage(image: UIImage?, url: String?) {
    for view in userImage.subviews {
      view.removeFromSuperview()
    }
    let indicator = UIActivityIndicatorView()
    indicator.center = userImage.center
    indicator.startAnimating()
    indicator.style = .white
    indicator.color = .blue
    userImage.addSubview(indicator)
    
    customImageViev.image = nil
    if let url = url {
      customImageViev.sd_setImage(with: URL(string: url), placeholderImage: nil, options: .allowInvalidSSLCertificates, completed: nil)
    } else {
      customImageViev.image = #imageLiteral(resourceName: "avatarPlaceholder")
    }
    if let image = image {
      customImageViev.image = image
    }
    
    AuthModule.userAvatar = customImageViev.image
    customImageViev.frame = CGRect(x: 0, y: 0, width: 99, height: 123)
    customImageViev.contentMode = .scaleAspectFill
    customImageViev.setNeedsLayout()
    userImage.addSubview(customImageViev)
    
    let button = UIButton(frame: CGRect(x: 0, y: 0, width: 99, height: 123))
    button.backgroundColor = .clear
    button.addTarget(self, action: #selector(openAvatar), for: .touchUpInside)
    self.userImage.addSubview(button)
  }
  
  @objc func openAvatar(sender: UIButton!) {
    if let avatar = AuthModule.currUser.avatar {
      UIView.animate(withDuration: 0.5) {
        self.imagePreviewView.alpha = 1
        self.tabBarController?.tabBar.isHidden = true
        if let imgUrl = URL(string: avatar) {
          self.previewImage.sd_setImage(with: imgUrl, placeholderImage: nil, options: .allowInvalidSSLCertificates, completed: nil)
        }
      }
    }
  }
  
  @IBAction func cameraButon(_ sender: Any) {
    self.openCamera()
  }
  @IBAction func addButton(_ sender: Any) {
    let alert = UIAlertController(title: "Загрузить:", message: nil, preferredStyle: .actionSheet)
    //        alert.addAction(UIAlertAction(title: "Камеры", style: .default, handler: { _ in
    //        }))
    alert.addAction(UIAlertAction(title: "Из галереи", style: .default, handler: { _ in
      self.openGallary()
    }))
    alert.addAction(UIAlertAction.init(title: "Отменить", style: .cancel, handler: { _ in
    }))
    self.present(alert, animated: true, completion: nil)
  }
  @IBAction func statisticButton(_ sender: Any) {
  }
  @IBAction func infoWeightHeightEct(_ sender: Any) {
  }
  @IBAction func foodButton(_ sender: Any) {
  }
  @IBAction func traningsButton(_ sender: Any) {
  }
  @IBAction func settingsButton(_ sender: Any) {
    print("Settings")
  }
  @IBAction func setPurpose(_ sender: Any) {
  }
  @IBAction func closePreview(_ sender: Any) {
    UIView.animate(withDuration: 0.5) {
      self.imagePreviewView.alpha = 0
      self.previewImage.image = nil
      self.tabBarController?.tabBar.isHidden = false
    }
  }
  @IBAction func deleteItem(_ sender: UIButton) {
    let index = sender.tag
    let alert = UIAlertController(title: "Удаление из галереи", message: nil, preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "Удалить", style: .default, handler: { _ in
      self.presenter.deleteGaleryItem(index: index)
    }))
    alert.addAction(UIAlertAction.init(title: "Отменить", style: .cancel, handler: { _ in
    }))
    self.present(alert, animated: true, completion: nil)
  }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return presenter.getItems().count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = galleryCollectionView.dequeueReusableCell(withReuseIdentifier: "galleryPhotoCell", for: indexPath) as! GalleryCollectionViewCell
    let index = indexPath.row
    cell.c.tag = index
    cell.activityIndicator.startAnimating()
    if let url = presenter.getItems()[index].imageUrl {
      cell.photoImageView.sd_setImage(with: URL(string: url)!, placeholderImage: nil, options: .allowInvalidSSLCertificates, completed: { (img, err, cashe, url) in
        cell.activityIndicator.stopAnimating()
      })
    }
    if let video = presenter.getItems()[index].video_url, video != "" {
      cell.video.alpha = 1
    } else {
      cell.video.alpha = 0
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: galleryCollectionView.frame.width/3-10, height: (galleryCollectionView.frame.width/3-3)*140/110);
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let index = indexPath.row
    if let url = presenter.getItems()[index].video_url  {
      playVideo(url: url)
    } else {
      if let url = presenter.getItems()[index].imageUrl {
        UIView.animate(withDuration: 0.5) {
          self.imagePreviewView.alpha = 1
          self.tabBarController?.tabBar.isHidden = true
          if let imgUrl = URL(string: url) {
            self.previewImage.sd_setImage(with: imgUrl, placeholderImage: nil, options: .allowInvalidSSLCertificates, completed: nil)
          }
        }
      }
      
    }
  }
  
  
  func openGallary() {
    myPicker.allowsEditing = false
    myPicker.sourceType = UIImagePickerController.SourceType.photoLibrary
    myPicker.mediaTypes = ["public.image", "public.movie"]
    present(myPicker, animated: true, completion: nil)
  }
  
  func openCamera() {
    myPicker.allowsEditing = false
    myPicker.sourceType = UIImagePickerController.SourceType.camera
    myPicker.mediaTypes = ["public.image", "public.movie"]
    present(myPicker, animated: true, completion: nil)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
  
//  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         if galleryUploadInProgress {
        self.pendingForUpload.append(info)
      } else {
        self.uploadInfo(info: info)
      }
      dismiss(animated: true, completion: nil)
  }
  
  private func uploadInfo(info: [UIImagePickerController.InfoKey : Any]) {

            if let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                self.galleryUploadInProgress = true
                presenter.uploadPhoto(image: chosenImage)
            } else if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                do {
                    let asset = AVURLAsset(url: videoURL, options: nil)
                    let imgGenerator = AVAssetImageGenerator(asset: asset)
                    imgGenerator.appliesPreferredTrackTransform = true
                    let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                    let thumbnail = UIImage(cgImage: cgImage)
    
                    self.galleryUploadInProgress = true
    
                    presenter.uploadVideo(videoURL.absoluteString, thumbnail)
                    presenter.setCurrentVideoPath(path: videoURL.absoluteString)
                } catch let error {
                    print("*** Error generating thumbnail: \(error.localizedDescription)")
                }
            }
  }
  
}

extension MainViewController: GalleryDataProtocol {
  func videoLoaded(url: String, and img: UIImage) {
    presenter.setCurrentVideoUrl(url: url)
    presenter.uploadPhoto(image: img)
  }
  
  func errorOccurred(err: String) { }
  
  func photoUploaded() {
    presenter.addItem(item: presenter.getCurrentItem())
    if pendingForUpload.isEmpty {
      self.galleryUploadInProgress = false
    } else {
      guard let itemForUpload = pendingForUpload.first else {return}
      pendingForUpload.remove(at: 0)
      self.uploadInfo(info: itemForUpload)
    }
  }
  
  func startLoading() {
    DispatchQueue.main.async {
      self.activityIndicator.startAnimating()
    }
  }
  
  func finishLoading() {
    DispatchQueue.main.async {
      self.activityIndicator.stopAnimating()
    }
  }
  
  func galleryLoaded() {
    DispatchQueue.main.async {
      self.presenter.updateGalleryItems(items: self.presenter.getItems())
      self.presenter.deleteGalleryBlock(context: self.context)
      self.presenter.saveGallery(context: self.context)
      self.galleryCollectionView.reloadData()
      self.presenter.clear()
      self.activityIndicator.stopAnimating()
      self.presenter.clear()
    }
  }
  
  func playVideo(url: String) {
    if let VideoURL = URL(string: url) {
      let player = AVPlayer(url: VideoURL)
      let playerViewController = AVPlayerViewController()
      playerViewController.player = player
      self.present(playerViewController, animated: true) {
        playerViewController.player!.play()
      }
    }
  }
  
  func openImage(image: UIImage) {
    
  }
  
}

extension MainViewController: CommunityListViewProtocol {
  func updateTableView() {}
  func configureFilterView(dataSource: [String], selectedFilterIndex: Int) {}
  func setCityFilterTextField(name: String?) {}
  func showAlertFor(user: UserVO, isTrainerEnabled: Bool) {}
  func setErrorViewHidden(_ isHidden: Bool) {}
  func setLoaderVisible(_ visible: Bool) { }
  func stopLoadingViewState() {}
  func showGeneralAlert() {}
  func showRestoreAlert() {}
  func showIAP() {}
  func hideAccessDeniedView() {}
}

extension MainViewController: SPPermissionsDataSource, SPPermissionsDelegate{
  func configure(_ cell: SPPermissionTableViewCell, for permission: SPPermission) -> SPPermissionTableViewCell {
    cell.permissionDescriptionLabel.text = "Получайте уведомления о новых сообщениях в чате и новостях"
    cell.permissionTitleLabel.text = "Уведомления"
    cell.button.setTitle("Включить", for: .normal)
    return cell
  }
  
  func didAllow(permission: SPPermission) {
    pushManager.registerForPushNotifications()
  }
  
  func didDenied(permission: SPPermission) {
  }
  
  func didHide(permissions ids: [Int]) {
    
  }
  
//  func deniedData(for permission: SPPermission) -> SPPermissionDeniedAlertData? {
////    if permission == .notification {
////        let data = SPPermissionDeniedAlertData()
////        data.alertOpenSettingsDeniedPermissionTitle = "Нет разрешения"
////        data.alertOpenSettingsDeniedPermissionDescription = "Пожалуйста, перейдите в настройки и разрешите уведомления."
////        data.alertOpenSettingsDeniedPermissionButtonTitle = "Настройки"
////        data.alertOpenSettingsDeniedPermissionCancelTitle = "Отмена"
////        return data
////    } else {
//        // If returned nil, alert will not show.
//        return nil
//    //}
//  }
}
