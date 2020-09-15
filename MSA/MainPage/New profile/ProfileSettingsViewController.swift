//
//  SignInViewController.swift
//  STO App
//
//  Created by Nik on 13.03.2020.
//  Copyright © 2020 Nik. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class ProfileSettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var cityLabel: UILabel!
  @IBOutlet weak var editButton: UIButton!
  @IBOutlet weak var photoImageView: UIImageView!
  @IBOutlet weak var addPhotoButto: UIButton!
  var myPicker = UIImagePickerController()

  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
  var viewModel  = ProfileViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  func setupUI() {
    myPicker.delegate = self
    setupConstraint()
    let backButton = UIBarButtonItem(image: UIImage(named: "arrow-left 1"), style: .plain, target: self, action: #selector(self.backAction))
    self.navigationItem.leftBarButtonItem = backButton
    self.navigationController?.navigationBar.tintColor = .newBlack
    cityLabel.isHidden = true
    
    tableView.dataSource = self
    tableView.delegate = self
    tableView.separatorStyle = .none
    tableView.tableFooterView = UIView()
    nameTextField.delegate = self
    nameTextField.font = NewFonts.SFProDisplayBold20
    editButton.isHidden = true
    editButton.addTarget(self, action: #selector(editName), for: .touchUpInside)
    addPhotoButto.addTarget(self, action: #selector(addPhotoAction), for: .touchUpInside)
    nameTextField.text = "\(AuthModule.currUser.firstName ?? "") \(AuthModule.currUser.lastName ?? "")"
    if let url = AuthModule.currUser.avatar {
      photoImageView.sd_setImage(with: URL(string: url), placeholderImage: #imageLiteral(resourceName: "avatarPlaceholder"), options: .allowInvalidSSLCertificates, completed: nil)
    }
    
  }
  
  func setupConstraint() {
    photoImageView.snp.makeConstraints { (make) in
      make.top.equalTo(screenSize.height * (95/iPhoneXHeight))
      make.centerX.equalTo(self.view.snp.centerX)
      make.width.height.equalTo(screenSize.height * (64/iPhoneXHeight))
    }
    photoImageView.cornerRadius = (screenSize.height * (64/iPhoneXHeight))/2
    
    addPhotoButto.snp.makeConstraints { (make) in
      make.bottom.equalTo(photoImageView.snp.bottom)
      make.right.equalTo(photoImageView.snp.right)
      make.width.height.equalTo(screenSize.height * (20/iPhoneXHeight))
    }
    
    nameTextField.snp.makeConstraints { (make) in
      make.top.equalTo(photoImageView.snp.bottom).offset(screenSize.height * (16/iPhoneXHeight))
      make.centerX.equalTo(self.view.snp.centerX)
    }
    
    editButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(nameTextField.snp.centerY)
      make.left.equalTo(nameTextField.snp.right).offset(screenSize.height * (5/iPhoneXHeight))
    }
    
    tableView.snp.makeConstraints { (make) in
      make.top.equalTo(nameTextField.snp.bottom).offset(screenSize.height * (16/iPhoneXHeight))
      make.bottom.equalTo(self.view.snp.bottom)
      make.right.equalTo(self.view.snp.right)
      make.left.equalTo(self.view.snp.left)
    }
    
  }
  
  @objc func backAction() {
    self.navigationController?.popViewController(animated: true)
  }
  
  
  
  func showEditProfile() {
    
  }
  
  @objc func editName(sender: UIButton!) {
    
  }
  
  func openGallary() {
         myPicker.allowsEditing = true
       myPicker.sourceType = UIImagePickerController.SourceType.photoLibrary
         present(myPicker, animated: true, completion: nil)
     }
     
     func openCamera() {
         myPicker.allowsEditing = true
       myPicker.sourceType = UIImagePickerController.SourceType.camera
         present(myPicker, animated: true, completion: nil)
     }
  
  
  @objc func addPhotoAction(sender: UIButton!) {
    let alert = UIAlertController(title: "Загрузить из:", message: nil, preferredStyle: .actionSheet)
     alert.addAction(UIAlertAction(title: "Камеры", style: .default, handler: { _ in
         self.openCamera()
     }))
     alert.addAction(UIAlertAction(title: "Галереи", style: .default, handler: { _ in
         self.openGallary()
     }))
     alert.addAction(UIAlertAction.init(title: "Отменить", style: .cancel, handler: { _ in
         //self.finishLoading()
     }))
     self.present(alert, animated: true, completion: nil)
     //startLoading()
  }
  
   func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //finishLoading()
        dismiss(animated: true, completion: nil)
    }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
      guard let chosenImage = info[.editedImage] as? UIImage else {
        return
      }
      dismiss(animated: true, completion: nil)
    
      SVProgressHUD.show()
      viewModel.updateUserAvatar(chosenImage, completion: { (image) in
        self.photoImageView.image = chosenImage
        SVProgressHUD.dismiss()
      }) { (error) in
        SVProgressHUD.dismiss()
      }
  }
  
  func uploadPhoto() {
    
  }
  
  func menuCellImage(row: Int) -> UIImage {
    switch row {
      case 0:
        return UIImage(named: "user 3")!
      case 1:
        return UIImage(named: "user 32")!
//      case 2:
//        return UIImage(named: "settings (1) 1")!
//      case 3:
//        return UIImage(named: "question (1) 1")!
      case 2:
        return UIImage(named: "logout 1")!
      default:
        return UIImage(named: "maps-and-flags 1")!
    }
  }
  
  func menuCellText(row: Int) -> String {
    switch row {
      case 0:
        return "Профиль"
      case 1:
        return "Персональный данные"
//      case 2:
//        return "Настройки"
//      case 3:
//        return "Помощь"
      case 2:
        return "Выйти"
      default:
        return "Выйти"
    }
  }
  
  func logout() {
    TrainingsDataSource.shared.clearDB()
    viewModel.deleteUserBlock(context: context) { (loggedOut) in
      self.viewModel.clearRealm()
      if loggedOut {
        AuthModule.currUser.id = nil
        Analytics.logEvent("logout", parameters: nil)
        let nextViewController = signInStoryboard.instantiateViewController(withIdentifier: "StartOnboardingViewController") as! StartOnboardingViewController
        let nc = UINavigationController(rootViewController: nextViewController)
        nc.modalPresentationStyle = .fullScreen
        self.present(nc, animated: true, completion: nil)
      } else {
        AlertDialog.showAlert("Ошибка", message: "Ошибка при выходе из приложения", viewController: self)
      }
    }
  }
  
}

