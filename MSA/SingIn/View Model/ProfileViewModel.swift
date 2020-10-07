//
//  ProfileVIewModel.swift
//  MSA
//
//  Created by Nik on 03.09.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import Firebase

enum EditSettingsControllerType {
  case userInfo
  case newAchievement
  case editAchievement
}

enum AchievementType {
  case achieve
  case rank
  case education
  case certificate
}

class ProfileViewModel {
  
  var editSettingsControllerType: EditSettingsControllerType = .userInfo
  var achevementType: AchievementType?
  
  private var dataLoader = UserDataManager()
  
  var selectedUserId = ""
  var selectedUser: UserVO?
  var userSkills: [String] = []
  var selectedAchievements:[(id: String, name: String, rank: String, achieve: String, year: String)] = []
  var selectedEducation:[(id: String, name: String, yearFrom: String, yearTo: String)] = []
  var selectedCertificates:[(id: String, name: String)] = []
  
  var currentAchievement: (id: String, name: String, rank: String, achieve: String, year: String) = (id: "", name: "", rank: "", achieve: "", year: "")
  var currentEducation: (id: String, name: String, yearFrom: String, yearTo: String) = (id: "", name: "", yearFrom: "", yearTo: "")
  var currentCertificates: (id: String, name: String) = (id: "", name: "")
  var skills = ["Бодибилдинг","Фитнес","Реабилитация","Бодифитнес","Фитнес Бикини","Men’s Physique","Силовые тренировки","Коррекция фигуры","Диетология","Функциональный тренинг","ВИТ","Crossfit","Тяжелая атлетика","Пауэрлифтинг","Strongman","Развитие гибкости","Единоборства","Фитнес для беременных"]
  var ranks = ["Заслуженный мастер спорта","Мастер спорта международного класса","Мастер спорта","Кандидат в мастера спорта","1 Взрослый разряд","2 Взрослый разряд","3 Взрослый разряд","1 Юношеский разряд","2 Юношеский разряд","3 Юношеский разряд"]
  var years: [String] = (1970...2020).map { String($0) }.reversed()
  var achieves: [String] = ["1","2","3","4","5","6","7","8","9","10"]
  var achievePlaceholders = ["Вид спорта","Название соревнований","Год","Занятое место"]
  var rankPlaceholders = ["Вид спорта","Звание","Год"]
  var educationPlaceholders = ["Учебное заведение","Год начала обучения","Год выпуска"]
  var certificationPlaceholders = ["Название"]
  
  var profileImages = ["VectorImage","VectorImage","location 1","mail (3) 1","calendar 1"]
  var socialsImages = ["instagram-sketched (2)","facebook (2)","vk (1)"]
  
  var firstName = AuthModule.currUser.firstName
  var lastName = AuthModule.currUser.lastName
  var city = AuthModule.currUser.city
  
  var instaLink = AuthModule.currUser.instagramLink
  var facebookLink = AuthModule.currUser.facebookLink
  var vkLink = AuthModule.currUser.vkLink

  var chatId: String?
  var users: [UserVO] = [] {
    didSet {
      communityDataSource = users
    }
  }
  var reloadSkillsTable: (() -> ())?
  var reloadAchievementsTable: (() -> ())?
  var reloadTable: (() -> ())?
  var communityDataSource = [UserVO]()
  
  init() {  }
  
  func getSelectedUsersChat(completion: @escaping (Bool) -> Void) {
    if let id = selectedUser?.id {
      dataLoader.getSelectedUsersChat(userId: id) { (success,chatId,error) in
        self.chatId = chatId
        completion(true)
      }
    }
  }
  
  func getUserById(completion: @escaping (Bool) -> Void) {
      dataLoader.getUser(userId: self.selectedUserId) { (user, error) in
        if let fetchedUser = user {
          self.selectedUser = fetchedUser
          completion(true)
        } else {
          completion(false)
        }
    }
  }

