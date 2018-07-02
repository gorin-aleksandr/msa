//
//  ImagePickerManager.swift
//  MSA
//
//  Created by Pavlo Kharambura on 7/2/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import DKImagePickerController
import AVFoundation

protocol SelectingImagesManager: AnyObject {
    init(presentingViewController viewController: UIViewController & SelectingImagesManagerDelegate)
    func presentImagePicker()
    var contentType: DKImagePickerControllerAssetType { get set }
}

protocol SelectingImagesManagerDelegate: AnyObject {
    func maximumImagesCanBePicked() -> Int
    func imagesWasSelecting(images: [Data])
    func videoSelectenWith(url: String, image: UIImage)
}

class ImageManager: NSObject, SelectingImagesManager {
    
    let presentingViewController: UIViewController & SelectingImagesManagerDelegate
    var contentType: DKImagePickerControllerAssetType = .allAssets
    
    required init(presentingViewController viewController: UIViewController & SelectingImagesManagerDelegate) {
        presentingViewController = viewController
        super.init()
    }
    
    func setContentType(type: DKImagePickerControllerAssetType) {
        contentType = type
    }
    
    func presentImagePicker() {
        guard presentingViewController.maximumImagesCanBePicked() > 0 else {return}
        let actionSheetController = UIAlertController(title: "Please select a source of your photo", message: "Option to select", preferredStyle: .actionSheet)
        let cancelActionButton = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            print("Cancel")
        }
        actionSheetController.addAction(cancelActionButton)
        
        let cameraActionButton = getCameraAlertAction()
        actionSheetController.addAction(cameraActionButton)
        
        let photoLibraryActionButton = getLibraryAlertAction()
        actionSheetController.addAction(photoLibraryActionButton)
        presentingViewController.present(actionSheetController, animated: true, completion: nil)
        
    }
    
    private func getCameraAlertAction() -> UIAlertAction {
        let cameraActionButton = UIAlertAction(title: "Camera", style: .default) { action -> Void in
            let imagePicker = UIImagePickerController()
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .camera
                imagePicker.delegate = self
                self.presentingViewController.present(imagePicker, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "Error", message: "You should enable camera usage for this application in Settings", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
                alertController.addAction(cancelAction)
                let enableAction = UIAlertAction(title: "Enable", style: .default) { action -> Void in
                    guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {return}
                    
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                print("Settings opened: \(success)") // Prints true
                            })
                        }
                    }
                }
                alertController.addAction(enableAction)
                self.presentingViewController.present(alertController, animated: true) {}
            }
        }
        
        return cameraActionButton
    }
    
    private func getLibraryAlertAction() -> UIAlertAction {
        let selectedPhotoController = DKImagePickerController()
        
        let photoLibraryActionButton = UIAlertAction(title: "Photo Library", style: .default) { action -> Void in
            selectedPhotoController.maxSelectableCount = self.presentingViewController.maximumImagesCanBePicked()
            selectedPhotoController.allowMultipleTypes = false
            selectedPhotoController.sourceType = .both
            selectedPhotoController.assetType = self.contentType
            selectedPhotoController.didSelectAssets = { (assets: [DKAsset]) in
                var imageArray: [Data] = []
                if assets.count != 0 {
                    for asset in assets {
                        asset.fetchOriginalImage(true, completeBlock: { image, info in
                            let resizedImage = image?.scaleAndRotateImage()
                            let smallImage = resizedImage?.scaleImage(toSize: CGSize(width: 200, height: 200))
                            let data = UIImagePNGRepresentation(smallImage!) as Data?
                            if let _data = data {
                                let newImage = _data
                                imageArray.append(newImage)
                            }
                        })
                    }
                }
                self.presentingViewController.imagesWasSelecting(images: imageArray)
            }
            self.presentingViewController.present(selectedPhotoController, animated: true) {}
        }
        
        return photoLibraryActionButton
    }
}

extension ImageManager: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if contentType == .allPhotos {
            guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {return}
            let normalImage = image.scaleAndRotateImage()
            guard let newImage = UIImagePNGRepresentation(normalImage) else {return}
            presentingViewController.imagesWasSelecting(images: [newImage])
        } else if contentType == .allVideos {
            if let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
                do {
                    let asset = AVURLAsset(url: videoURL, options: nil)
                    let imgGenerator = AVAssetImageGenerator(asset: asset)
                    imgGenerator.appliesPreferredTrackTransform = true
                    let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
                    let thumbnail = UIImage(cgImage: cgImage)
                    presentingViewController.videoSelectenWith(url: videoURL.absoluteString, image: thumbnail)
                } catch let error {
                    print("*** Error generating thumbnail: \(error.localizedDescription)")
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
