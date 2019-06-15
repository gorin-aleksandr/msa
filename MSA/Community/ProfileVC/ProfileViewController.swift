//
//  ProfileViewController.swift
//  MSA
//
//  Created by Andrey Krit on 8/29/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import SDWebImage
import SVProgressHUD

protocol ProfileViewProtocol: class {
    func updateProfile(with user: UserVO)
    func configureViewBasedOnState(state: PersonState)
    func reloadIconsCollectionView()
    func showDeleteAlert(for user: UserVO)
    func dismiss()
    func showAddAlertFor(user: UserVO, isTrainerEnabled: Bool)
}

class ProfileViewController: BasicViewController, UIPopoverControllerDelegate, UINavigationControllerDelegate, ProfileViewProtocol {
    
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var buttViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imagePreviewView: UIView!
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var containerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var viewWithButtons: UIView!
    @IBOutlet weak var scrollView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!{didSet{activityIndicator.stopAnimating()}}
    @IBOutlet weak var galleryCollectionView: UICollectionView!
    @IBOutlet weak var galleryView: UIView! {didSet{galleryView.layer.cornerRadius = 12}}
    @IBOutlet weak var profileViewbg: UIView! {didSet{profileViewbg.layer.cornerRadius = 10}}
    @IBOutlet weak var userImage: UIView!
    
    @IBOutlet weak var relatedCollectionView: UICollectionView!
    @IBOutlet weak var relatedWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userLevel: UILabel!
    @IBOutlet weak var levelBg: UIImageView!
    @IBOutlet weak var dailyTraining: UILabel!
    @IBOutlet weak var dreamInsideView: UIView! {
        didSet {dreamInsideView.layer.cornerRadius = 12
            dreamInsideView.layer.borderColor = UIColor.msaBlack.withAlphaComponent(0.1).cgColor
            dreamInsideView.layer.borderWidth = 2
        }
        
    }
    @IBOutlet weak var buttonsStackView: UIStackView!
    
    var profilePresenter: ProfilePresenterProtocol!
    