  func numberOfRowInSectionForDataController(section: Int) -> Int {
    if editSettingsControllerType == .userInfo {
      switch section {
        case 0:
          return 4
        case 1:
          return 3
        default:
          return 0
      }
    } else {
      switch achevementType {
        case .achieve:
          return 4
        case .rank:
          return 3
        case .education:
          return 3
        case .certificate:
          return 1
        default:
          return 4
      }
    }
  }
  
  func placeholderText(index: Int) -> String {
    switch achevementType {
      case .achieve:
        return achievePlaceholders[index]
      case .rank:
        return rankPlaceholders[index]
      case .education:
        return educationPlaceholders[index]
      case .certificate:
        return certificationPlaceholders[index]
      default:
        return ""
    }
  }
  
  func numberOfRowSpecializationDataController(section: Int) -> Int {
    return skills.count
  }
  
  func getUser(success: @escaping ()->()) {
    dataLoader.getUser(callback: { (user, error) in
      if let user = user {
        AuthModule.currUser = user
        success()
      } else {
        success()
      }
      success()
    })
  }
  
  func resetSelectedValues() {
       currentAchievement = (id: "", name: "", rank: "", achieve: "", year: "")
       currentEducation = (id: "", name: "", yearFrom: "", yearTo: "")
       currentCertificates  = (id: "", name: "")
  }
  
  func selectDeselectSpecialization(index: Int) {
    if let index = userSkills.firstIndex(of: skills[index]) {
      userSkills.remove(at: index)
    } else {
      userSkills.append(skills[index])
    }
    
  }
  
  func updateTextValue(text: String, tag: Int, section: Int? = nil) {
    if editSettingsControllerType == .userInfo {
      if section == 0 {
        switch tag {
          case 0:
          firstName = text
          case 1:
          lastName = text
          case 2:
          city = text
          default:
          return
        }
      } else {
        switch tag {
          case 0:
          instaLink = text
          case 1:
          facebookLink = text
          case 2:
          vkLink = text
          default:
          return
        }
      }

    } else {
      switch achevementType {
        case .rank:
          if tag == 0 {
            currentAchievement.name = text
        }
        case .achieve:
          if tag == 0 {
            currentAchievement.name = text
          }
          if tag == 1 {
            currentAchievement.rank = text
        }
        case .education:
          if tag == 0 {
            currentEducation.name = text
        }
        case .certificate:
          if tag == 0 {
            currentCertificates.name = text
        }
        default:
          return
      }
    }

  }
  
  func fetchMySportsmans() {
    dataLoader.loadAllUsers { [weak self] (users, error) in
      if let error = error {
        Errors.handleError(error, completion: { [weak self] message in
          if let _ = error as? MSAError {
            //self?.view.setErrorViewHidden(false)
          } else {
            guard let `self` = self else { return }
            //self.view.showGeneralAlert()
          }
          //self?.view.stopLoadingViewState()
        })
      } else {
        //              self?.users = users.filter { $0.id != self?.currentUser?.id && $0.firstName != "" && $0.lastName != "" }
        //              self?.setCitiesDataSource(from: users)
        //              self?.view.setErrorViewHidden(true)
        //              self?.selectFilter()
        //              self?.view.stopLoadingViewState()
      }
    }
  }
  
  func fetchSpecialization(completion: @escaping (Bool) -> Void) {
    let key = selectedUser?.id != nil ? selectedUser?.id : AuthModule.currUser.id
    dataLoader.userRef.child(key!).child("coachDetail").child("specialization").observeSingleEvent(of: .value, with: { snapshot in
      var specializations:[String] = []
      for child in snapshot.children {
        let snap = child as! DataSnapshot
        let specialization = snap.value as! String
        specializations.append(specialization)
      }
      self.userSkills = specializations
      completion(true)
      print(self.userSkills)
    })
    
  }
  
  func saveSpecialization(completion: @escaping (Bool) -> Void) {
    if let key = AuthModule.currUser.id {
      dataLoader.userRef.child(key).child("coachDetail").child("specialization").setValue(userSkills, andPriority: nil) { (error, ref) in
        if error == nil {
          completion(true)
          self.reloadSkillsTable?()
        } else {
          completion(false)
        }
      }
    }
  }
  
