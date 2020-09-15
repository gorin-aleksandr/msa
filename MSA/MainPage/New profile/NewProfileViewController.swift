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

class NewProfileViewController: UIViewController {

  @IBOutlet weak var photoImageView: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var cityLabel: UILabel!
  @IBOutlet weak var tagList: TagListView!
  @IBOutlet weak var segmentedControl: BetterSegmentedControl!
  @IBOutlet weak var photoView: UIView!
  @IBOutlet weak var informationView: UIView!
  @IBOutlet weak var sportsmanView: UIView!

  var viewModel: ProfileViewModel? {
    didSet {
      self.viewModel!.reloadSkillsTable = {
        self.fetchSkills()
      }
    }
  }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    navigationController?.setNavigationBarHidden(false, animated: false)
    navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationController?.navigationBar.shadowImage = UIImage()
    navigationController?.navigationBar.isTranslucent = true
    let backButton = UIBarButtonItem(image: UIImage(named: "arrow-left 1"), style: .plain, target: self, action: #selector(self.backAction))
    self.navigationItem.leftBarButtonItem = backButton
    self.navigationController?.navigationBar.tintColor = .newBlack
    fetchSkills()
    
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    //navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  func setupUI() {
      if let url = viewModel?.selectedUser?.avatar {
          photoImageView.sd_setImage(with: URL(string: url), placeholderImage: #imageLiteral(resourceName: "avatarPlaceholder"), options: .allowInvalidSSLCertificates, completed: nil)
        nameLabel.text = "\(viewModel?.selectedUser?.firstName ?? "") \(viewModel?.selectedUser?.lastName ?? "")"
        cityLabel.text = "\(viewModel?.selectedUser?.city ?? "")"
    } else {
      if let url = AuthModule.currUser.avatar {
          photoImageView.sd_setImage(with: URL(string: url), placeholderImage: #imageLiteral(resourceName: "avatarPlaceholder"), options: .allowInvalidSSLCertificates, completed: nil)
        nameLabel.text = "\(AuthModule.currUser.firstName ?? "") \(AuthModule.currUser.lastName ?? "")"
        cityLabel.text = "\(AuthModule.currUser.city ?? "")"
        }
    }
    

    photoImageView.cornerRadius = 32
    tagList.textFont = UIFont.systemFont(ofSize: 14)
    tagList.alignment = .center
    tagList.delegate = self
    let first =  LabelSegment.init(text: "ГАЛЕРЕЯ", numberOfLines: 1, normalBackgroundColor: UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.00), normalFont: NewFonts.SFProDisplayRegular12, normalTextColor: UIColor(red: 0.34, green: 0.45, blue: 0.60, alpha: 1.00), selectedBackgroundColor: UIColor(red: 0.34, green: 0.45, blue: 0.60, alpha: 1.00), selectedFont: NewFonts.SFProDisplayRegular12, selectedTextColor: UIColor(red: 0.97, green: 0.97, blue: 1.00, alpha: 1.00), accessibilityIdentifier: "")
    let second =  LabelSegment.init(text: "ИНФОРМАЦИЯ", numberOfLines: 1, normalBackgroundColor: UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.00), normalFont: NewFonts.SFProDisplayRegular12, normalTextColor: UIColor(red: 0.34, green: 0.45, blue: 0.60, alpha: 1.00), selectedBackgroundColor: UIColor(red: 0.34, green: 0.45, blue: 0.60, alpha: 1.00), selectedFont: NewFonts.SFProDisplayRegular12, selectedTextColor: UIColor(red: 0.97, green: 0.97, blue: 1.00, alpha: 1.00), accessibilityIdentifier: "")
    let third =  LabelSegment.init(text: "СПОРТСМЕНЫ", numberOfLines: 1, normalBackgroundColor: UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.00), normalFont: NewFonts.SFProDisplayRegular12, normalTextColor: UIColor(red: 0.34, green: 0.45, blue: 0.60, alpha: 1.00), selectedBackgroundColor: UIColor(red: 0.34, green: 0.45, blue: 0.60, alpha: 1.00), selectedFont: NewFonts.SFProDisplayRegular12, selectedTextColor: UIColor(red: 0.97, green: 0.97, blue: 1.00, alpha: 1.00), accessibilityIdentifier: "")
    if viewModel?.selectedUser != nil {
      if viewModel?.selectedUser?.userType == .trainer {
        segmentedControl.segments = [first,second,third]
      } else {
        segmentedControl.segments = [first,second]
      }
    } else {
      if AuthModule.currUser.userType == .trainer {
        segmentedControl.segments = [first,second,third]
      } else {
        segmentedControl.segments = [first,second]
      }
    }

    segmentedControl.addTarget(self, action: #selector(photoControl(_:)), for: .valueChanged)
    //tagList.tagViews[0].isSelected = true
    photoView.alpha = 1
    informationView.alpha = 0
    sportsmanView.alpha = 0
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
  
  @IBAction func backAction(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    print("\(segue.destination)")
    if let vc: ProfileGalleryViewController = segue.destination as? ProfileGalleryViewController {
      vc.viewModel = self.viewModel
    }
    
    if let vc: UserAchievementsViewController = segue.destination as? UserAchievementsViewController {
      vc.viewModel = self.viewModel!
     }
    
    if let vc: UsersSportsmansViewController = segue.destination as? UsersSportsmansViewController {
         vc.viewModel = CommunityViewModel()
         vc.viewModel?.selectedUser = self.viewModel!.selectedUser 
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

