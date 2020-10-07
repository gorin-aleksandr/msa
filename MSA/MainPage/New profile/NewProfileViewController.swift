//
//  NewProfileViewController.swift
//  MSA
//
//  Created by Nik on 26.08.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit
import TagListView
import BetterSegmentedControl
import PhotoSlider

class NewProfileViewController: UIViewController {

  @IBOutlet weak var photoImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var cityLabel: UILabel!
  @IBOutlet weak var tagList: TagListView!
  @IBOutlet weak var segmentedControl: BetterSegmentedControl!
  @IBOutlet weak var photoView: UIView!
  @IBOutlet weak var informationView: UIView!
  @IBOutlet weak var sportsmanView: UIView!
  @IBOutlet weak var socialsStackView: UIStackView!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var instaButton: UIButton!
  @IBOutlet weak var facebookButton: UIButton!
  @IBOutlet weak var vkButton: UIButton!
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var directButton: UIButton!
  
  var galleryViewController: ProfileGalleryViewController?
  var achievementsViewController: UserAchievementsViewController?
  var userSportsmansViewController: UsersSportsmansViewController?

  var viewModel: ProfileViewModel? {
    didSet {
      self.viewModel!.reloadSkillsTable = {
        self.fetchSkills()
      }
    }
  }
  
  override func viewDidLoad() {
        super.viewDidLoad()
      self.navigationController?.navigationBar.isHidden = true
      setupUI()
  }

  func loadUserFromDynamicLink() {
    viewModel!.getUserById { (success) in
      if success {
        self.setupProfile()
        self.fetchSkills()
        self.updateControllersViewModel()
        self.viewModel!.getSelectedUsersChat { (value) in
          if self.viewModel?.selectedUser != nil {
            self.directButton.isHidden = false
          }
        }
      }
    }
  }
  
  func updateControllersViewModel() {
    achievementsViewController!.viewModel.selectedUser = self.viewModel?.selectedUser
    achievementsViewController?.viewModel.reloadAchievementsTable?()
    userSportsmansViewController!.viewModel?.selectedUser = self.viewModel?.selectedUser
    userSportsmansViewController!.fetchSportsmans()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    self.navigationController?.navigationBar.isHidden = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    directButton.isHidden = true
    if viewModel?.selectedUserId == "" {
     setupProfile()
     fetchSkills()
      viewModel!.getSelectedUsersChat { (value) in
        if self.viewModel?.selectedUser != nil {
          self.directButton.isHidden = false
        }
      }
    } else {
      loadUserFromDynamicLink()
    }
  }
  
  func setupProfile() {
    if self.viewModel?.selectedUser != nil {
         instaButton.isHidden = self.viewModel?.selectedUser?.instagramLink != nil && self.viewModel?.selectedUser?.instagramLink?.count > 0 ? false : true
         facebookButton.isHidden = self.viewModel?.selectedUser?.facebookLink != nil && self.viewModel?.selectedUser?.facebookLink?.count > 0  ? false : true
         vkButton.isHidden = self.viewModel?.selectedUser?.vkLink != nil && self.viewModel?.selectedUser?.vkLink?.count > 0 ? false : true
       } else {
         instaButton.isHidden = AuthModule.currUser.instagramLink != nil && AuthModule.currUser.instagramLink?.count > 0 ? false : true
         facebookButton.isHidden = AuthModule.currUser.facebookLink != nil && AuthModule.currUser.facebookLink?.count > 0 ? false : true
         vkButton.isHidden = AuthModule.currUser.vkLink != nil && AuthModule.currUser.vkLink?.count > 0 ? false : true
       }
    
       if let user = viewModel?.selectedUser {
         tagList.isHidden = user.userType == .sportsman ? true : false
         if let avatar = user.avatar {
           photoImageView.sd_setImage(with: URL(string: avatar), placeholderImage: UIImage(named:"Group-1"), options: .allowInvalidSSLCertificates, completed: nil)
         }  else {
           photoImageView.image = UIImage(named:"Group-1")
         }
         nameLabel.text = "\(viewModel?.selectedUser?.firstName ?? "") \(viewModel?.selectedUser?.lastName ?? "")"
         if viewModel?.selectedUser?.userType == .trainer {
           cityLabel.text = "Тренер \(viewModel?.selectedUser?.city ?? "")"
         } else {
           cityLabel.text = "Спортсмен \(viewModel?.selectedUser?.city ?? "")"
         }
       } else {
         if let url = AuthModule.currUser.avatar {
           photoImageView.sd_setImage(with: URL(string: url), placeholderImage: UIImage(named:"Group-1"), options: .allowInvalidSSLCertificates, completed: nil)
         } else {
           photoImageView.image = UIImage(named:"Group-1")
         }
         nameLabel.text = "\(AuthModule.currUser.firstName ?? "") \(AuthModule.currUser.lastName ?? "")"
         tagList.isHidden = AuthModule.currUser.userType == .sportsman ? true : false
         if AuthModule.currUser.userType == .trainer {
           cityLabel.text = "Тренер \(AuthModule.currUser.city ?? "")"
         } else {
           cityLabel.text = "Спортсмен \(AuthModule.currUser.city ?? "")"
         }
       }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
  }
  