  func fetchAchievements(completion: @escaping (Bool) -> Void) {
    let key = selectedUser?.id != nil ? selectedUser?.id : AuthModule.currUser.id
    
    dataLoader.userRef.child(key ?? "").child("coachDetail").child("achievements").observeSingleEvent(of: .value, with: { snapshot in
      if let dict = snapshot.value as? Dictionary<String, Any> {
        self.selectedAchievements = []
        print(dict)
        for key in dict.keys {
          let item = dict[key] as? Dictionary<String, Any>
          self.selectedAchievements.append((id: key, name: item?["name"] as! String, rank: item?["rank"] as! String, achieve: item?["achievement"] as! String, year: item?["year"] as! String))
        }
        completion(true)
      }else {
        completion(false)
      }
    })
    
  }
  
  
  
  func saveAchievements(completion: @escaping (Bool) -> Void) {
    let achieve:[String: Any] = [
      "name": currentAchievement.name,
      "rank": currentAchievement.rank,
      "year": currentAchievement.year,
      "achievement": currentAchievement.achieve]
    if currentAchievement.id == "" {
      let autoId = Database.database().reference().childByAutoId().key
      if let key = AuthModule.currUser.id {
        dataLoader.userRef.child(key).child("coachDetail").child("achievements").child("\(autoId)").setValue(achieve, andPriority: nil) { (error, ref) in
          if error == nil {
            completion(true)
          } else {
            completion(false)
          }
          self.reloadAchievementsTable?()
        }
      }
    } else {
      if let key = AuthModule.currUser.id {
        dataLoader.userRef.child(key).child("coachDetail").child("achievements").child(currentAchievement.id).updateChildValues(achieve) { (error, ref) in
          if error == nil {
            completion(true)
          } else {
            completion(false)
          }
          self.reloadAchievementsTable?()
        }
      }
    }
    
  }
  
  func removeAchievement(index: Int,completion: @escaping (Bool) -> Void) {
    let achieve = selectedAchievements[index]
    dataLoader.userRef.child(AuthModule.currUser.id!).child("coachDetail").child("achievements").child("\(achieve.id)").setValue(nil, andPriority: nil) { (error, ref) in
      self.selectedAchievements.remove(at: index)
      if error == nil {
        completion(true)
      } else {
        completion(false)
      }
    }
  }
  
  func fetchEducation(completion: @escaping (Bool) -> Void) {
    let key = selectedUser?.id != nil ? selectedUser?.id : AuthModule.currUser.id
    dataLoader.userRef.child(key!).child("coachDetail").child("education").observeSingleEvent(of: .value, with: { snapshot in
      if let dict = snapshot.value as? Dictionary<String, Any> {
        self.selectedEducation = []
        print(dict)
        for key in dict.keys {
          let item = dict[key] as? Dictionary<String, Any>
          self.selectedEducation.append((id: key, name: item?["name"] as! String, yearFrom: item?["yearFrom"] as! String, yearTo: item?["yearTo"] as! String))
        }
        completion(true)
      } else {
        completion(false)
      }
    })
  }
  
  func saveEducation(completion: @escaping (Bool) -> Void) {
    let education:[String: Any] = [
      "name": currentEducation.name,
      "yearFrom": currentEducation.yearFrom,
      "yearTo": currentEducation.yearTo,
    ]
    
    if currentEducation.id == "" {
      let autoId = Database.database().reference().childByAutoId().key
      if let key = AuthModule.currUser.id {
        dataLoader.userRef.child(key).child("coachDetail").child("education").child("\(autoId)").setValue(education, andPriority: nil) { (error, ref) in
          if error == nil {
            completion(true)
          } else {
            completion(false)
          }
          self.reloadAchievementsTable?()
        }
      }
    } else {
      if let key = AuthModule.currUser.id {
        dataLoader.userRef.child(key).child("coachDetail").child("education").child(currentEducation.id).updateChildValues(education) { (error, ref) in
          if error == nil {
            completion(true)
          } else {
            completion(false)
          }
          self.reloadAchievementsTable?()
        }
      }
    }

  }
  
