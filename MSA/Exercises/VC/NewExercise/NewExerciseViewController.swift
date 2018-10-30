//
//  NewExerciseViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 7/1/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import RealmSwift
import AVKit
import AVFoundation

protocol NewExerciseProtocol: class {
    func startLoading()
    func finishLoading()
    func photoUploaded()
    func videoLoaded(url: String)
    func exerciseCreated()
    func exerciseUpdated()
    func errorOccurred(err: String)
}

class NewExerciseViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! {
        didSet{
            activityIndicator.stopAnimating()
        }
    }
    @IBOutlet weak var greyView: UIView! {
        didSet{
            greyView.isHidden = true
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewWithPicker: UIView!{
        didSet{viewWithPicker.alpha = 0}
    }
    @IBOutlet weak var picker: UIPickerView!
    
    var presentedVC: UIViewController?
    
    var selectedRow = -1
    var id = ""
    var index = 0
    var exercManager = NewExerciseManager.shared
    var presenter: ExersisesTypesPresenter?

    var imageManager: SelectingImagesManager?

    override func viewDidLoad() {
        super.viewDidLoad()

        initialConfigurations()
        configureTableView()
    }

    @IBAction func pickerDoneButton(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.greyView.isHidden = true
            self.viewWithPicker.alpha = 0
        }
        tableView.reloadData()
    }
    
    //MARK: Handle photo selecting
    @objc func handleAddPhoto(_ sender: UIButton) {
        self.view.endEditing(true)
        imageManager?.contentType = .allPhotos
        imageManager?.presentImagePicker()
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
    
    func initialConfigurations() {
        if exercManager.dataSource.editMode {
            id = exercManager.dataSource.newExerciseModel.id
            index = presenter?.getCurrentIndex() ?? 0
        }
        imageManager = ImageManager(presentingViewController: self)
        exercManager.attachView(view: self)
        picker.delegate = self
        setShadow(outerView: viewWithPicker, shadowOpacity: 0.5)
        let attrs = [NSAttributedStringKey.foregroundColor: darkCyanGreen,
                     NSAttributedStringKey.font: UIFont(name: "Rubik-Medium", size: 17)!]
        self.navigationController?.navigationBar.titleTextAttributes = attrs
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(UINib(nibName: "infoTextTableViewCell", bundle: nil), forCellReuseIdentifier: "infoTextTableViewCell")
        self.tableView.register(UINib(nibName: "TextViewViewCounterTableViewCell", bundle: nil), forCellReuseIdentifier: "TextViewViewCounterTableViewCell")
        self.tableView.register(UINib(nibName: "ChoosingItemTableViewCell", bundle: nil), forCellReuseIdentifier: "ChoosingItemTableViewCell")
        self.tableView.register(UINib(nibName: "CreateExerciseTableViewCell", bundle: nil), forCellReuseIdentifier: "CreateExerciseTableViewCell")
        self.tableView.register(UINib(nibName: "AddImagesTableViewCell", bundle: nil), forCellReuseIdentifier: "AddImagesTableViewCell")
        self.tableView.register(UINib(nibName: "LoadVideoTableViewCell", bundle: nil), forCellReuseIdentifier: "LoadVideoTableViewCell")
        self.tableView.register(UINib(nibName: "DeleteExerciseTableViewCell", bundle: nil), forCellReuseIdentifier: "DeleteExerciseTableViewCell")
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorColor = .clear
        tableView.showsVerticalScrollIndicator = false
    }

    @IBAction func back(_ sender: Any) {
        if exercManager.dataSource.editMode {
            exercManager.dataSource.editMode = false
            self.dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func done(_ sender: Any) {
        if exercManager.dataSource.editMode {
            updateExercise()
        } else {
            createExercise()
        }
        exercManager.dataSource.createButtonTapped = true
        tableView.reloadData()
    }
}

extension NewExerciseViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        switch textView.tag {
            case 1:
                exercManager.setName(name: textView.text)
                guard let cell = tableView.cellForRow(at: IndexPath(item: 1, section: 0)) as? TextViewViewCounterTableViewCell else {return}
                cell.numOfSymbuls.text = "\(textView.text.count)"
            case 2:
                exercManager.setDescription(description: textView.text)
                guard let cell = tableView.cellForRow(at: IndexPath(item: 4, section: 0)) as? TextViewViewCounterTableViewCell else {return}
                cell.numOfSymbuls.text = "\(textView.text.count)"
            case 3:
                exercManager.setHowToDo(howToDo: textView.text)
                guard let cell = tableView.cellForRow(at: IndexPath(item: 5, section: 0)) as? TextViewViewCounterTableViewCell else {return}
                cell.numOfSymbuls.text = "\(textView.text.count)"
            default: return
        }
        tableView.endUpdates()
        textView.becomeFirstResponder()
    }
    

    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        switch textView.tag {
            case 1: return numberOfChars < 151
            case 2: return numberOfChars < 601
            case 3: return numberOfChars < 1201
            default: return false
        }
    }
    
}