// MARK: - TableViewDataSource
extension ProfileSettingsViewController: UITableViewDataSource, UITableViewDelegate {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return screenSize.height * (77/iPhoneXHeight)
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3 //viewModel!.numberOfRowsInSectionForMenuOrder(section)
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileMenuCell") as! ProfileMenuCell
    cell.logoImageVIew.image = menuCellImage(row: indexPath.row)
    cell.nameLabel.text = menuCellText(row: indexPath.row)
    //cell.mainView.roundCorners(corners: .allCorners, radius: 8)
    cell.mainView.layer.cornerRadius = 8
    cell.mainView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.00)
    cell.selectionStyle = .none
    return cell
    //viewModel!.cellMenuController(tableView, indexPath: indexPath)
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //viewModel!.selectMenu(indexPath)
    if indexPath.row == 0 {
      let vc = newProfileStoryboard.instantiateViewController(withIdentifier: "NewProfileViewController") as! NewProfileViewController
      vc.viewModel = viewModel
      self.navigationController?.pushViewController(vc, animated: true)
    } else if indexPath.row == 1 {
      let vc = newProfileStoryboard.instantiateViewController(withIdentifier: "UserSettingsViewController") as! UserSettingsViewController
      vc.viewModel = ProfileViewModel()
      vc.viewModel!.editSettingsControllerType = .userInfo
      self.navigationController?.pushViewController(vc, animated: true)
    } else if indexPath.row == 2 {
      logout()
    }
    
  }
}


// MARK: - UITextFieldDelegate

extension ProfileSettingsViewController: UITextFieldDelegate {
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    return true
  }
  
  func textFieldDidChangeSelection(_ textField: UITextField) {
    //viewModel!.updateNameTextValue(text: textField.text ?? "")
  }
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
  }
}





