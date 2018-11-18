
//
//  EditProfileViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 4/4/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import SDWebImage

protocol EditProfileProtocol: class {
    func startLoading()
    func finishLoading()
    func errorOcurred(_ error: String)
    func setUser(user: UserVO)
    func setNoUser()
    func setAvatar(image: UIImage)
    func purposeSetted()
}

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UINavigationControllerDelegate  {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var findTrainerView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {didSet{activityIndicator.stopAnimating()}}
    @IBOutlet weak var profilePhoto: UIView!
    @IBOutlet weak var changeImageButton: UIButton! {didSet{changeImageButton.imageView?.contentMode = .scaleAspectFit}}
    
    @IBOutlet weak var loadingTrainerView: UIView!
    @IBOutlet weak var trainerImageIndicator: UIActivityIndicatorView!
    @IBOutlet weak var trainerStackView: UIStackView!
    @IBOutlet weak var trainername: UILabel!
    @IBOutlet weak var trainerImage: UIImageView! {didSet{trainerImage.layer.cornerRadius = 25}}
    
    @IBOutlet weak var userNametextField: SkyFloatingLabelTextField!
    @IBOutlet weak var userSurnameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var sportsmanTypeImage: UIImageView! {didSet {setShadow(outerView: sportsmanTypeImage)}}
    @IBOutlet weak var trainerTypeImage: UIImageView! {didSet {setShadow(outerView: trainerTypeImage)}}
    
    @IBOutlet weak var smImage: UIImageView! {didSet {setShadow(outerView: smImage)}}
    @IBOutlet weak var ftImage: UIImageView! {didSet {setShadow(outerView: ftImage)}}
    @IBOutlet weak var kgImage: UIImageView! {didSet {setShadow(outerView: kgImage)}}
    @IBOutlet weak var pdImage: UIImageView! {didSet {setShadow(outerView: pdImage)}}
    
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var sexLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var cityTF: SkyFloatingLabelTextField!
    
    @IBOutlet weak var pickerView: UIPickerView! {didSet{pickerView.alpha = 0}}
    
    @IBOutlet weak var approveEmail: UIButton! {
        didSet {
            approveEmail.layer.cornerRadius = 15
            approveEmail.backgroundColor = .clear
            approveEmail.layer.borderWidth = 1
            approveEmail.layer.borderColor = darkCyanGreen.cgColor
            approveEmail.titleLabel?.numberOfLines = 1
            approveEmail.titleLabel?.adjustsFontSizeToFitWidth = true
        }
    }
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var changePass: UIButton! {
        didSet {
            changePass.layer.cornerRadius = 15
            changePass.titleLabel?.numberOfLines = 1
            changePass.titleLabel?.adjustsFontSizeToFitWidth = true
        }
    }
    
    private let presenter = EditProfilePresenter(profile: UserDataManager())
    
    var myPicker = UIImagePickerController()
    private var dataType: PickerDataType!

    override func viewDidLoad() {
        super.viewDidLoad()

        myPicker.delegate = self
        
        configureNavigationItem()
        presenter.attachView(view: self)
        // Do any additional setup after loading the view.
    }
    
    func setShadow(outerView: UIView) {
        outerView.clipsToBounds = false
        outerView.layer.shadowColor = UIColor.black.cgColor
        outerView.layer.shadowOpacity = 0.2
        outerView.layer.shadowOffset = CGSize.zero
        outerView.layer.shadowRadius = 2
        outerView.layer.shadowPath = UIBezierPath(roundedRect: outerView.bounds, cornerRadius: 10).cgPath
    }
    
    func configereProfile() {
        let user = AuthModule.currUser
        setProfileImage(image: #imageLiteral(resourceName: "avatarPlaceholder"), url: nil)
        setTrainerInfo(of: user)
        if let url = user.avatar {
            setProfileImage(image: nil, url: url)
        }
        if let name = user.firstName, let surname = user.lastName {
            userNametextField.text = name
            userSurnameTextField.text = surname
        }
        if let email = user.email {
            emailTextField.text = email
        }
        if let city = user.city {
            cityTF.text = city
        }
        if user.type == "СПОРТСМЕН" {
            sportsmanTypeImage.image = #imageLiteral(resourceName: "selected")
            trainerTypeImage.image = #imageLiteral(resourceName: "notSelected")
        } else {
            sportsmanTypeImage.image = #imageLiteral(resourceName: "notSelected")
            trainerTypeImage.image = #imageLiteral(resourceName: "selected")
        }
        if let age = user.age {
            ageLabel.text = "\(age)"
        }
        if let sex = user.sex {
            sexLabel.text = sex
        }
        if let height = user.height {
            heightLabel.text = "\(height)"
        }
        if let weight = user.weight {
            weightLabel.text = "\(weight)"
        }
        if let level = user.level {
            levelLabel.text = level
        }
        if user.heightType == "sm" {
            smImage.image = #imageLiteral(resourceName: "selected")
            ftImage.image = #imageLiteral(resourceName: "notSelected")
            presenter.setHeightType(type: .sm)
        } else {
            smImage.image = #imageLiteral(resourceName: "notSelected")
            ftImage.image = #imageLiteral(resourceName: "selected")
            presenter.setHeightType(type: .ft)
        }
        if user.weightType == "kg" {
            kgImage.image = #imageLiteral(resourceName: "selected")
            pdImage.image = #imageLiteral(resourceName: "notSelected")
            presenter.setWeightType(type: .kg)
        } else {
            kgImage.image = #imageLiteral(resourceName: "notSelected")
            pdImage.image = #imageLiteral(resourceName: "selected")
            presenter.setWeightType(type: .pd)
        }
        
    }
    
    private func setTrainerInfo(of user: UserVO) {
        if user.userType == .trainer {
            trainerStackView.isHidden = true
            return
        }
        guard let trainerId = user.trainerId, trainerId != "" else {
            findTrainerView.isHidden = false
            return
        }
        
        loadingTrainerView.isHidden = false
        findTrainerView.isHidden = true
        presenter.getTrainerInfo(trainer: trainerId) { (user) in
            self.loadingTrainerView.isHidden = true
            self.trainername.text = (user.firstName ?? "") + " " + (user.lastName ?? "")
            guard let avatar = user.avatar else {return}
            self.trainerImage.sd_setImage(with: URL(string: avatar), placeholderImage: nil, options: .allowInvalidSSLCertificates, completed: nil)
        }
    }
    
    func openGallary() {
        myPicker.allowsEditing = true
        myPicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(myPicker, animated: true, completion: nil)
    }
    
    func openCamera() {
        myPicker.allowsEditing = true
        myPicker.sourceType = UIImagePickerControllerSourceType.camera
        present(myPicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        finishLoading()
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerEditedImage] as! UIImage
        dismiss(animated: true, completion: nil)
        presenter.updateUserAvatar(chosenImage)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configereProfile()
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func configureNavigationItem() {
        let button1 = UIBarButtonItem(image: #imageLiteral(resourceName: "ok_blue"), style: .plain, target: self, action: #selector(self.save))
        let button2 = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(self.back))
        button2.tintColor = darkCyanGreen
        self.navigationItem.leftBarButtonItem = button2
        self.navigationItem.rightBarButtonItem = button1
        self.navigationItem.title = "Настройки"
        let attrs = [NSAttributedStringKey.foregroundColor: darkCyanGreen,
                     NSAttributedStringKey.font: UIFont(name: "Rubik-Medium", size: 17)!]
        self.navigationController?.navigationBar.titleTextAttributes = attrs
    }
    
    func setProfileImage(image: UIImage?, url: String?) {
        let customImageViev = ProfileImageView()
        if let url = url {
            customImageViev.sd_setImage(with: URL(string: url), placeholderImage: #imageLiteral(resourceName: "avatarPlaceholder"), options: .allowInvalidSSLCertificates, completed: nil)
        } else {
            customImageViev.image = #imageLiteral(resourceName: "avatarPlaceholder")
        }
        if let image = image {
            customImageViev.image = image
        }
        AuthModule.userAvatar = customImageViev.image
        customImageViev.frame = CGRect(x: 0, y: 0, width: 115, height: 145)
        customImageViev.setNeedsLayout()
        customImageViev.contentMode = .scaleAspectFill
        profilePhoto.addSubview(customImageViev)
    }
    
    @objc func save() {
        if let name = userNametextField.text {
            presenter.setName(name: name)
        }
        if let surname = userSurnameTextField.text {
            presenter.setSurname(surname: surname)
        }
        if let email = AuthModule.currUser.email {
            presenter.setEmail(email: email)
        }
        if let city = cityTF.text {
            presenter.setCity(city: city)
        }
        presenter.updateUserProfile(AuthModule.currUser)
    }
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func changeProfilePhotoButton(_ sender: Any) {
        let alert = UIAlertController(title: "Загрузить с:", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Камеры", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Галлереи", style: .default, handler: { _ in
            self.openGallary()
        }))
        alert.addAction(UIAlertAction.init(title: "Отменить", style: .cancel, handler: { _ in
            self.finishLoading()
        }))
        self.present(alert, animated: true, completion: nil)
        startLoading()
    }
    
    @IBAction func deleteTrainer(_ sender: Any) {
        guard let trainerId = AuthModule.currUser.trainerId, trainerId != "" else {
            return
        }
        startLoading()
        presenter.deleteTrainer(trainerId, deleted: {
            self.finishLoading()
            findTrainerView.isHidden = false
            AlertDialog.showAlert("Удаление прошло успешно!", message: "У вас теперь нету тренера.", viewController: self)
        }) {
            self.finishLoading()
            AlertDialog.showAlert("Ошибка удаления!", message: "Повторите еще раз.", viewController: self)
        }
    }
    @IBAction func findTrainer(_ sender: Any) {
        self.tabBarController?.selectedIndex = 2
    }
    @IBAction func setSportsmanType(_ sender: Any) {
        presenter.setType(type: .sport)
        sportsmanTypeImage.image = #imageLiteral(resourceName: "selected")
        trainerTypeImage.image = #imageLiteral(resourceName: "notSelected")
    }
    @IBAction func setTrainerType(_ sender: Any) {
        presenter.setType(type: .trainer)
        sportsmanTypeImage.image = #imageLiteral(resourceName: "notSelected")
        trainerTypeImage.image = #imageLiteral(resourceName: "selected")
    }
    @IBAction func setAge(_ sender: Any) {
        dataType = PickerDataType.Age
        openPicker()
    }
    @IBAction func setSex(_ sender: Any) {
        dataType = PickerDataType.Sex
        openPicker()
    }
    @IBAction func setHeight(_ sender: Any) {
        dataType = PickerDataType.Height
        openPicker()
    }
    @IBAction func setWeight(_ sender: Any) {
        dataType = PickerDataType.Weight
        openPicker()
    }
    @IBAction func setLevel(_ sender: Any) {
        dataType = PickerDataType.Level
        openPicker()
    }
    @IBAction func setSantimeters(_ sender: Any) {
        smImage.image = #imageLiteral(resourceName: "selected")
        ftImage.image = #imageLiteral(resourceName: "notSelected")
        presenter.setHeightType(type: .sm)
    }
    @IBAction func setFt(_ sender: Any) {
        smImage.image = #imageLiteral(resourceName: "notSelected")
        ftImage.image = #imageLiteral(resourceName: "selected")
        presenter.setHeightType(type: .ft)
    }
    @IBAction func setKg(_ sender: Any) {
        kgImage.image = #imageLiteral(resourceName: "selected")
        pdImage.image = #imageLiteral(resourceName: "notSelected")
        presenter.setWeightType(type: .kg)
    }
    @IBAction func setPd(_ sender: Any) {
        kgImage.image = #imageLiteral(resourceName: "notSelected")
        pdImage.image = #imageLiteral(resourceName: "selected")
        presenter.setWeightType(type: .pd)
    }
    
    @IBAction func help(_ sender: Any) {
    }
    @IBAction func rules(_ sender: Any) {
    }
    @IBAction func logout(_ sender: Any) {
        presenter.deleteUserBlock(context: context) { (loggedOut) in
        self.presenter.clearRealm()
        if loggedOut {
                let storyBoard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MainNVC") as! UINavigationController
                self.navigationController?.show(nextViewController, sender: self)
                AuthModule.currUser.id = nil
                
            } else {
                AlertDialog.showAlert("Ошибка", message: "Ошибка логаута", viewController: self)
            }
        }
        
    }
    @IBAction func hideTrainerView(_ sender: Any) {

    }
    
}

extension EditProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if dataType == PickerDataType.Age {
            return presenter.getAges().count
        } else if dataType == PickerDataType.Sex {
            return presenter.getSexes().count
        } else if dataType == PickerDataType.Height {
            return presenter.getHeight().count
        } else if dataType == PickerDataType.Weight {
            return presenter.getWeight().count
        } else {
            return presenter.getlevels().count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if dataType == PickerDataType.Age {
            return "\(presenter.getAges()[row])"
        } else if dataType == PickerDataType.Sex {
            return presenter.getSexes()[row]
        } else if dataType == PickerDataType.Height {
            return "\(presenter.getHeight()[row])"
        } else if dataType == PickerDataType.Weight {
            return "\(presenter.getWeight()[row])"
        } else {
            return presenter.getlevels()[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if dataType == PickerDataType.Age {
            ageLabel.text = "\(presenter.getAges()[row])"
            presenter.setAge(age: Int(ageLabel.text!)!)
        } else if dataType == PickerDataType.Sex {
            sexLabel.text = presenter.getSexes()[row]
            presenter.setSex(sex: sexLabel.text!)
        } else if dataType == PickerDataType.Height {
            heightLabel.text = "\(presenter.getHeight()[row])"
            presenter.setHeight(height: Int(heightLabel.text!)!)
        } else if dataType == PickerDataType.Weight {
            weightLabel.text = "\(presenter.getWeight()[row])"
            presenter.setWeight(weight: Int(weightLabel.text!)!)
        } else {
            levelLabel.text = presenter.getlevels()[row]
            presenter.setLevel(level: levelLabel.text!)
        }
        closePicker()
    }
    
    func openPicker() {
        pickerView.reloadAllComponents()
        pickerView.alpha = 1
    }
    
    func closePicker() {
        pickerView.alpha = 0
    }
    
}

extension EditProfileViewController: EditProfileProtocol {
    
    func errorOcurred(_ error: String) {
        DispatchQueue.main.async {
            AlertDialog.showAlert("Ошибка", message: error, viewController: self)
        }
    }
   
    func setAvatar(image: UIImage) {
        DispatchQueue.main.async {
            self.setProfileImage(image: image, url: nil)
            self.presenter.setUser(user: AuthModule.currUser, context: self.context)
        }
    }
    
    func startLoading() {
        self.view.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
    }
    
    func finishLoading() {
        self.view.isUserInteractionEnabled = true
        activityIndicator.stopAnimating()
    }
    
    func setUser(user: UserVO) {
        presenter.setUser(user: user, context: context)
        navigationController?.popViewController(animated: true)
    }
    func setNoUser() {
        presenter.setNoUser()
    }
    func purposeSetted() {}

    
}