extension NewExerciseViewController: SelectingImagesManagerDelegate {
    func videoSelectenWith(url: String, image: UIImage) {
        exercManager.dataSource.videoPath = url
        tableView.reloadData()
    }

    func maximumImagesCanBePicked() -> Int {
        return (5 - exercManager.dataSource.pictures.count)
    }
    
    func imagesWasSelecting(images: [Data]) {
        exercManager.dataSource.imagesEdited = true
        exercManager.dataSource.pictures.append(contentsOf: images)
        tableView.reloadData()
    }
}

extension NewExerciseViewController: UITableViewDelegate, UITableViewDataSource {
    
    func configureTextInfo(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoTextTableViewCell", for:  indexPath) as! infoTextTableViewCell
        cell.label.text = "Что бы создать упражнения вам необходимо заполнить все поля и загрузить фото/видео."
        return cell
    }
    func configureTypeCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChoosingItemTableViewCell", for:  indexPath) as! ChoosingItemTableViewCell
        cell.headerLabel.text = "Группа мышц / вид спорта"
        if exercManager.created() && (exercManager.dataSource.typeId == -1){
            cell.errorLabel.isHidden = false
        } else {
            cell.errorLabel.isHidden = true
        }
        cell.elementChoosed.text = "\(RealmManager().getArray(ofType: ExerciseType.self, filterWith: NSPredicate(format: "id = %d", exercManager.dataSource.typeId)).first?.name ?? "-")"
        return cell
    }
    func configureInventarCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChoosingItemTableViewCell", for:  indexPath) as! ChoosingItemTableViewCell
        cell.headerLabel.text = "Инвентарь"
        if exercManager.created() && (exercManager.dataSource.filterId == -1){
            cell.errorLabel.isHidden = false
        } else {
            cell.errorLabel.isHidden = true
        }
        cell.elementChoosed.text = "\(RealmManager().getArray(ofType: ExerciseTypeFilter.self, filterWith: NSPredicate(format: "id = %d", exercManager.dataSource.filterId)).first?.name ?? "-")"
        return cell
    }
    func configureNameCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewViewCounterTableViewCell", for:  indexPath) as! TextViewViewCounterTableViewCell
        cell.HeaderLabel.text = "Название"
        if exercManager.created() && (exercManager.dataSource.name == ""){
            cell.errorLabel.isHidden = false
        } else {
            cell.errorLabel.isHidden = true
        }
        cell.infoTextView.delegate = self
        cell.infoTextView.tag = 1
        cell.infoTextView.text = exercManager.dataSource.name
        cell.maxLenght.text = "150"
        let c = exercManager.dataSource.name.count
        if c == 0 {
            cell.numOfSymbuls.text = ""
        } else {
            cell.numOfSymbuls.text = "\(c)"
        }
        return cell
    }
    func configureDescriptionCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewViewCounterTableViewCell", for:  indexPath) as! TextViewViewCounterTableViewCell
        cell.HeaderLabel.text = "Описание"
//        if exercManager.created() && (exercManager.dataSource.descript == ""){
//            cell.errorLabel.isHidden = false
//        } else {
            cell.errorLabel.isHidden = true