  func removeEducation(index: Int,completion: @escaping (Bool) -> Void) {
    let education = selectedEducation[index]
    if let key = AuthModule.currUser.id {
      dataLoader.userRef.child(key).child("coachDetail").child("education").child("\(education.id)").setValue(nil, andPriority: nil) { (error, ref) in
        self.selectedEducation.remove(at: index)
        if error == nil {
          completion(true)
        } else {
          completion(false)
        }
        
      }
    }
  }
  
  func fetchCertificate(completion: @escaping (Bool) -> Void) {
    let key = selectedUser?.id != nil ? selectedUser?.id : AuthModule.currUser.id
    dataLoader.userRef.child(key!).child("coachDetail").child("certificates").observeSingleEvent(of: .value, with: { snapshot in
      if let dict = snapshot.value as? Dictionary<String, Any> {
        self.selectedCertificates = []
        print(dict)
        for key in dict.keys {
          let item = dict[key] as? Dictionary<String, Any>
          self.selectedCertificates.append((id: key, name: item?["name"] as! String))
        }
        completion(true)
      }else {
        completion(false)
      }
    })
    
  }
  
  func saveCertificate(completion: @escaping (Bool) -> Void) {
    let certificate:[String: Any] = [
      "name": currentCertificates.name,
    ]
    if currentCertificates.id == "" {
      let autoId = Database.database().reference().childByAutoId().key
      if let key = AuthModule.currUser.id {
        dataLoader.userRef.child(key).child("coachDetail").child("certificates").child("\(autoId)").setValue(certificate, andPriority: nil) { (error, ref) in
          if error == nil {
            completion(true)
          } else {
            completion(false)
          }
          self.reloadAchievementsTable?()
        }
      }
    } else {
      if let key = AuthModule.currUser.id {
        dataLoader.userRef.child(key).child("coachDetail").child("certificates").child(currentCertificates.id).updateChildValues(certificate) { (error, ref) in
          if error == nil {
            completion(true)
          } else {
            completion(false)
          }
          self.reloadAchievementsTable?()
        }
      }
    }
    
  }
  
  func removeCertificate(index: Int,completion: @escaping (Bool) -> Void) {
    let certificate = selectedCertificates[index]
    if let key = AuthModule.currUser.id {
      dataLoader.userRef.child(key).child("coachDetail").child("certificates").child("\(certificate.id)").setValue(nil, andPriority: nil) { (error, ref) in
        self.selectedCertificates.remove(at: index)
        if error == nil {
          completion(true)
        } else {
          completion(false)
        }
      }
    }
  }
  
  func updateUserProfile(callback: @escaping (_ created: Bool,_ err: Error?)-> ()) {
    if firstName?.count > 0 {
      AuthModule.currUser.firstName = firstName
    }
    if lastName?.count > 0 {
        AuthModule.currUser.lastName = lastName
      }
    if city?.count > 0 {
        AuthModule.currUser.city = city
    }
    if instaLink?.count > 0 {
          AuthModule.currUser.instagramLink = instaLink
      }
    if facebookLink?.count > 0 {
          AuthModule.currUser.facebookLink = facebookLink
      }
    if vkLink?.count > 0 {
          AuthModule.currUser.vkLink = vkLink
    }
    
    self.dataLoader.updateProfile(AuthModule.currUser) { (updated,error) in
      //self.view?.finishLoading()
      if updated {
       // self.view?.setUser(user: AuthModule.currUser)
        callback(true,nil)
      } else {
        if let err = error?.localizedDescription {
          //self.view?.errorOcurred(err)
          callback(false,error)
        }
      }
    }
  }
  
  func updateUserAvatar(_ image: UIImage,completion: @escaping (UIImage) -> Void,failure: @escaping (String) -> Void) {
    if let id = AuthModule.currUser.id {
      if let data = image.jpegData(compressionQuality: 0.5) {
        // Create a reference to the file you want to upload
        let avatarUpdateRef = dataLoader.storageRef.child("\(id)/avatar.jpg")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        // Upload the file to the path "images/rivers.jpg"
        avatarUpdateRef.putData(data, metadata: metadata) { (metadata, error) in
          guard metadata != nil else {
            if let error = error?.localizedDescription {
              failure(error)
            }
            return
          }
          completion(image)
          
          avatarUpdateRef.downloadURL(completion: { (url, error) in
            self.dataLoader.userRef.child(id).updateChildValues(["userPhoto": url!.absoluteString], withCompletionBlock: { (error, ref) in
              AuthModule.currUser.avatar = url!.absoluteString
              self.getImage()
            })
          })
        }
      }
    }
  }
  
