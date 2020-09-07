//
//  ProfileGalleryViewController.swift
//  MSA
//
//  Created by Nik on 31.08.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit

class ProfileGalleryViewController: UIViewController {
  @IBOutlet weak var galleryCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      setupUI()
    }
    
  func setupUI() {
    galleryCollectionView.dataSource = self
    galleryCollectionView.delegate = self
  }
  
  func getItems() -> [GalleryItemVO] {
    return AuthModule.currUser.gallery ?? []
  }

}

extension ProfileGalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.getItems().count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = galleryCollectionView.dequeueReusableCell(withReuseIdentifier: "galleryPhotoCell", for: indexPath) as! GalleryCollectionViewCell
    let index = indexPath.row
    cell.c.tag = index
    cell.activityIndicator.startAnimating()
    if let url = self.getItems()[index].imageUrl {
      cell.photoImageView.sd_setImage(with: URL(string: url)!, placeholderImage: nil, options: .allowInvalidSSLCertificates, completed: { (img, err, cashe, url) in
        cell.activityIndicator.stopAnimating()
      })
    }
    if let video = self.getItems()[index].video_url, video != "" {
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
//    let index = indexPath.row
//    if let url = presenter.getItems()[index].video_url  {
//      playVideo(url: url)
//    } else {
//      if let url = presenter.getItems()[index].imageUrl {
//        UIView.animate(withDuration: 0.5) {
//          self.imagePreviewView.alpha = 1
//          self.tabBarController?.tabBar.isHidden = true
//          if let imgUrl = URL(string: url) {
//            self.previewImage.sd_setImage(with: imgUrl, placeholderImage: nil, options: .allowInvalidSSLCertificates, completed: nil)
//          }
//        }
//      }
//      
//    }
  }
  
  
//  func openGallary() {
//    myPicker.allowsEditing = false
//    myPicker.sourceType = UIImagePickerController.SourceType.photoLibrary
//    myPicker.mediaTypes = ["public.image", "public.movie"]
//    present(myPicker, animated: true, completion: nil)
//  }
//  
//  func openCamera() {
//    myPicker.allowsEditing = false
//    myPicker.sourceType = UIImagePickerController.SourceType.camera
//    myPicker.mediaTypes = ["public.image", "public.movie"]
//    present(myPicker, animated: true, completion: nil)
//  }
//  
//  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//    dismiss(animated: true, completion: nil)
//  }
//  
//  //  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//  //  }
//  
//  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//    if galleryUploadInProgress {
//      self.pendingForUpload.append(info)
//    } else {
//      self.uploadInfo(info: info)
//    }
//    dismiss(animated: true, completion: nil)
//  }
//  
//  private func uploadInfo(info: [UIImagePickerController.InfoKey : Any]) {
//    
//    if let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//      self.galleryUploadInProgress = true
//      presenter.uploadPhoto(image: chosenImage)
//    } else if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
//      do {
//        let asset = AVURLAsset(url: videoURL, options: nil)
//        let imgGenerator = AVAssetImageGenerator(asset: asset)
//        imgGenerator.appliesPreferredTrackTransform = true
//        let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
//        let thumbnail = UIImage(cgImage: cgImage)
//        
//        self.galleryUploadInProgress = true
//        
//        presenter.uploadVideo(videoURL.absoluteString, thumbnail)
//        presenter.setCurrentVideoPath(path: videoURL.absoluteString)
//      } catch let error {
//        print("*** Error generating thumbnail: \(error.localizedDescription)")
//      }
//    }
//  }
  
}