//        }
        cell.infoTextView.delegate = self
        cell.infoTextView.tag = 2
        cell.infoTextView.text = "\(exercManager.dataSource.descript)"
        cell.maxLenght.text = "600"
        let c = exercManager.dataSource.descript.count
        if c == 0 {
            cell.numOfSymbuls.text = ""
        } else {
            cell.numOfSymbuls.text = "\(c)"
        }
        return cell
    }
    func configureTechnicCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewViewCounterTableViewCell", for:  indexPath) as! TextViewViewCounterTableViewCell
        cell.HeaderLabel.text = "Техника"
//        if exercManager.created() && (exercManager.dataSource.howToDo == ""){
//            cell.errorLabel.isHidden = false
//        } else {
            cell.errorLabel.isHidden = true
//        }
        cell.infoTextView.delegate = self
        cell.infoTextView.tag = 3
        cell.infoTextView.text = "\(exercManager.dataSource.howToDo)"
        cell.maxLenght.text = "1200"
        let c = exercManager.dataSource.howToDo.count
        if c == 0 {
            cell.numOfSymbuls.text = ""
        } else {
            cell.numOfSymbuls.text = "\(c)"
        }
        return cell
    }
    
    func configureImagesCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddImagesTableViewCell", for:  indexPath) as! AddImagesTableViewCell
        cell.delegate = self
//        if exercManager.created() && (exercManager.dataSource.pictures.count == 0) {
//            cell.errorLabel.isHidden = false
//            cell.collectionView.isHidden = true
//            cell.errorLabel.text = "Прикрепите изображения!"
//        } else {
            cell.errorLabel.isHidden = true
        if !exercManager.dataSource.pictures.isEmpty {
            cell.collectionView.isHidden = false
        } else {
            cell.collectionView.isHidden = true
        }
//        }
        cell.addPictureButton.addTarget(self, action: #selector(self.handleAddPhoto(_:)), for: .touchUpInside)
        cell.images = exercManager.dataSource.pictures
        cell.photoCounter.text = "\(cell.images.count)"
        return cell
    }
    
    func configureVideoCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LoadVideoTableViewCell", for:  indexPath) as! LoadVideoTableViewCell
//        if exercManager.created() && (exercManager.dataSource.videoPath == "") {
//            cell.errorLabel.isHidden = false
//            cell.errorLabel.text = "Прикрепите видео файл!"
//            cell.img.isHidden = true
//            cell.deleteVideoButt.isHidden = true
//        } else {
            if exercManager.dataSource.videoPath == "" {
                cell.img.isHidden = true
                cell.deleteVideoButt.isHidden = true
            } else {
                cell.img.isHidden = false
                cell.deleteVideoButt.isHidden = false
            }
            cell.errorLabel.isHidden = true
//        }
        cell.deleteVideoButt.addTarget(self, action: #selector(self.deleteVideo(_:)), for: .touchUpInside)
        cell.addVideo.addTarget(self, action: #selector(self.addVideo(_:)), for: .touchUpInside)
        return cell
    }
    
    func configureFinalCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreateExerciseTableViewCell", for:  indexPath) as! CreateExerciseTableViewCell
        return cell
    }
    
    func configureDeleteCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeleteExerciseTableViewCell", for:  indexPath) as! DeleteExerciseTableViewCell
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if exercManager.dataSource.editMode {
            return 10
        } else {
            return 9
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return configureTextInfo(indexPath: indexPath)
        case 1:
            return configureNameCell(indexPath: indexPath)
        case 2:
            return configureTypeCell(indexPath: indexPath)
        case 3:
            return configureInventarCell(indexPath: indexPath)
        case 4:
            return configureDescriptionCell(indexPath: indexPath)
        case 5:
            return configureTechnicCell(indexPath: indexPath)
        case 6:
            return configureImagesCell(indexPath: indexPath)
        case 7:
            return configureVideoCell(indexPath: indexPath)
        case 8:
            return configureFinalCell(indexPath: indexPath)
        case 9:
            return configureDeleteCell(indexPath: indexPath)
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 6:
            if exercManager.dataSource.pictures.isEmpty {
                return 65
            } else {
                return UITableViewAutomaticDimension + 160
            }
        case 7:
            if exercManager.dataSource.videoPath == "" {
                return 65
            } else {
                return UITableViewAutomaticDimension
            }
        case 8, 9:
            return 60
        
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedRow = indexPath.row
        switch selectedRow {
        case 2,3:
            picker.reloadAllComponents()
            UIView.animate(withDuration: 0.3) {
                self.greyView.isHidden = false
                self.viewWithPicker.alpha = 1
            }
        case 8:
            if exercManager.dataSource.editMode {
                updateExercise()
            } else {
                createExercise()
            }
            exercManager.dataSource.createButtonTapped = true
            tableView.reloadData()
        case 9:
            startLoading()
            exercManager.deleteExercise(deleted: {
                self.exerciseDeleted()
            }, failure: {_ in
                self.finishLoading()
                AlertDialog.showAlert("Ошибка удаления", message: "Повторите позже", viewController: self)
            })
        default:
            return
        }
        
    }
    
    func updateExercise() {
        if exercManager.dataSource.name != "" && exercManager.dataSource.filterId != -1 &&  exercManager.dataSource.typeId != -1 {
            exercManager.updateNewExerciseInFirebase()
        } else {
            AlertDialog.showAlert("Ошибка создания", message: "Введите все необходимые данные", viewController: self)
            tableView.reloadData()
        }
    }
    
    func createExercise() {
        if exercManager.dataSource.name != "" && exercManager.dataSource.filterId != -1 &&  exercManager.dataSource.typeId != -1 {
            exercManager.createNewExerciseInFirebase()
        } else {
            AlertDialog.showAlert("Ошибка создания", message: "Введите все необходимые данные", viewController: self)
            tableView.reloadData()
        }
    }
  
}