  func getImage() {
    if let id = AuthModule.currUser.id {
      dataLoader.userRef.child(id).observe(.value, with: { (snapshot) in
        // check if user has photo
        if snapshot.hasChild("userPhoto"){
          // set image locatin
          let filePath = "\(id)/avatar.jpg"
          // Assuming a < 10MB file, though you can change that
          self.dataLoader.storageRef.child(filePath).getData(maxSize: 10*1024*1024, completion: { (data, error) in
            //self.view?.finishLoading()
            if let data = data {
              if let userPhoto = UIImage(data: data) {
                //self.view?.setAvatar(image: userPhoto)
              }
            } else {
              if let error = error?.localizedDescription {
                //self.view?.errorOcurred(error)
              }
            }
          })
        }
      })
    }
  }
  
  func editUserCell(indexPath: IndexPath, tableView: UITableView) -> UserDataCell{
    let cell = tableView.dequeueReusableCell(withIdentifier: "UserDataCell") as! UserDataCell
    cell.valueTextField.placeholder = menuCellText(row: indexPath.row)
    cell.selectionStyle = .none
    cell.valueTextField.borderStyle = .none
    cell.contentView.cornerRadius = screenSize.height * (16/screenSize.height)
    cell.valueTextField.font = NewFonts.SFProDisplayRegular16

    if indexPath.section == 0 {
      if let myImage = UIImage(named: profileImages[indexPath.row]){
        cell.valueTextField.withImage(direction: .Left, image: myImage, colorSeparator: UIColor.orange, colorBorder: UIColor.clear)
      }
      switch indexPath.row {
        case 0:
          cell.valueTextField.placeholder = "Имя"
          cell.valueTextField.text = AuthModule.currUser.firstName
        case 1:
          cell.valueTextField.placeholder = "Фамилия"
          cell.valueTextField.text = AuthModule.currUser.lastName
        case 2:
          cell.valueTextField.placeholder = "Город"
          cell.valueTextField.text = AuthModule.currUser.city
        case 3:
          cell.valueTextField.placeholder = "Email"
          cell.valueTextField.text = AuthModule.currUser.email
        default:
          cell.valueTextField.text = ""
      }
    } else {
      if let myImage = UIImage(named: socialsImages[indexPath.row]){
            cell.valueTextField.withImage(direction: .Left, image: myImage, colorSeparator: UIColor.orange, colorBorder: UIColor.clear)
          }
      switch indexPath.row {
        case 0:
          cell.valueTextField.placeholder = "Instagram"
          cell.valueTextField.text = AuthModule.currUser.instagramLink
        case 1:
          cell.valueTextField.placeholder = "Facebook"
          cell.valueTextField.text = AuthModule.currUser.facebookLink
        case 2:
          cell.valueTextField.placeholder = "Вконтакте"
          cell.valueTextField.text = AuthModule.currUser.vkLink
        default:
          cell.valueTextField.text = ""
      }
    }
    cell.valueTextField.cornerRadius = screenSize.height * (16/screenSize.height)
    cell.valueTextField.clipsToBounds = true

    return cell
  }
  
  func specializationCell(indexPath: IndexPath, tableView: UITableView) -> SpecializationCell{
    let cell = tableView.dequeueReusableCell(withIdentifier: "SpecializationCell") as! SpecializationCell
    cell.selectionStyle = .none
    cell.accessoryType = userSkills.contains(skills[indexPath.row]) ? .checkmark : .none
    cell.textLabel?.text = skills[indexPath.row]
    return cell
  }
  
