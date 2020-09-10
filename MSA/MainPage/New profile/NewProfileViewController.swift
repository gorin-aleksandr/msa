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

  var viewModel: ProfileViewModel?
  
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    viewModel!.fetchSpecialization { (value) in
      if value {
        self.tagList.removeAllTags()
        self.tagList.addTag("+")
        self.tagList.addTags(self.viewModel!.userSkills)

      }
    }
  }
  
  func setupUI() {
    if let url = AuthModule.currUser.avatar {
      photoImageView.sd_setImage(with: URL(string: url), placeholderImage: #imageLiteral(resourceName: "avatarPlaceholder"), options: .allowInvalidSSLCertificates, completed: nil)
    }
    nameLabel.text = "\(AuthModule.currUser.firstName ?? "") \(AuthModule.currUser.lastName ?? "")"
    cityLabel.text = "\(AuthModule.currUser.city ?? "")"

    photoImageView.cornerRadius = 32
    //tagList.addTags(["+","Вит","Функциональный трейнинг","Фитнес","Бокс","Футбол","Аеробика"])//,"Отмененные"
    tagList.textFont = UIFont.systemFont(ofSize: 14)
    tagList.alignment = .center
    tagList.delegate = self
    let first =  LabelSegment.init(text: "ГАЛЕРЕЯ", numberOfLines: 1, normalBackgroundColor: UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.00), normalFont: NewFonts.SFProDisplayRegular12, normalTextColor: UIColor(red: 0.34, green: 0.45, blue: 0.60, alpha: 1.00), selectedBackgroundColor: UIColor(red: 0.34, green: 0.45, blue: 0.60, alpha: 1.00), selectedFont: NewFonts.SFProDisplayRegular12, selectedTextColor: UIColor(red: 0.97, green: 0.97, blue: 1.00, alpha: 1.00), accessibilityIdentifier: "")
    let second =  LabelSegment.init(text: "ИНФОРМАЦИЯ", numberOfLines: 1, normalBackgroundColor: UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.00), normalFont: NewFonts.SFProDisplayRegular12, normalTextColor: UIColor(red: 0.34, green: 0.45, blue: 0.60, alpha: 1.00), selectedBackgroundColor: UIColor(red: 0.34, green: 0.45, blue: 0.60, alpha: 1.00), selectedFont: NewFonts.SFProDisplayRegular12, selectedTextColor: UIColor(red: 0.97, green: 0.97, blue: 1.00, alpha: 1.00), accessibilityIdentifier: "")
    let third =  LabelSegment.init(text: "СПОРТСМЕНЫ", numberOfLines: 1, normalBackgroundColor: UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.00), normalFont: NewFonts.SFProDisplayRegular12, normalTextColor: UIColor(red: 0.34, green: 0.45, blue: 0.60, alpha: 1.00), selectedBackgroundColor: UIColor(red: 0.34, green: 0.45, blue: 0.60, alpha: 1.00), selectedFont: NewFonts.SFProDisplayRegular12, selectedTextColor: UIColor(red: 0.97, green: 0.97, blue: 1.00, alpha: 1.00), accessibilityIdentifier: "")
    segmentedControl.segments = [first,second,third]
    segmentedControl.addTarget(self, action: #selector(photoControl(_:)), for: .valueChanged)
    //tagList.tagViews[0].isSelected = true
    photoView.alpha = 1
    informationView.alpha = 0
    sportsmanView.alpha = 0
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

}

// MARK: Taglist Delegate

extension NewProfileViewController: TagListViewDelegate {
  
  func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
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
