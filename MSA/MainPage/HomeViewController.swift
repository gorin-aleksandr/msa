//
//  HomeViewController.swift
//  
//
//  Created by Nik on 17.08.2020.
//

import UIKit

class HomeViewController: UIViewController {
  @IBOutlet weak var collectionView: UICollectionView!
  var images = ["powerlifter","eat","ruller","stats","team"]
  var titles = ["Тренировки","Питание","Статистика","Замеры","Мои спортсмены"]
  var descriptions = ["У вас 24 тренировки","Добавьте диету","Закончено 24 тренировки","Ваши параметры","У вас 23 спортсмена"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  func setupUI() {
    collectionView.dataSource = self
    collectionView.delegate = self
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
      return 5
      default:
          return 6
    }
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 3
  }
  
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  1
        let collectionViewSizeWidth = collectionView.frame.size.width - padding
        let collectionViewSizeHeight = collectionView.frame.size.height - padding

  //      if indexPath.row == 4 {
  //        return CGSize(width: collectionViewSizeWidth - 18, height: collectionViewSizeHeight/3.25)
  //      } else {
      if indexPath.section == 0 {
        return CGSize(width: collectionViewSizeWidth - 20, height: 80)

      } else if indexPath.section == 1  {
        return CGSize(width: collectionViewSizeWidth - 20, height: 50)
      }  else {
        return CGSize(width: collectionViewSizeWidth/2.2, height: collectionViewSizeHeight/6.5)
      }
        //}
    }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    if indexPath.section == 0 {
      let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeProfileCollectionViewCell", for: indexPath as IndexPath) as! HomeProfileCollectionViewCell
      myCell.logoImageView.image = UIImage(named: "demo avatar")
      myCell.logoImageView.roundCorners(.allCorners, radius: 16)
      myCell.titleLabel.text = "Андрей Иванов"
      myCell.layer.cornerRadius = 10
      myCell.layer.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.00).cgColor
     myCell.layer.masksToBounds = false
     // myCell.mainView.roundCorners(.allCorners, radius: 10)
      return myCell

    } else if indexPath.section == 1 {
      let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeTargetCollectionViewCell", for: indexPath as IndexPath) as! HomeTargetCollectionViewCell
      myCell.titleLabel.text = "6 кубиков за 6 месяцев"
      myCell.layer.cornerRadius = 10
      myCell.layer.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.00).cgColor
      myCell.layer.masksToBounds = false
      return myCell
    } else {
      let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath as IndexPath) as! HomeCollectionViewCell
      myCell.logoImageView.image = UIImage(named: images[indexPath.row])
      myCell.titleLabel.text = titles[indexPath.row]
      myCell.descriptionLabel.text = descriptions[indexPath.row]
      myCell.mainView.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.98, alpha: 1.00)
      myCell.mainView.roundCorners(.allCorners, radius: 10)
      return myCell
    }
    

  }
  
  //  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
  //
  //      var slider = PhotoSlider.ViewController(imageURLs: self.images)
  //      slider.currentPage = indexPath.row
  //      photoSlider.transitioningDelegate = self
  //      present(photoSlider, animated: true, completion: nil)
  //
  //  }
  
}