  func editCurrentAchevementUserCell(indexPath: IndexPath, tableView: UITableView) -> UserDataCell{
    let cell = tableView.dequeueReusableCell(withIdentifier: "UserDataCell") as! UserDataCell
    cell.valueTextField.placeholder = menuCellText(row: indexPath.row)
    cell.valueTextField.placeholder = placeholderText(index: indexPath.row)
    cell.selectionStyle = .none
    cell.valueTextField.borderStyle = .none
    cell.contentView.cornerRadius = screenSize.height * (16/screenSize.height)
    cell.valueTextField.font = NewFonts.SFProDisplayRegular16
    cell.valueTextField.withImage(direction: .Left, image: UIImage(), colorSeparator: UIColor.orange, colorBorder: UIColor.clear)
    cell.valueTextField.cornerRadius = screenSize.height * (16/screenSize.height)
    cell.valueTextField.clipsToBounds = true
    
    switch indexPath.row {
      case 0:
        if currentAchievement.name.count > 0 {
          cell.valueTextField.text = currentAchievement.name
        }
        if currentEducation.name.count > 0 {
          cell.valueTextField.text = currentEducation.name
        }
        if currentCertificates.name.count > 0  {
          cell.valueTextField.text = currentCertificates.name
      }
      case 1:
//        if currentAchievement.achieve.count > 0 {
//          cell.valueTextField.text = currentAchievement.achieve
//        }
        if currentAchievement.rank.count > 0 {
           cell.valueTextField.text = currentAchievement.rank
        }
        if currentEducation.yearFrom.count > 0 {
          cell.valueTextField.text = currentEducation.yearFrom
      }
      
      case 2:
        if currentAchievement.year.count > 0 {
          cell.valueTextField.text = currentAchievement.year
        }
        if currentEducation.yearFrom.count > 0 {
          cell.valueTextField.text = currentEducation.yearFrom
      }
      case 3:
        if currentAchievement.achieve.count > 0 {
          cell.valueTextField.text = currentAchievement.achieve
        }

//        if currentAchievement.rank.count > 0 {
//          cell.valueTextField.text = currentAchievement.rank
//        }
        if currentEducation.yearFrom.count > 0 {
          cell.valueTextField.text = currentEducation.yearTo
      }
      default:
        cell.valueTextField.text = AuthModule.currUser.firstName
    }
    return cell
  }
  
  func menuCellText(row: Int) -> String {
    switch row {
      case 0:
        return "Имя"
      case 1:
        return "Фамилия"
      case 2:
        return "Город"
      case 3:
        return "Email"
      default:
        return "Выйти"
    }
  }
  
  func numberOfRowsInSectionForAchevements(section: Int) -> Int{
    
    switch section {
      case 0:
        return selectedUser != nil ? selectedAchievements.count : selectedAchievements.count + 1
      case 1:
        return selectedUser != nil ? selectedEducation.count : selectedEducation.count + 1
      case 2:
        return selectedUser != nil ? selectedCertificates.count : selectedCertificates.count + 1
      default:
        return 0
    }
  }
  
  func heightForRow(indexPath: IndexPath) -> Double{
    switch indexPath.section {
      case 0:
        if indexPath.row == selectedAchievements.count {
          return Double(screenSize.height * (62/iPhoneXHeight))
        }
        return Double(screenSize.height * (74/iPhoneXHeight))
      case 1:
        if indexPath.row == selectedEducation.count {
          return Double(screenSize.height * (62/iPhoneXHeight))
        }
        return Double(screenSize.height * (74/iPhoneXHeight))
      case 2:
        if indexPath.row == selectedCertificates.count {
          return Double(screenSize.height * (62/iPhoneXHeight))
        }
        return Double(screenSize.height * (74/iPhoneXHeight))
      default:
        return 0
    }
  }
  
  func deleteUserBlock(context: NSManagedObjectContext, callback: @escaping (_ logouted: Bool)->()) {
    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
    let request = NSBatchDeleteRequest(fetchRequest: fetch)
    do {
      let _ = try context.execute(request)
      callback(true)
    } catch {
      callback(false)
    }
  }
  
  func clearRealm() {
    let realm = try! Realm()
    try! realm.write {
      realm.deleteAll()
    }
  }
  
}
