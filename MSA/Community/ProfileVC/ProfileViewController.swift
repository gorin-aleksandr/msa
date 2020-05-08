//
//  ProfileViewController.swift
//  MSA
//
//  Created by Andrey Krit on 8/29/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import SDWebImage
import SVProgressHUD
import MessageUI
import FZAccordionTableView
import Firebase

protocol ProfileViewProtocol: class {
    func updateProfile(with user: UserVO)
    func configureViewBasedOnState(state: PersonState)
    func reloadIconsCollectionView()
    func showDeleteAlert(for user: UserVO)
    func dismiss()
    func showAddAlertFor(user: UserVO, isTrainerEnabled: Bool)
    func mailViewController(email: String, subject: String)
    func setMailButton(hidden: Bool)
}

class ProfileViewController: BasicViewController, UIPopoverControllerDelegate, UINavigationControllerDelegate, ProfileViewProtocol, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var buttViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imagePreviewView: UIView!
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var sendEmailButton: UIButton!
    
    
    @IBOutlet weak var viewWithButtons: UIView!
    @IBOutlet weak var scrollView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!{didSet{activityIndicator.stopAnimating()}}
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    @IBOutlet weak var galleryView: UIView! {didSet{galleryView.layer.cornerRadius = 12}}
    @IBOutlet weak var profileViewbg: UIView! {didSet{profileViewbg.layer.cornerRadius = 10}}
    @IBOutlet weak var userImage: UIView!
    
    @IBOutlet weak var relatedCollectionView: UICollectionView!
    @IBOutlet weak var relatedWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userLevel: UILabel!
    @IBOutlet weak var levelBg: UIImageView!
    @IBOutlet weak var dailyTraining: UILabel!
    @IBOutlet weak var tableView: FZAccordionTableView! {didSet{tableView.layer.cornerRadius = 10}}

    @IBOutlet weak var dreamInsideView: UIView! {
        didSet {dreamInsideView.layer.cornerRadius = 0
            dreamInsideView.layer.borderColor = UIColor.white.withAlphaComponent(1.0).cgColor
            dreamInsideView.layer.borderWidth = 0
        }
        
    }
    @IBOutlet weak var buttonsStackView: UIStackView!
 
    @IBOutlet weak var vkButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var instagramButton: UIButton!

    var profilePresenter: ProfilePresenterProtocol!
    var isHiddenSendMessageButton = true

    var customImageViev = ProfileImageView()
    var myPicker = UIImagePickerController()
    
    var userRef = Database.database().reference().child("Users")

    var selectedSkills: [String] = []
    var selectedAchievements:[(id: String, name: String, rank: String, achieve: String, year: String)] = []
    var selectedEducation:[(id: String, name: String, yearFrom: String, yearTo: String)] = []
    var selectedCertificates:[(id: String, name: String)] = []
  
    override func viewDidLoad() {
        super.viewDidLoad()
        relatedCollectionView.dataSource = self
        relatedCollectionView.delegate = self
        relatedWidthConstraint.constant = CGFloat(((profilePresenter.iconsDataSource.count > 5 ? 5 : profilePresenter.iconsDataSource.count) - 1) * 12 + 32)
        configureButtonsView()
        profilePresenter.start()
        
      tableView.register(UINib(nibName: "TrainerSkillsHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "TrainerSkillsHeaderView")
        tableView.register(UINib(nibName: "ExerciseTableViewCell", bundle: nil), forCellReuseIdentifier: "ExerciseTableViewCell")
        tableView.register(UINib(nibName: "AchievmentCell", bundle: nil), forCellReuseIdentifier: "AchievmentCell")
        tableView.register(UINib(nibName: "CreateExerciseTableViewCell", bundle: nil), forCellReuseIdentifier: "CreateExerciseTableViewCell")

        tableView.register(UINib(nibName: "EducationCell", bundle: nil), forCellReuseIdentifier: "EducationCell")
        tableView.register(UINib(nibName: "SkyFloatingView", bundle: nil), forHeaderFooterViewReuseIdentifier: "SkyFloatingView")
      
      tableView.tableFooterView = UIView()
      let group = DispatchGroup()
      group.enter()
      fetchSpecialization(completion: { sucess in
        group.leave()
      })
      group.enter()
      fetchAchievements(completion: { sucess in
        group.leave()
      })
      group.enter()
      fetchEducation(completion: { sucess in
        group.leave()
      })
      group.enter()
      fetchCertificate(completion: { sucess in
        group.leave()
      })
      group.notify(queue: .main) {
        self.tableView.reloadData()
      }
      
      sendEmailButton.isHidden = isHiddenSendMessageButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureProfileView()
        setNavigationBarTransparent()
        self.tabBarController?.tabBar.isHidden = false
        self.profilePresenter.getSelectedUsersChat()

        //navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func setNavigationBarTransparent() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.view.backgroundColor = .clear
    }
    
    
    func configureButtonsView() {
        let w = CGFloat(self.view.frame.width - 32.0)
        buttViewHeight.constant = CGFloat(100 + (w*111.0/164.0))
    }
    
    func setMailButton(hidden: Bool) {
        sendEmailButton.isHidden = hidden
    }
    
    func setShadow(outerView: UIView, shadowOpacity: Float) {
        outerView.clipsToBounds = false
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOpacity = shadowOpacity
        outerView.layer.shadowOffset = CGSize.zero
        outerView.layer.shadowRadius = 10
        outerView.layer.shadowPath = UIBezierPath(roundedRect: outerView.bounds, cornerRadius: 10).cgPath
    }
    
    func configureProfileView() {
        setShadow(outerView: profileView, shadowOpacity: 0.3)
        setShadow(outerView: viewWithButtons, shadowOpacity: 0.2)
        vkButton.isHidden = true
        vkButton.frame = CGRect(x: vkButton.frame.origin.x, y: vkButton.frame.origin.y, width: 0, height: 0)
        facebookButton.isHidden = true
        instagramButton.isHidden = true
        vkButton.addTarget(self, action: #selector(showVkProfile), for: .touchUpInside)
        facebookButton.addTarget(self, action: #selector(showFacebookProfile), for: .touchUpInside)
        instagramButton.addTarget(self, action: #selector(showInstagramProfile), for: .touchUpInside)

        if let vkLink = profilePresenter.user.vkLink {
          if vkLink != "" {
            vkButton.isHidden = false
          }
        }
        if let facebookLink = profilePresenter.user.facebookLink {
          if facebookLink != "" {
            facebookButton.isHidden = false
          }
        }
        if let instagramLink = profilePresenter.user.instagramLink {
          if instagramLink != "" {
            instagramButton.isHidden = false
          }
        }
    }
    
    func configureViewBasedOnState(state: PersonState) {
        SVProgressHUD.dismiss()
      //  if state != .trainersSportsman {
//            containerViewHeightConstraint.constant -= viewWithButtons.frame.height
//            buttViewHeight.constant = 0
//            buttonsStackView.isHidden = true
       // }
        if profilePresenter.user.userType == .trainer {
          containerViewHeightConstraint.constant = 1100
        }

        if state == .all {
            navigationItem.rightBarButtonItem?.tintColor = .lightBlue
            navigationItem.rightBarButtonItem?.image = #imageLiteral(resourceName: "plus_blue")
        } else {
            navigationItem.rightBarButtonItem?.tintColor = .red
            navigationItem.rightBarButtonItem?.image = #imageLiteral(resourceName: "delete_red")
        }
        if profilePresenter.user.userType != .trainer {
              containerViewHeightConstraint.constant -= viewWithButtons.frame.height
              buttViewHeight.constant = 0
        } else {
          //containerViewHeightConstraint.constant += viewWithButtons.frame.height
        }
        navigationItem.leftBarButtonItem?.image = UIImage(named: "back_")
        navigationItem.leftBarButtonItem?.title = "Назад"
        sendEmailButton.isHidden = isHiddenSendMessageButton
    }
    
    func updateProfile(with user: UserVO) {
        if let name = user.firstName, let surname = user.lastName {
            userName.text = name + " " + surname
            cityLabel.text = user.city
        }
        if let level = user.level {
            userLevel.text = level
            userLevel.isHidden = false
            levelBg.isHidden = false
            if level == "" {
                userLevel.isHidden = true
                levelBg.isHidden = true
            }
        } else {
            userLevel.isHidden = true
            levelBg.isHidden = true
        }
      if user.userType == .trainer {
        userLevel.isHidden = false
        levelBg.isHidden = false
        userLevel.text = "ТРЕНЕР"
      }
        if let dream = user.purpose {
            dailyTraining.text = dream
        }
        setProfileImage(image: nil, url: user.avatar)
        if  user.userType == .trainer {

        }
//        if let trainer = user.trainerId, trainer == AuthModule.currUser.id {
//            configureButtonsView()
//        }
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
        customImageViev.frame = CGRect(x: 0, y: 0, width: 96, height: 120)
        customImageViev.contentMode = .scaleAspectFill
        customImageViev.setNeedsLayout()
        userImage.addSubview(customImageViev)
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 90))
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(openAvatar), for: .touchUpInside)
        self.userImage.addSubview(button)
    }
    
    @objc func openAvatar(sender: UIButton!) {
        if let avatar = profilePresenter.avatar {
            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.imagePreviewView.alpha = 1
                self?.tabBarController?.tabBar.isHidden = true
                self?.navigationController?.navigationBar.isHidden = true
                if let imgUrl = URL(string: avatar) {
                    self?.previewImage.sd_setImage(with: imgUrl, placeholderImage: nil, options: .allowInvalidSSLCertificates, completed: nil)
                }
            }
        }
    }
    
    func showCantSendEmailAlert() {
        let alert = UIAlertController(title: "Отказ", message: "Для отправки сообщения настройте почтовый клиент на Вашем устройстве", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ок", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    func showDeleteAlert(for user: UserVO) {
        let alert = UIAlertController(title: nil, message: profilePresenter.state == .userTrainer ? "Вы действительно хотите удалить тренера?" : "Вы дейсвительно хотите удалить из запросов/друзей/спортсменов?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            SVProgressHUD.show()
            self?.profilePresenter.deleteAction(for: user)
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func showAddAlertFor(user: UserVO, isTrainerEnabled: Bool) {
        let alert = UIAlertController(title: "Добавить в свое сообщество \(user.getFullName())", message: "Вы можете перейти на страницу тренера/друга на вкладке “Сообщество”", preferredStyle: .alert)
        let cancelActionButton = UIAlertAction(title: "Отмена", style: .cancel) { action -> Void in
            print("Cancel")
        }
        let addFriendAction = UIAlertAction(title: "Добавить в список друзей", style: .default, handler: { [weak self] action -> Void in
            SVProgressHUD.show()
            self?.profilePresenter.addToFriends(user: user)
        })
        alert.addAction(cancelActionButton)
        alert.addAction(addFriendAction)
        if isTrainerEnabled {
            let addTrainerAction = UIAlertAction(title: "Добавить в тренеры", style: .default, handler: { [weak self] _ in
                SVProgressHUD.show()
                self?.profilePresenter.addAsTrainer(user: user)
            })
            alert.addAction(addTrainerAction)
        }
        self.present(alert, animated: true)
    }
  
  @objc func showVkProfile() {
      if let vkLink = profilePresenter.user.vkLink {
          
           let userName =  vkLink // Your Instagram Username here
          
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
                // if Instagram app is not installed, open URL inside Safari
                let webURL = URL(string: "https://vk.com/\(userName)")!
                application.open(webURL)
            }
          }
      }
    }
  
  @objc func showInstagramProfile() {
       if let instagramLink = profilePresenter.user.instagramLink {
        
         let userName =  instagramLink // Your Instagram Username here
        
        if let link = userName.detectedFirstLink {
          if let url = URL(string: link) {
              UIApplication.shared.open(url)
          }
        } else {
          let appURL = URL(string: "instagram://user?username=\(userName)")!
          let application = UIApplication.shared

          if application.canOpenURL(appURL) {
              application.open(appURL)
          } else {
              // if Instagram app is not installed, open URL inside Safari
              let webURL = URL(string: "https://instagram.com/\(userName)")!
              application.open(webURL)
          }
        }
    }
  }
    
  @objc func showFacebookProfile() {
            if let facebookLink = profilePresenter.user.facebookLink {
             
              let userName =  facebookLink // Your Instagram Username here
             
             if let link = userName.detectedFirstLink {
               if let url = URL(string: link) {
                   UIApplication.shared.open(url)
               }
             } else {
//               let appURL = URL(string: "fb://profile/\(userName)")!
//               let application = UIApplication.shared
//
//               if application.canOpenURL(appURL) {
//                   application.open(appURL)
//               } else {
                   // if Instagram app is not installed, open URL inside Safari
                   let webURL = URL(string: "https://www.facebook.com/\(userName)")!
                   UIApplication.shared.open(webURL)
               
             //}
         }
    }
  }
    
    func dismiss() {
        SVProgressHUD.dismiss()
        self.navigationController?.popViewController(animated: true)
    }
    
    func reloadIconsCollectionView() {
        // MARK: use for future refactoring
        //relatedCollectionView.reloadData()
    }
    
    func mailViewController(email: String, subject: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([email])
            mail.setSubject(subject)
            present(mail, animated: true)
        } else {
            showCantSendEmailAlert()
        }
        
    }
    
    @IBAction func rightBarButtonTapped(_ sender: Any) {
        profilePresenter.addOrRemoveUserAction()
    }
    
    
    @IBAction func statisticButton(_ sender: Any) {
    }
    @IBAction func infoWeightHeightEct(_ sender: Any) {
    }
    @IBAction func foodButton(_ sender: Any) {
    }
    @IBAction func traningsButton(_ sender: Any) {
        let destinationVC = UIStoryboard(name: "Trannings", bundle: nil).instantiateViewController(withIdentifier: "MyTranningsViewController") as! MyTranningsViewController
        destinationVC.manager.trainingType = .notMine(userId: profilePresenter.userId)
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss()
    }
    @IBAction func closePreview(_ sender: Any) {
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.imagePreviewView.alpha = 0
            self?.previewImage.image = nil
            self?.tabBarController?.tabBar.isHidden = false
        }
        navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func sendEmailButtonTapped(_ sender: Any) {
        //profilePresenter.prepareMessage()// отправить уведомление
      let chatViewController = chatStoryboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController
      chatViewController?.viewModel = ChatViewModel(chatId: profilePresenter.chatId!, chatUserId: profilePresenter.user.id!, chatUserName: "\(profilePresenter.user.firstName!) \(profilePresenter.user.lastName!)")
      chatViewController?.viewModel!.chatUser = profilePresenter.user
      chatViewController?.viewModel?.chatUserAvatar = profilePresenter.user.avatar
      chatViewController?.senderDisplayName = ""
      let nc = UINavigationController(rootViewController: chatViewController!)
      nc.modalPresentationStyle = .fullScreen
      self.present(nc, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == relatedCollectionView {
            return profilePresenter.iconsDataSource.count > 5 ? 5 : profilePresenter.iconsDataSource.count
        }
        return profilePresenter.gallery.count > 5 ? 5 : profilePresenter.gallery.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == relatedCollectionView {
            let cell = relatedCollectionView.dequeueReusableCell(withReuseIdentifier: "RelatedUserCell", for: indexPath) as! RelatedUserCollectionViewCell
            let imageUrl = profilePresenter.iconsDataSource[indexPath.row]
            if let url = URL(string: imageUrl) {
                cell.photoImageView.sd_setImage(with: url, completed: nil)
            }
            cell.typeImageView.image = profilePresenter.userType == .trainer ?  #imageLiteral(resourceName: "athlet-icon") : #imageLiteral(resourceName: "coach-icon")
            return cell
        }
        
        let cell = galleryCollectionView.dequeueReusableCell(withReuseIdentifier: "galleryPhotoCell", for: indexPath) as! GalleryCollectionViewCell
        let index = indexPath.row
        cell.c.isHidden = true
        cell.activityIndicator.startAnimating()
        if let url = profilePresenter.gallery[index].imageUrl {
            cell.photoImageView.sd_setImage(with: URL(string: url)!, placeholderImage: nil, options: .allowInvalidSSLCertificates, completed: { (img, err, cashe, url) in
                cell.activityIndicator.stopAnimating()
            })
        }
        if let video = profilePresenter.gallery[index].video_url, video != "" {
            cell.video.alpha = 1
        } else {
            cell.video.alpha = 0
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == relatedCollectionView {
            return CGSize(width: 32, height: 32)
        }
        return CGSize(width: galleryCollectionView.frame.width/3-10, height: (galleryCollectionView.frame.width/3-3)*140/110);
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == relatedCollectionView { return }
        
        let index = indexPath.row
        if let url = profilePresenter.gallery[index].video_url  {
            playVideo(url: url)
        } else {
            if let url = profilePresenter.gallery[index].imageUrl {
                self.tabBarController?.tabBar.isHidden = true
                self.navigationController?.navigationBar.isHidden = true
                UIView.animate(withDuration: 0.5) {
                    self.imagePreviewView.alpha = 1
                    if let imgUrl = URL(string: url) {
                        self.previewImage.sd_setImage(with: imgUrl, placeholderImage: nil, options: .allowInvalidSSLCertificates, completed: nil)
                    }
                }
            }
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
        UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return -18
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
}

//extension ProfileViewController: GalleryDataProtocol {
//
//    func videoLoaded(url: String, and img: UIImage) {
////        presenter.setCurrentVideoUrl(url: url)
////        presenter.uploadPhoto(image: img)
//    }
//
//    func errorOccurred(err: String) {
//
//    }
//
//    func photoUploaded() {
//       // presenter.addItem(item: presenter.getCurrentItem())
//    }
//
//    func startLoading() {
//        DispatchQueue.main.async {
//            self.activityIndicator.startAnimating()
//        }
//    }
//
//    func finishLoading() {
//        DispatchQueue.main.async {
//            self.activityIndicator.stopAnimating()
//        }
//    }
//
//    func galleryLoaded() {
//        DispatchQueue.main.async {
////            self.galleryPresenter.updateGalleryItems(items: self.presenter.getItems())
////            self.galleryPresenter.deleteGalleryBlock(context: self.context)
////            self.galleryPresenter.saveGallery(context: self.context)
////            self.galleryCollectionView.reloadData()
////            self.galleryPresenter.clear()
////            self.activityIndicator.stopAnimating()
////            self.galleryPresenter.clear()
//        }
//    }
//
//    func openImage(image: UIImage) {
//
//    }
//
//}
extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
    guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "TrainerSkillsHeaderView") as? TrainerSkillsHeaderView else {return nil}
    headerView.tag = section
    headerView.titleLabel.font = UIFont(name: "Rubik-Regular", size: 17)
    headerView.textLabel?.textColor = lightBlue_
    switch section {
      case 0:
        headerView.titleLabel.text = "Специализация"
        headerView.logoImageView.image = UIImage(named: "noun_personaltrainer")
      case 1:
        headerView.titleLabel.text = "Спортивные достижения"
        headerView.logoImageView.image = UIImage(named: "noun_champion")
      case 2:
        headerView.titleLabel.text = "Образование"
        headerView.logoImageView.image = UIImage(named: "noun_education")
      case 3:
        headerView.titleLabel.text = "Сертификация"
        headerView.logoImageView.image = UIImage(named: "noun_strong")
      default:
        headerView.titleLabel.text = "Сертификация"
      
    }
      return headerView
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == 4 || section == 5 || section == 6 {
      return 50
    }
    return 85
    
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    switch indexPath.section {
      case 0:
        return UITableView.automaticDimension
      case 1:
        if indexPath.row != selectedAchievements.count {
          return 80
        } else {
          return 60
      }
      case 2:
        if indexPath.row != selectedEducation.count {
          return 70
        } else {
          return 60
      }
      case 3:
        if indexPath.row != selectedCertificates.count {
          return 50
        } else {
          return 60
      }
      default: return UITableView.automaticDimension
    }
    
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    if indexPath.section == 0 {
        return tagCell(indexPath: indexPath)
    }
    
    if indexPath.section == 1 {
      if selectedAchievements.count > 0 && indexPath.row != selectedAchievements.count {
        return achievementCell(indexPath: indexPath)
      } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateExerciseTableViewCell", for:  indexPath) as! CreateExerciseTableViewCell
        cell.icon.image = nil
        cell.textLabelMess.text = "Добавить свой вариант"
        return cell
      }
    }
    
    if indexPath.section == 2 {
      if selectedEducation.count > 0 && indexPath.row != selectedEducation.count {
        return educationCell(indexPath: indexPath)
      } else {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateExerciseTableViewCell", for:  indexPath) as! CreateExerciseTableViewCell
        cell.icon.image = nil
        cell.textLabelMess.text = "Добавить свой вариант"
        return cell
      }
    }
    
    if indexPath.section == 3 {
        if selectedCertificates.count > 0 && indexPath.row != selectedCertificates.count {
          return certificationCell(indexPath: indexPath)
        } else {
          let cell = tableView.dequeueReusableCell(withIdentifier: "CreateExerciseTableViewCell", for:  indexPath) as! CreateExerciseTableViewCell
          cell.icon.image = nil
          cell.textLabelMess.text = "Добавить свой вариант"
          return cell
        }
      }
    let cell = tableView.dequeueReusableCell(withIdentifier: "CreateExerciseTableViewCell", for:  indexPath) as! CreateExerciseTableViewCell
    cell.icon.image = nil
    cell.textLabelMess.text = "Добавить свой вариант"
    return cell
  }
  
  func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
    return false
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
      case 0:
        return selectedSkills.count
      case 1:
        return selectedAchievements.count
      case 2:
        return selectedEducation.count
      case 3:
        return selectedCertificates.count
      default:
        return 1
    }
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 4
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

  }
  
  func tagCell(indexPath: IndexPath) -> ProductCategoriesCell{
    let cell: ProductCategoriesCell! = tableView.dequeueReusableCell(withIdentifier: ProductCategoriesCell.identifier) as? ProductCategoriesCell
    cell.tagList.removeAllTags()
    let tag = selectedSkills[indexPath.row]
    cell.tagList.addTag(tag)
    cell.tagList.tagViews[0].isSelected = true
    return cell
  }
  
  func achievementCell(indexPath: IndexPath) -> AchievmentCell{
    let cell: AchievmentCell! = tableView.dequeueReusableCell(withIdentifier: AchievmentCell.identifier) as? AchievmentCell
    let achieve = selectedAchievements[indexPath.row]
    cell.nameLabel.text = achieve.name
    cell.rankLabel.text = achieve.rank
    cell.yearLabel.text = achieve.year
    cell.achieveLabel.text = achieve.achieve != "" ? "\(achieve.achieve) \nместо" : ""
    cell.removeButton.isHidden = true
    return cell
  }
  
  func educationCell(indexPath: IndexPath) -> EducationCell{
    let cell: EducationCell! = tableView.dequeueReusableCell(withIdentifier: EducationCell.identifier) as? EducationCell
    let education = selectedEducation[indexPath.row]
    cell.nameLabel.text = education.name
    cell.yearFromLabel.text = education.yearFrom
    cell.yearToLabel.text = education.yearTo
    cell.removeButton.isHidden = true
    return cell
  }
  
  func certificationCell(indexPath: IndexPath) -> EducationCell{
    let cell: EducationCell! = tableView.dequeueReusableCell(withIdentifier: EducationCell.identifier) as? EducationCell
    let certificate = selectedCertificates[indexPath.row]
    cell.nameLabel.text = certificate.name
    cell.yearToLabel.isHidden = true
    cell.yearFromLabel.isHidden = true
    cell.removeButton.isHidden = true
    return cell
  }
}

