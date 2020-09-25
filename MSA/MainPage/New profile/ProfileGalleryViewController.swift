//
//  ProfileGalleryViewController.swift
//  MSA
//
//  Created by Nik on 31.08.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import SDWebImage
import PhotoSlider
import SVProgressHUD

class ProfileGalleryViewController: UIViewController, UINavigationControllerDelegate {
  @IBOutlet weak var galleryCollectionView: UICollectionView!
  var myPicker = UIImagePickerController()
  var galleryUploadInProgress: Bool = false
  private let presenter = GalleryDataPresenter(gallery: GalleryDataManager())
  var pendingForUpload: [[UIImagePickerController.InfoKey : Any]] = []
  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  var viewModel: ProfileViewModel?
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    setupUI()

  }
  
  func setupUI() {
    presenter.attachView(view: self)
    presenter.getGallery(for: AuthModule.currUser.id)
    myPicker.delegate = self
    galleryCollectionView.dataSource = self
    galleryCollectionView.delegate = self
    galleryCollectionView.snp.makeConstraints { (make) in
      make.top.equalTo(self.view.snp.top)
      make.bottom.equalTo(self.view.snp.bottom)
      make.right.equalTo(self.view.snp.right)
      make.left.equalTo(self.view.snp.left)
    }
    
    let btn = UIButton(type: .custom) as UIButton
    btn.addTarget(self, action: #selector(addContent), for: .touchUpInside)
    btn.setBackgroundImage(UIImage(named: "Float-1"), for: .normal)
    if viewModel?.selectedUser == nil {
      self.view.addSubview(btn)
      btn.snp.makeConstraints { (make) in
         make.right.equalTo(self.view.snp.right).offset(screenSize.height * (-8/iPhoneXHeight))
         make.bottom.equalTo(self.view.snp.bottom).offset(screenSize.height * (-25/iPhoneXHeight))
         make.height.width.equalTo(screenSize.height * (96/iPhoneXHeight))
       }
    }
 
  }

  @objc func addContent(_ sender: UIButton) {
    let alert = UIAlertController(title: "Загрузить:", message: nil, preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "Камеры", style: .default, handler: { _ in
      self.openCamera()
    }))
    alert.addAction(UIAlertAction(title: "Из галереи", style: .default, handler: { _ in
      self.openGallary()
    }))
    alert.addAction(UIAlertAction.init(title: "Отменить", style: .cancel, handler: { _ in
    }))
    self.present(alert, animated: true, completion: nil)
  }
  
}

extension ProfileGalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if  let count = viewModel?.selectedUser?.gallery?.count {
      return count
    } else {
      return presenter.getItems().count
    }
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = galleryCollectionView.dequeueReusableCell(withReuseIdentifier: "galleryPhotoCell", for: indexPath) as! GalleryCollectionViewCell
    let index = indexPath.row
    cell.c.tag = index
    cell.c.isHidden = true
    cell.activityIndicator.startAnimating()
    let item = viewModel?.selectedUser?.gallery?[indexPath.row] != nil ? viewModel?.selectedUser?.gallery?[indexPath.row] : presenter.getItems()[index]
    cell.photoImageView.sd_setImage(with: URL(string: item?.imageUrl ?? ""), placeholderImage: UIImage(named:"Group-1"), options: .allowInvalidSSLCertificates, completed: { (img, err, cashe, url) in
        cell.activityIndicator.stopAnimating()
      })
     

    if let video = item?.video_url, video != "" {
      cell.video.alpha = 1
    } else {
      cell.video.alpha = 0
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: screenSize.width * (123.5/iPhoneXWidth), height: screenSize.height * (123.5/iPhoneXHeight))
    
  }
  
  //  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
  //    return UIEdgeInsets(top: 2, left: screenSize.width * (2.5/iPhoneXWidth), bottom: 2, right: screenSize.width * (2.5/iPhoneXWidth))
  //  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let index = indexPath.row
    let item = viewModel?.selectedUser?.gallery?[indexPath.row] != nil ? viewModel?.selectedUser?.gallery?[indexPath.row] : presenter.getItems()[index]

    if let url = item?.video_url  {
      playVideo(url: url)
    } else {
      if let url = item?.imageUrl {
        UIView.animate(withDuration: 0.5) {
          self.tabBarController?.tabBar.isHidden = true
          if let imgUrl = URL(string: url) {
            let photoSlider = PhotoSlider.ViewController(imageURLs: [imgUrl])
            photoSlider.pageControl.isHidden = true
            self.present(photoSlider, animated: true, completion: nil)
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


extension ProfileGalleryViewController: GalleryDataProtocol {
  func videoLoaded(url: String, and img: UIImage) {
    presenter.setCurrentVideoUrl(url: url)
    presenter.uploadPhoto(image: img)
    DispatchQueue.main.async {
          self.galleryCollectionView.reloadData()
    }
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
    DispatchQueue.main.async {
      self.presenter.getGallery(for: AuthModule.currUser.id)
    }
  }
  
  func startLoading() {
    DispatchQueue.main.async {
      SVProgressHUD.show()
    }
  }
  
  func finishLoading() {
    DispatchQueue.main.async {
      SVProgressHUD.dismiss()
    }
  }
  
  func galleryLoaded() {
    DispatchQueue.main.async {
      self.presenter.updateGalleryItems(items: self.presenter.getItems())
      self.presenter.deleteGalleryBlock(context: self.context)
      self.presenter.saveGallery(context: self.context)
      self.galleryCollectionView.reloadData()
      self.presenter.clear()
      SVProgressHUD.show()
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
