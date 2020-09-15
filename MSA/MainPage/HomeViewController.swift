//
//  HomeViewController.swift
//  
//
//  Created by Nik on 17.08.2020.
//

import UIKit
import SVProgressHUD

class HomeViewController: UIViewController {
  @IBOutlet weak var collectionView: UICollectionView!
  var images = ["powerlifter","ruller","eat","statsIcon","team"]
  var titles = ["Тренировки","Замеры","Питание","Статистика","Мои спортсмены"]
  var descriptions = ["У вас 24 тренировки","Ваши параметры","Добавьте диету","Ваши результаты","У вас 23 спортсмена"]
  var viewModel = ProfileViewModel()
  private let presenter = GalleryDataPresenter(gallery: GalleryDataManager())

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    if viewModel.selectedUser == nil {
      SVProgressHUD.show()
      self.viewModel.getUser(success: {
         SVProgressHUD.dismiss()
         self.collectionView.reloadData()
       })
    }
    if viewModel.selectedUser != nil {
      navigationController?.setNavigationBarHidden(false, animated: false)
      let backButton = UIBarButtonItem(image: UIImage(named: "backIcon"), style: .plain, target: self, action: #selector(self.backAction))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.navigationBar.tintColor = .newBlack
    } else {
      navigationController?.setNavigationBarHidden(true, animated: false)
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
  
  @objc private func handleAppleSignInSelector() {
    presentInputStatus()
  }
  
  @objc func presentInputStatus() {
    DispatchQueue.main.async {
          let destinationVC = UIStoryboard(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "IAPViwController") as! IAPViewController
          //let navigationController = UINavigationController()
          //navigationController.setViewControllers([destinationVC], animated: false)
          self.present(destinationVC, animated: true, completion: nil)
        }
//    let alert = UIAlertController(style: .actionSheet, title: "Укажите цель")
//    let config: TextField.Config = { textField in
//      textField.becomeFirstResponder()
//      textField.textColor = .black
//      if let dream = AuthModule.currUser.purpose, dream != "" {
//        textField.text = dream
//      }
//      textField.placeholder = "Напишите вашу цель"
//      //textField.left(image: image, color: .black)
//      textField.leftViewPadding = 12
//      textField.borderWidth = 1
//      textField.cornerRadius = 8
//      textField.borderColor = UIColor.lightGray.withAlphaComponent(0.5)
//      textField.backgroundColor = nil
//      textField.keyboardAppearance = .default
//      textField.keyboardType = .default
//      textField.isSecureTextEntry = false
//      textField.returnKeyType = .done
//      textField.action { textField in
//        if let purpose = textField.text, purpose != AuthModule.currUser.purpose  {
//          self.viewModel.setPurpose(purpose: purpose, success: {
//            self.collectionView.reloadData()
//          }) { (error) in
//          }
//        }
//      }
//    }
//    alert.addOneTextField(configuration: config)
//    let saveAction = UIAlertAction(title: "Сохранить", style: .default) { (action) in
//    }
//    alert.addAction(saveAction)
//    alert.show()
  }
  
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch section {
      case 0:
        return 1
      case 1:
        return 1
      case 2:
        if AuthModule.currUser.userType == .trainer && viewModel.selectedUser == nil{
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
      return CGSize(width: screenSize.width * (335/iPhoneXWidth), height: screenSize.height * (40/iPhoneXHeight))
    }  else {
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
          myCell.logoImageView.sd_setImage(with: URL(string: url), placeholderImage: #imageLiteral(resourceName: "avatarPlaceholder"), options: .allowInvalidSSLCertificates, completed: nil)
        } else {
          myCell.logoImageView.image = #imageLiteral(resourceName: "avatarPlaceholder")
        }
      } else {
        if let url = viewModel.selectedUser?.avatar {
          print(viewModel.selectedUser)
          myCell.logoImageView.sd_setImage(with: URL(string: url), placeholderImage: #imageLiteral(resourceName: "avatarPlaceholder"), options: .allowInvalidSSLCertificates, completed: nil)
        } else {
          myCell.logoImageView.image = #imageLiteral(resourceName: "avatarPlaceholder")
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
      let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeTargetCollectionViewCell", for: indexPath as IndexPath) as! HomeTargetCollectionViewCell
      if let selectedUser = viewModel.selectedUser  {
        if let purpose = selectedUser.purpose {
          myCell.titleLabel.text = purpose
        } else {
          myCell.titleLabel.text = ""
        }
        
      } else {
        if let purpose = AuthModule.currUser.purpose {
          myCell.titleLabel.text = purpose
        } else {
          myCell.titleLabel.text = "Укажите цель"
        }
      }
    
      myCell.layer.cornerRadius = screenSize.height * (16/iPhoneXHeight)
      myCell.layer.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.00).cgColor
      myCell.layer.masksToBounds = false
      let tap = UITapGestureRecognizer(target: self, action:  #selector(handleAppleSignInSelector))
      myCell.rightImageView.addGestureRecognizer(tap)
      myCell.rightImageView.isUserInteractionEnabled = true
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
      print(viewModel.selectedUser)
      vc.viewModel = viewModel
      self.navigationController?.pushViewController(vc, animated: true)
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
              nextViewController.viewModel!.selectedUserId = selectedUser.id!
            } else {
              nextViewController.viewModel!.selectedUserId = AuthModule.currUser.id!
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
  
  
}
