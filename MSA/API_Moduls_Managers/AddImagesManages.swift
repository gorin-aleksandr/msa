//
//  ImagePickerManager.swift
//  MSA
//
//  Created by Pavlo Kharambura on 7/2/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import DKImagePickerController

protocol SelectingImagesManager: AnyObject {
    init(presentingViewController viewController: UIViewController & SelectingImagesManagerDelegate)
    func presentImagePicker()
}

protocol SelectingImagesManagerDelegate: AnyObject {
    func maximumImagesCanBePicked() -> Int
    func imagesWasSelecting(images: [Data])
}

class ImageManager: NSObject, SelectingImagesManager {
    
    let presentingViewController: UIViewController & SelectingImagesManagerDelegate
    
    required init(presentingViewController viewController: UIViewController & SelectingImagesManagerDelegate) {
        presentingViewController = viewController
        super.init()
        print("Test")
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
            selectedPhotoController.sourceType = .photo
            selectedPhotoController.assetType = .allPhotos
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
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {return}
        let normalImage = image.scaleAndRotateImage()
        guard let newImage = UIImagePNGRepresentation(normalImage) else {return}
        presentingViewController.imagesWasSelecting(images: [newImage])
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