  func setupUI() {
    backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
    backButton.snp.makeConstraints { (make) in
         make.top.equalTo(self.view.snp.top).offset(screenSize.height * (60/iPhoneXHeight))
         make.left.equalTo(self.view.snp.left).offset((screenSize.width * (20/iPhoneXWidth)))
         make.width.equalTo(20)
         make.height.equalTo(17)
       }
    
    directButton.addTarget(self, action: #selector(directMessage), for: .touchUpInside)
    directButton.snp.makeConstraints { (make) in
         make.top.equalTo(self.view.snp.top).offset(screenSize.height * (60/iPhoneXHeight))
         make.right.equalTo(self.view.snp.right).offset((screenSize.width * (-20/iPhoneXWidth)))
         make.width.equalTo(20)
         make.height.equalTo(17)
       }
    
    photoImageView.snp.makeConstraints { (make) in
      make.top.equalTo(self.view.snp.top).offset(screenSize.height * (61/iPhoneXHeight))
      make.centerX.equalTo(self.view.snp.centerX)
      make.width.height.equalTo(screenSize.height * (81/iPhoneXHeight))
    }
    
    nameLabel.font = NewFonts.SFProDisplaySemiBold16
    nameLabel.snp.makeConstraints { (make) in
        make.top.equalTo(self.photoImageView.snp.bottom).offset(screenSize.height * (8/iPhoneXHeight))
        make.centerX.equalTo(self.view.snp.centerX)
      }
    cityLabel.font = NewFonts.SFProDisplaySemiBold12
    cityLabel.snp.makeConstraints { (make) in
        make.top.equalTo(self.nameLabel.snp.bottom).offset(screenSize.height * (4/iPhoneXHeight))
        make.centerX.equalTo(self.view.snp.centerX)
      }
    
    scrollView.snp.makeConstraints { (make) in
      make.top.equalTo(self.socialsStackView.snp.bottom).offset(screenSize.height * (12/iPhoneXHeight))
      make.centerX.equalTo(self.view.snp.centerX)
    }
  
    
    photoImageView.cornerRadius = 32
    tagList.textFont = NewFonts.SFProDisplaySemiBold12
    tagList.alignment = .center
    tagList.delegate = self
    let first =  LabelSegment.init(text: "ГАЛЕРЕЯ", numberOfLines: 1, normalBackgroundColor: UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.00), normalFont: NewFonts.SFProDisplayBold11, normalTextColor: UIColor(red: 0.34, green: 0.45, blue: 0.60, alpha: 1.00), selectedBackgroundColor: UIColor(red: 0.34, green: 0.45, blue: 0.60, alpha: 1.00), selectedFont: NewFonts.SFProDisplayBold11, selectedTextColor: UIColor(red: 0.97, green: 0.97, blue: 1.00, alpha: 1.00), accessibilityIdentifier: "")
    let second =  LabelSegment.init(text: "ИНФОРМАЦИЯ", numberOfLines: 1, normalBackgroundColor: UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.00), normalFont: NewFonts.SFProDisplayBold11, normalTextColor: UIColor(red: 0.34, green: 0.45, blue: 0.60, alpha: 1.00), selectedBackgroundColor: UIColor(red: 0.34, green: 0.45, blue: 0.60, alpha: 1.00), selectedFont: NewFonts.SFProDisplayBold11, selectedTextColor: UIColor(red: 0.97, green: 0.97, blue: 1.00, alpha: 1.00), accessibilityIdentifier: "")
    let third =  LabelSegment.init(text: "СПОРТСМЕНЫ", numberOfLines: 1, normalBackgroundColor: UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.00), normalFont: NewFonts.SFProDisplayBold11, normalTextColor: UIColor(red: 0.34, green: 0.45, blue: 0.60, alpha: 1.00), selectedBackgroundColor: UIColor(red: 0.34, green: 0.45, blue: 0.60, alpha: 1.00), selectedFont: NewFonts.SFProDisplayBold11, selectedTextColor: UIColor(red: 0.97, green: 0.97, blue: 1.00, alpha: 1.00), accessibilityIdentifier: "")
    if viewModel?.selectedUser != nil {
      if viewModel?.selectedUser?.userType == .trainer {
        segmentedControl.segments = [first,second,third]
      } else {
        segmentedControl.isHidden = true
        segmentedControl.segments = [first]
      }
    } else {
      if AuthModule.currUser.userType == .trainer {
        segmentedControl.segments = [first,second,third]
      } else {
        segmentedControl.isHidden = true
        segmentedControl.segments = [first]
      }
    }

    segmentedControl.addTarget(self, action: #selector(photoControl(_:)), for: .valueChanged)
    photoView.alpha = 1
    informationView.alpha = 0
    sportsmanView.alpha = 0
    
     let pictureTap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
          photoImageView.addGestureRecognizer(pictureTap)
          photoImageView.isUserInteractionEnabled = true
  }
  
  @objc func imageTapped() {
    let photoSlider = PhotoSlider.ViewController(images: [photoImageView.image ?? UIImage()])
    photoSlider.pageControl.isHidden = true
    self.present(photoSlider, animated: true, completion: nil)
  }
  
  func fetchSkills() {
    viewModel!.fetchSpecialization { (value) in
      if value {
        self.tagList.removeAllTags()
        if self.viewModel?.selectedUser == nil {
          self.tagList.addTag("Добавить тег +")
        }
        self.tagList.addTags(self.viewModel!.userSkills)
      }
    }
  }
  
  @objc func photoControl(_ sender: BetterSegmentedControl) {
    print("The selected index is \(sender.index)")
  
    updateSegmentedControler(selectedIndex: sender.index)
  }
  
  func updateSegmentedControler(selectedIndex: Int) {
    switch selectedIndex {
      case 0:
      photoView.alpha = 1
      informationView.alpha = 0
      sportsmanView.alpha = 0
      case 1:
      photoView.alpha = 0
      informationView.alpha = 1
      sportsmanView.alpha = 0
      case 2:
      photoView.alpha = 0
      informationView.alpha = 0
      sportsmanView.alpha = 1
      default:
      return
    }
  }
  
  @objc func backAction() {
    self.navigationController?.dismiss(animated: true, completion: nil)
  }
  
  @objc func directMessage() {
    if let id = viewModel?.selectedUser?.id {
      DispatchQueue.main.async {
      let chatViewController = chatStoryboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController
        chatViewController?.viewModel = ChatViewModel(chatId: self.viewModel!.chatId!, chatUserId: id, chatUserName: "\(self.viewModel!.selectedUser?.firstName ?? "") \(self.viewModel!.selectedUser?.lastName ?? "")")
        chatViewController?.viewModel!.chatUser = self.viewModel?.selectedUser
        chatViewController?.viewModel?.chatUserAvatar = self.viewModel?.selectedUser?.avatar
      chatViewController?.senderDisplayName = ""
      let nc = UINavigationController(rootViewController: chatViewController!)
      nc.modalPresentationStyle = .fullScreen
      self.present(nc, animated: true, completion: nil)
      }
    }
  }
  
  
  @IBAction func instagramAction(_ sender: Any) {
      let instagramLink = self.viewModel?.selectedUser?.instagramLink != nil ? self.viewModel?.selectedUser?.instagramLink : AuthModule.currUser.instagramLink
    let userName =  instagramLink?.trimmingCharacters(in: .whitespaces) // Your Instagram Username here
    if var link = userName?.detectedFirstLink {
        if !link.contains("https://") {
          link = "https://\(link)"
        }
        if let url = URL(string: link) {
          UIApplication.shared.open(url)
        }
      } else {
      let appURL = URL(string: "instagram://user?username=\(userName ?? "")")!
        let application = UIApplication.shared
        
        if application.canOpenURL(appURL) {
          application.open(appURL)
        } else {
          let webURL = URL(string: "https://instagram.com/\(userName ?? "")")!
          application.open(webURL)
        }
      }
   }
  
  @IBAction func facebookAction(_ sender: Any) {
      let facebookLink = self.viewModel?.selectedUser?.facebookLink != nil ? self.viewModel?.selectedUser?.facebookLink : AuthModule.currUser.facebookLink
    let userName =  facebookLink?.trimmingCharacters(in: .whitespaces)
    if let link = userName?.detectedFirstLink {
         if let url = URL(string: link) {
           UIApplication.shared.open(url)
         }
       } else {
         let webURL = URL(string: "https://www.facebook.com/\(userName)")!
         UIApplication.shared.open(webURL)
       }
   }
  
  @IBAction func vkAction(_ sender: Any) {
    let vkLink = self.viewModel?.selectedUser?.vkLink != nil ? self.viewModel?.selectedUser?.vkLink : AuthModule.currUser.vkLink
       let userName =  vkLink
    if let link = userName?.detectedFirstLink {
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
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    print("\(segue.destination)")
    if let vc: ProfileGalleryViewController = segue.destination as? ProfileGalleryViewController {
      galleryViewController = vc
      galleryViewController!.viewModel = self.viewModel
    }
    
    if let vc: UserAchievementsViewController = segue.destination as? UserAchievementsViewController {
      achievementsViewController = vc
      achievementsViewController!.viewModel = self.viewModel!
     }
    
    if let vc: UsersSportsmansViewController = segue.destination as? UsersSportsmansViewController {
         userSportsmansViewController = vc
         userSportsmansViewController!.viewModel = CommunityViewModel()
         userSportsmansViewController!.viewModel?.selectedUser = self.viewModel!.selectedUser
       }
  }

}

// MARK: Taglist Delegate

extension NewProfileViewController: TagListViewDelegate {
  
  func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
    if title == "Добавить тег +" {
      let vc = newProfileStoryboard.instantiateViewController(withIdentifier: "SpecializationsViewController") as! SpecializationsViewController
      vc.viewModel = viewModel
      let nc = UINavigationController(rootViewController: vc)
      self.present(nc, animated: true, completion: nil)

    }
//    let index = sender.tagViews.firstIndex(of: tagView)
//    tagView.isSelected =  tagView.isSelected ? true : !tagView.isSelected
//    for tag in sender.tagViews {
//      if tag != tagView {
//        tag.isSelected = false
//      }
//    }
//    if viewModel!.selectedSegmentedControlIndex != index {
//      self.viewModel!.selectSegment(index: index!)
//      fetchOrders()
//    }
  }
}