extension ProfileViewController: FZAccordionTableViewDelegate {
  func tableView(_ tableView: FZAccordionTableView, willOpenSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
    guard let sectionHeader = header as? TrainerSkillsHeaderView else { return }
    sectionHeader.headerState.toggle()
    
  }
  func tableView(_ tableView: FZAccordionTableView, willCloseSection section: Int, withHeader header: UITableViewHeaderFooterView?) {
    guard let sectionHeader = header as? TrainerSkillsHeaderView else { return }
    sectionHeader.headerState.toggle()
  }
}

extension ProfileViewController {
  
  func fetchSpecialization(completion: @escaping (Bool) -> Void) {
    if let key = profilePresenter.user.id {
      userRef.child(key).child("coachDetail").child("specialization").observeSingleEvent(of: .value, with: { snapshot in
        for child in snapshot.children {
          let snap = child as! DataSnapshot
          let specialization = snap.value as! String
          self.selectedSkills.append(specialization)
        }
        completion(true)
        print(self.selectedSkills)
      })
    }
  }
  
 
  
  func fetchAchievements(completion: @escaping (Bool) -> Void) {
    if let key = profilePresenter.user.id {
      userRef.child(key).child("coachDetail").child("achievements").observeSingleEvent(of: .value, with: { snapshot in
        if let dict = snapshot.value as? Dictionary<String, Any> {
          print(dict)
          for key in dict.keys {
            let item = dict[key] as? Dictionary<String, Any>
            self.selectedAchievements.append((id: key, name: item?["name"] as! String, rank: item?["rank"] as! String, achieve: item?["achievement"] as! String, year: item?["year"] as! String))
          }
          completion(true)
        }
      })
    }
  }
  

  
  func fetchEducation(completion: @escaping (Bool) -> Void) {
    if let key = profilePresenter.user.id {
      userRef.child(key).child("coachDetail").child("education").observeSingleEvent(of: .value, with: { snapshot in
        if let dict = snapshot.value as? Dictionary<String, Any> {
          print(dict)
          for key in dict.keys {
            let item = dict[key] as? Dictionary<String, Any>
            self.selectedEducation.append((id: key, name: item?["name"] as! String, yearFrom: item?["yearFrom"] as! String, yearTo: item?["yearTo"] as! String))
          }
          completion(true)
        }
      })
    }
  }
  
  func fetchCertificate(completion: @escaping (Bool) -> Void) {
    if let key = profilePresenter.user.id {
      userRef.child(key).child("coachDetail").child("certificates").observeSingleEvent(of: .value, with: { snapshot in
        if let dict = snapshot.value as? Dictionary<String, Any> {
          print(dict)
          for key in dict.keys {
            let item = dict[key] as? Dictionary<String, Any>
            self.selectedCertificates.append((id: key, name: item?["name"] as! String))
          }
          completion(true)
        }
      })
    }
  }
}
