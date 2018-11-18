//
//  MainViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 2/18/18.
//  Copyright © 2018 easyapps.solutions. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import SDWebImage

protocol GalleryDataProtocol: class {
    func startLoading()
    func finishLoading()
    func galleryLoaded()
    func photoUploaded()
    func videoLoaded(url: String,and img: UIImage)
    func playVideo(url: String)
    func openImage(image: UIImage)
    func errorOccurred(err: String)
}

class MainViewController: BasicViewController, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var buttViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imagePreviewView: UIView!
    @IBOutlet weak var previewImage: UIImageView!
    
    @IBOutlet weak var viewWithButtons: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!{didSet{activityIndicator.stopAnimating()}}
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    @IBOutlet weak var galleryView: UIView! {didSet{galleryView.layer.cornerRadius = 10}}
    @IBOutlet weak var profileViewbg: UIView! {didSet{profileViewbg.layer.cornerRadius = 10}}
    @IBOutlet weak var userImage: UIView!
    @IBOutlet weak var coachIcon: UIImageView!
    @IBOutlet weak var trainerImage: UIImageView! {didSet{trainerImage.layer.cornerRadius = 16}}
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userCity: UILabel!
    @IBOutlet weak var userLevel: UILabel!
    @IBOutlet weak var dailyTraining: UILabel!
    @IBOutlet weak var dreamInsideView: UIView! {didSet {dreamInsideView.layer.cornerRadius = 9}}
    @IBOutlet weak var dreamView: UIView! { didSet{dreamView.layer.cornerRadius = 10 }}
    
    private let presenter = GalleryDataPresenter(gallery: GalleryDataManager())
    let p = ExersisesTypesPresenter(exercises: ExersisesDataManager())
    private let editProfilePresenter = EditProfilePresenter(profile: UserDataManager())

    var customImageViev = ProfileImageView()
    var myPicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        downloadData()
        myPicker.delegate = self
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    private func downloadData() {
        downloadExercises()
        configureButtonsView()
        presenter.attachView(view: self)
//        presenter.getGallery(context: context)
        presenter.getGallery(for: AuthModule.currUser.id)
    }
    
    private func downloadExercises() {
        p.getExercisesFromRealm()
        p.getTypesFromRealm()
        p.getFiltersFromRealm()
        p.getMyExercisesFromRealm()
        
        p.getAllExersises()
        p.getAllTypes()
        p.getAllFilters()
        p.getMyExercises()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        downloadExercises()
        configureProfile()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func configureButtonsView() {
        let w = CGFloat(self.view.frame.width - 32.0)
        buttViewHeight.constant = CGFloat(20.0 + (w*111.0/164.0))
    }
    
    func configureProfile() {
        setShadow(outerView: profileView, shadowOpacity: 0.3)
        setShadow(outerView: viewWithButtons, shadowOpacity: 0.2)
        setProfileImage(image: nil, url: AuthModule.currUser.avatar)
        self.coachIcon.isHidden = true
        self.trainerImage.isHidden = true
        if let trainerId = AuthModule.currUser.trainerId {
            editProfilePresenter.getTrainerInfo(trainer: trainerId) { (trainer) in
                if let imageUrl = trainer.avatar, imageUrl != "" {
                    self.coachIcon.isHidden = false
                    self.trainerImage.isHidden = false
                    self.trainerImage.sd_setImage(with: URL(string: imageUrl), placeholderImage: nil, options: .allowInvalidSSLCertificates, completed: nil)
                }
            }
        }
        if let name = AuthModule.currUser.firstName, let surname = AuthModule.currUser.lastName {
            userName.text = name + " " + surname
        }
        if let level = AuthModule.currUser.level {
            userLevel.text = level
        }
        if let city = AuthModule.currUser.city {
            userCity.text = "г. "+city
        }
        if let dream = AuthModule.currUser.purpose {
            dailyTraining.text = dream
        }
    }
    
    func setProfileImage(image: UIImage?, url: String?) {
        for view in userImage.subviews {
            view.removeFromSuperview()
        }
        let indicator = UIActivityIndicatorView()
        indicator.center = userImage.center
        indicator.startAnimating()
        indicator.activityIndicatorViewStyle = .white
        indicator.color = .blue
        userImage.addSubview(indicator)
        
        customImageViev.image = nil
        if let url = url {
            customImageViev.sd_setImage(with: URL(string: url), placeholderImage: nil, options: .allowInvalidSSLCertificates, completed: nil)
        } else {
            customImageViev.image = #imageLiteral(resourceName: "avatarPlaceholder")
        }
        if let image = image {
            customImageViev.image = image
        }
        
        AuthModule.userAvatar = customImageViev.image
        customImageViev.frame = CGRect(x: 0, y: 0, width: 99, height: 123)
        customImageViev.contentMode = .scaleAspectFill
        customImageViev.setNeedsLayout()
        userImage.addSubview(customImageViev)
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 99, height: 123))
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(openAvatar), for: .touchUpInside)
        self.userImage.addSubview(button)
    }
    
    @objc func openAvatar(sender: UIButton!) {
        if let avatar = AuthModule.currUser.avatar {
            UIView.animate(withDuration: 0.5) {
                self.imagePreviewView.alpha = 1
                self.tabBarController?.tabBar.isHidden = true
                if let imgUrl = URL(string: avatar) {
                    self.previewImage.sd_setImage(with: imgUrl, placeholderImage: nil, options: .allowInvalidSSLCertificates, completed: nil)
                }
            }
        }
    }
    
    @IBAction func cameraButon(_ sender: Any) {
        self.openCamera()
    }
    @IBAction func addButton(_ sender: Any) {
        let alert = UIAlertController(title: "Загрузить с:", message: nil, preferredStyle: .actionSheet)
        //        alert.addAction(UIAlertAction(title: "Камеры", style: .default, handler: { _ in
        //        }))
        alert.addAction(UIAlertAction(title: "Галлереи", style: .default, handler: { _ in
            self.openGallary()
        }))
        alert.addAction(UIAlertAction.init(title: "Отменить", style: .cancel, handler: { _ in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func statisticButton(_ sender: Any) {
    }
    @IBAction func infoWeightHeightEct(_ sender: Any) {
    }
    @IBAction func foodButton(_ sender: Any) {
    }
    @IBAction func traningsButton(_ sender: Any) {
    }
    @IBAction func settingsButton(_ sender: Any) {
        print("Settings")
    }
    @IBAction func setPurpose(_ sender: Any) {
    }
    @IBAction func closePreview(_ sender: Any) {
        UIView.animate(withDuration: 0.5) {
            self.imagePreviewView.alpha = 0
            self.previewImage.image = nil
            self.tabBarController?.tabBar.isHidden = false
        }
    }
    @IBAction func deleteItem(_ sender: UIButton) {
        let index = sender.tag
        let alert = UIAlertController(title: "Удаление с галлереи", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Удалить", style: .default, handler: { _ in
            self.presenter.deleteGaleryItem(index: index)
        }))
        alert.addAction(UIAlertAction.init(title: "Отменить", style: .cancel, handler: { _ in
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.getItems().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = galleryCollectionView.dequeueReusableCell(withReuseIdentifier: "galleryPhotoCell", for: indexPath) as! GalleryCollectionViewCell
        let index = indexPath.row
        cell.c.tag = index
        cell.activityIndicator.startAnimating()
        if let url = presenter.getItems()[index].imageUrl {
            cell.photoImageView.sd_setImage(with: URL(string: url)!, placeholderImage: nil, options: .allowInvalidSSLCertificates, completed: { (img, err, cashe, url) in
                cell.activityIndicator.stopAnimating()
            })
        }
        if let video = presenter.getItems()[index].video_url, video != "" {
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
        let index = indexPath.row
        if let url = presenter.getItems()[index].video_url  {
            playVideo(url: url)
        } else {
            if let url = presenter.getItems()[index].imageUrl {
                UIView.animate(withDuration: 0.5) {
                    self.imagePreviewView.alpha = 1
                    self.tabBarController?.tabBar.isHidden = true
                    if let imgUrl = URL(string: url) {
                        self.previewImage.sd_setImage(with: imgUrl, placeholderImage: nil, options: .allowInvalidSSLCertificates, completed: nil)
                    }
                }
            }
            
        }
    }
    
    
    func openGallary() {
        myPicker.allowsEditing = false
        myPicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        myPicker.mediaTypes = ["public.image", "public.movie"]
        present(myPicker, animated: true, completion: nil)
    }
    
    func openCamera() {
        myPicker.allowsEditing = false
        myPicker.sourceType = UIImagePickerControllerSourceType.camera
        myPicker.mediaTypes = ["public.image", "public.movie"]
        present(myPicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            dismiss(animated: true, completion: nil)
            presenter.uploadPhoto(image: chosenImage)
        } else if let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
            do {
                let asset = AVURLAsset(url: videoURL, options: nil)
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                imgGenerator.appliesPreferredTrackTransform = true
                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                presenter.uploadVideo(videoURL.absoluteString, thumbnail)
                presenter.setCurrentVideoPath(path: videoURL.absoluteString)
            } catch let error {
                print("*** Error generating thumbnail: \(error.localizedDescription)")
            }
            dismiss(animated: true, completion: nil)
        }
    }
    
}

extension MainViewController: GalleryDataProtocol {
    func videoLoaded(url: String, and img: UIImage) {
        presenter.setCurrentVideoUrl(url: url)
        presenter.uploadPhoto(image: img)
    }
    
    func errorOccurred(err: String) {
        
    }
    
    func photoUploaded() {
        presenter.addItem(item: presenter.getCurrentItem())
    }
    
    func startLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
    }
    
    func finishLoading() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }
    
    func galleryLoaded() {
        DispatchQueue.main.async {
            self.presenter.updateGalleryItems(items: self.presenter.getItems())
            self.presenter.deleteGalleryBlock(context: self.context)
            self.presenter.saveGallery(context: self.context)
            self.galleryCollectionView.reloadData()
            self.presenter.clear()
            self.activityIndicator.stopAnimating()
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