extension NewExerciseViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if selectedRow == 2 {
            return RealmManager.shared.getArray(ofType: ExerciseType.self).count
        } else if selectedRow == 3 {
            return RealmManager.shared.getArray(ofType: ExerciseTypeFilter.self).count
        } else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if selectedRow == 2 {
            return RealmManager.shared.getArray(ofType: ExerciseType.self)[row].name
        } else if selectedRow == 3 {
            return RealmManager.shared.getArray(ofType: ExerciseTypeFilter.self)[row].name
        } else {
            return "Nothing"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if selectedRow == 2 {
            exercManager.setType(type: RealmManager.shared.getArray(ofType: ExerciseType.self)[row].id)
        } else if selectedRow == 3 {
            exercManager.setFilter(filter: RealmManager.shared.getArray(ofType: ExerciseTypeFilter.self)[row].id)
        }
    }
}

extension NewExerciseViewController: NewExerciseProtocol {
    func exerciseUpdated() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func exerciseDeleted() {
        presenter?.deleteAt(i: index)
        exercManager.dataSource.editMode = false
        if let vc = presentedVC as? ExercisesInfoViewController {
            let index = (vc.navigationController?.viewControllers.count)! - 1
            vc.navigationController?.viewControllers.remove(at: index)
        }
        delay(sec: 1) {
            self.finishLoading()
            self.exerciseUpdated()
        }
    }
    
    func exerciseCreated() {
        navigationController?.popViewController(animated: true)
        NotificationCenter.default.post(name: Notification.Name("Exercise_added"), object: nil, userInfo: nil)
    }
    
    func startLoading() {
        activityIndicator.startAnimating()
        greyView.isHidden = false
    }
    
    func finishLoading() {
        activityIndicator.stopAnimating()
        greyView.isHidden = true
    }

    func photoUploaded() { }
    
    func videoLoaded(url: String) {
        exercManager.setVideo(url: url)
    }
    
    func errorOccurred(err: String) {
        activityIndicator.stopAnimating()
        greyView.isHidden = true
        AlertDialog.showAlert("Ошибка", message: err, viewController: self)
    }
    
}

extension NewExerciseViewController: ImagesProtocol {
    @objc func addVideo(_ sender: UIButton) {
        self.view.endEditing(true)
        imageManager?.contentType = .allVideos
        imageManager?.presentVideoPicker()
    }
    @objc func deleteVideo(_ sender: UIButton) {
        exercManager.deleteVideo()
        tableView.reloadData()
    }
    func deleteImage(at index: Int) {
        exercManager.dataSource.imagesEdited = true
        exercManager.dataSource.pictures.remove(at: index)
        tableView.reloadData()
    }
}