    var customImageViev = ProfileImageView()
    var myPicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        relatedCollectionView.dataSource = self
        relatedCollectionView.delegate = self
        relatedWidthConstraint.constant = CGFloat(((profilePresenter.iconsDataSource.count > 5 ? 5 : profilePresenter.iconsDataSource.count) - 1) * 12 + 32)
        configureButtonsView()
        profilePresenter.start()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureProfileView()
        setNavigationBarTransparent()
        self.tabBarController?.tabBar.isHidden = false
        
        
        //navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func setNavigationBarTransparent() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.view.backgroundColor = .clear
    }
    
    
    func configureButtonsView() {
        let w = CGFloat(self.view.frame.width - 32.0)
        buttViewHeight.constant = CGFloat(20.0 + (w*111.0/164.0))
    }
    
    func setShadow(outerView: UIView, shadowOpacity: Float) {
        outerView.clipsToBounds = false
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOpacity = shadowOpacity
        outerView.layer.shadowOffset = CGSize.zero
        outerView.layer.shadowRadius = 10
        outerView.layer.shadowPath = UIBezierPath(roundedRect: outerView.bounds, cornerRadius: 10).cgPath
    }
    
    func configureProfileView() {
        setShadow(outerView: profileView, shadowOpacity: 0.3)
        setShadow(outerView: viewWithButtons, shadowOpacity: 0.2)
    }
    
    func configureViewBasedOnState(state: PersonState) {
        SVProgressHUD.dismiss()
        if state != .trainersSportsman {
            containerViewHeightConstraint.constant -= viewWithButtons.frame.height
            buttViewHeight.constant = 0
            buttonsStackView.isHidden = true
        }
        if state == .all {
            navigationItem.rightBarButtonItem?.tintColor = .lightBlue
            navigationItem.rightBarButtonItem?.image = #imageLiteral(resourceName: "plus_blue")
        } else {
            navigationItem.rightBarButtonItem?.tintColor = .red
            navigationItem.rightBarButtonItem?.image = #imageLiteral(resourceName: "delete_red")
        }
        navigationItem.leftBarButtonItem?.image = UIImage(named: "back_")
        navigationItem.leftBarButtonItem?.title = "Назад"
    }
    
    func updateProfile(with user: UserVO) {
        if let name = user.firstName, let surname = user.lastName {
            userName.text = name + " " + surname
            cityLabel.text = user.city
        }
        if let level = user.level {
            userLevel.text = level
            userLevel.isHidden = false
            levelBg.isHidden = false
            if level == "" {
                userLevel.isHidden = true
                levelBg.isHidden = true
            }
        } else {
            userLevel.isHidden = true
            levelBg.isHidden = true
        }
        if let dream = user.purpose {
            dailyTraining.text = dream
        }
        setProfileImage(image: nil, url: user.avatar)
        if  user.userType == .trainer {

        }
//        if let trainer = user.trainerId, trainer == AuthModule.currUser.id {
//            configureButtonsView()
//        }
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
        customImageViev.frame = CGRect(x: 0, y: 0, width: 96, height: 120)
        customImageViev.contentMode = .scaleAspectFill
        customImageViev.setNeedsLayout()
        userImage.addSubview(customImageViev)
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 90))
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(openAvatar), for: .touchUpInside)
        self.userImage.addSubview(button)
    }
    
    @objc func openAvatar(sender: UIButton!) {
        if let avatar = profilePresenter.avatar {
            UIView.animate(withDuration: 0.5) { [weak self] in
                self?.imagePreviewView.alpha = 1
                self?.tabBarController?.tabBar.isHidden = true
                self?.navigationController?.navigationBar.isHidden = true
                if let imgUrl = URL(string: avatar) {
                    self?.previewImage.sd_setImage(with: imgUrl, placeholderImage: nil, options: .allowInvalidSSLCertificates, completed: nil)
                }
            }
        }
    }
    
    func showDeleteAlert(for user: UserVO) {
        let alert = UIAlertController(title: nil, message: profilePresenter.state == .userTrainer ? "Вы действительно хотите удалить тренера?" : "Вы дейсвительно хотите удалить из запросов/друзей/спортсменов?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            SVProgressHUD.show()
            self?.profilePresenter.deleteAction(for: user)
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    func showAddAlertFor(user: UserVO, isTrainerEnabled: Bool) {
        let alert = UIAlertController(title: "Добавить в свое сообщество \(user.getFullName())", message: "Вы можете перейти на страницу тренера/друга на вкладке “Сообщество”", preferredStyle: .alert)
        let cancelActionButton = UIAlertAction(title: "Отмена", style: .cancel) { action -> Void in
            print("Cancel")
        }
        let addFriendAction = UIAlertAction(title: "Добавить в список друзей", style: .default, handler: { [weak self] action -> Void in
            SVProgressHUD.show()
            self?.profilePresenter.addToFriends(user: user)
        })
        alert.addAction(cancelActionButton)
        alert.addAction(addFriendAction)
        if isTrainerEnabled {
            let addTrainerAction = UIAlertAction(title: "Добавить в тренеры", style: .default, handler: { [weak self] _ in
                SVProgressHUD.show()
                self?.profilePresenter.addAsTrainer(user: user)
            })
            alert.addAction(addTrainerAction)
        }
        self.present(alert, animated: true)
    }
    
    func dismiss() {
        SVProgressHUD.dismiss()
        self.navigationController?.popViewController(animated: true)
    }
    
    func reloadIconsCollectionView() {
        // MARK: use for future refactoring
        //relatedCollectionView.reloadData()
    }
    
    @IBAction func rightBarButtonTapped(_ sender: Any) {
        profilePresenter.addOrRemoveUserAction()
    }
    
    
    @IBAction func statisticButton(_ sender: Any) {
    }
    @IBAction func infoWeightHeightEct(_ sender: Any) {
    }
    @IBAction func foodButton(_ sender: Any) {
    }
    @IBAction func traningsButton(_ sender: Any) {
        let destinationVC = UIStoryboard(name: "Trannings", bundle: nil).instantiateViewController(withIdentifier: "MyTranningsViewController") as! MyTranningsViewController
        destinationVC.manager.trainingType = .notMine(userId: profilePresenter.userId)
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss()
    }
    @IBAction func closePreview(_ sender: Any) {
        UIView.animate(withDuration: 0.5) { [weak self] in
            self?.imagePreviewView.alpha = 0
            self?.previewImage.image = nil
            self?.tabBarController?.tabBar.isHidden = false
        }
        navigationController?.navigationBar.isHidden = false
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == relatedCollectionView {
            return profilePresenter.iconsDataSource.count > 5 ? 5 : profilePresenter.iconsDataSource.count
        }
        return profilePresenter.gallery.count > 5 ? 5 : profilePresenter.gallery.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == relatedCollectionView {
            let cell = relatedCollectionView.dequeueReusableCell(withReuseIdentifier: "RelatedUserCell", for: indexPath) as! RelatedUserCollectionViewCell
            let imageUrl = profilePresenter.iconsDataSource[indexPath.row]
            if let url = URL(string: imageUrl) {
                cell.photoImageView.sd_setImage(with: url, completed: nil)
            }
            cell.typeImageView.image = profilePresenter.userType == .trainer ?  #imageLiteral(resourceName: "athlet-icon") : #imageLiteral(resourceName: "coach-icon")
            return cell
        }
        
        
        let cell = galleryCollectionView.dequeueReusableCell(withReuseIdentifier: "galleryPhotoCell", for: indexPath) as! GalleryCollectionViewCell
        let index = indexPath.row
        cell.c.isHidden = true
        cell.activityIndicator.startAnimating()
        if let url = profilePresenter.gallery[index].imageUrl {
            cell.photoImageView.sd_setImage(with: URL(string: url)!, placeholderImage: nil, options: .allowInvalidSSLCertificates, completed: { (img, err, cashe, url) in
                cell.activityIndicator.stopAnimating()
            })
        }
        if let video = profilePresenter.gallery[index].video_url, video != "" {
            cell.video.alpha = 1
        } else {
            cell.video.alpha = 0
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == relatedCollectionView {
            return CGSize(width: 32, height: 32)
        }
        return CGSize(width: galleryCollectionView.frame.width/3-10, height: (galleryCollectionView.frame.width/3-3)*140/110);
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == relatedCollectionView { return }
        
        let index = indexPath.row
        if let url = profilePresenter.gallery[index].video_url  {
            playVideo(url: url)
        } else {
            if let url = profilePresenter.gallery[index].imageUrl {
                self.tabBarController?.tabBar.isHidden = true
                self.navigationController?.navigationBar.isHidden = true
                UIView.animate(withDuration: 0.5) {
                    self.imagePreviewView.alpha = 1
                    if let imgUrl = URL(string: url) {
                        self.previewImage.sd_setImage(with: imgUrl, placeholderImage: nil, options: .allowInvalidSSLCertificates, completed: nil)
                    }
                }
            }
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout:
        UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return -18
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
}

//extension ProfileViewController: GalleryDataProtocol {
//
//    func videoLoaded(url: String, and img: UIImage) {
////        presenter.setCurrentVideoUrl(url: url)
////        presenter.uploadPhoto(image: img)
//    }
//
//    func errorOccurred(err: String) {
//
//    }
//
//    func photoUploaded() {
//       // presenter.addItem(item: presenter.getCurrentItem())
//    }
//
//    func startLoading() {
//        DispatchQueue.main.async {
//            self.activityIndicator.startAnimating()
//        }
//    }
//
//    func finishLoading() {
//        DispatchQueue.main.async {
//            self.activityIndicator.stopAnimating()
//        }
//    }
//
//    func galleryLoaded() {
//        DispatchQueue.main.async {
////            self.galleryPresenter.updateGalleryItems(items: self.presenter.getItems())
////            self.galleryPresenter.deleteGalleryBlock(context: self.context)
////            self.galleryPresenter.saveGallery(context: self.context)
////            self.galleryCollectionView.reloadData()
////            self.galleryPresenter.clear()
////            self.activityIndicator.stopAnimating()
////            self.galleryPresenter.clear()
//        }
//    }
//
//    func openImage(image: UIImage) {
//
//    }
//
//}

