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
  case education
  case certificate
}

class ProfileViewModel {

  var editSettingsControllerType: EditSettingsControllerType = .userInfo
  var achevementType: AchievementType?

  private var dataLoader = UserDataManager()

  var selectedUser: UserVO?
  var userSkills: [String] = []
  var selectedAchievements:[(id: String, name: String, rank: String, achieve: String, year: String)] = []
  var selectedEducation:[(id: String, name: String, yearFrom: String, yearTo: String)] = []
  var selectedCertificates:[(id: String, name: String)] = []
 
  var currentAchievement: (id: String, name: String, rank: String, achieve: String, year: String)?
  var currentEducation: (id: String, name: String, yearFrom: String, yearTo: String)?
  var currentCertificates: (id: String, name: String)?
    var skills = ["Бодибилдинг","Фитнес","Реабилитация","Бодифитнес","Фитнес Бикини","Men’s Physique","Силовые тренировки","Коррекция фигуры","Диетология","Функциональный тренинг","ВИТ","Crossfit","Тяжелая атлетика","Пауэрлифтинг","Strongman","Развитие гибкости","Единоборства","Фитнес для беременных"]
  
  var users: [UserVO] = [] {
      didSet {
          communityDataSource = users
      }
  }
  var reloadSkillsTable: (() -> ())?

  var communityDataSource = [UserVO]()

  init() {  }
  
  func numberOfRowInSectionForDataController(section: Int) -> Int {
    switch achevementType {
      case .achieve:
        return 3
      case .education:
        return 3
      case .certificate:
        return 1
      default:
        return 4
    }
  }
  
  func numberOfRowSpecializationDataController(section: Int) -> Int {
    return skills.count
  }
  
  func getUser(success: @escaping ()->()) {
    UserDataManager().getUser(callback: { (user, error) in
      if let user = user {
        AuthModule.currUser = user
        success()
      } else {
        success()
      }
    })
  }
  
  func selectDeselectSpecialization(index: Int) {
    if let index = userSkills.firstIndex(of: skills[index]) {
      userSkills.remove(at: index)
    } else {
      userSkills.append(skills[index])
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
    
    var key = selectedUser?.id != nil ? selectedUser?.id : AuthModule.currUser.id
    
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
      var key = selectedUser?.id != nil ? selectedUser?.id : AuthModule.currUser.id

      dataLoader.userRef.child(key!).child("coachDetail").child("achievements").observeSingleEvent(of: .value, with: { snapshot in
         if let dict = snapshot.value as? Dictionary<String, Any> {
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
   
   func fetchEducation(completion: @escaping (Bool) -> Void) {
    var key = selectedUser?.id != nil ? selectedUser?.id : AuthModule.currUser.id
      dataLoader.userRef.child(key!).child("coachDetail").child("education").observeSingleEvent(of: .value, with: { snapshot in
         if let dict = snapshot.value as? Dictionary<String, Any> {
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
   
   func fetchCertificate(completion: @escaping (Bool) -> Void) {
     var key = selectedUser?.id != nil ? selectedUser?.id : AuthModule.currUser.id
      dataLoader.userRef.child(key!).child("coachDetail").child("certificates").observeSingleEvent(of: .value, with: { snapshot in
         if let dict = snapshot.value as? Dictionary<String, Any> {
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
  
  func setPurpose(purpose: String, success: @escaping () -> (), failure: @escaping (_ error: String) -> ()) {
    if let id = AuthModule.currUser.id {
      dataLoader.userRef.child(id).updateChildValues(["purpose": purpose], withCompletionBlock: { (error, ref) in
        if let err = error?.localizedDescription {
          failure(err)
        } else {
          AuthModule.currUser.purpose = purpose
          success()
        }
      })
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
     if let myImage = UIImage(named: "VectorImage"){
       cell.valueTextField.withImage(direction: .Left, image: myImage, colorSeparator: UIColor.orange, colorBorder: UIColor.clear)
     }
    switch indexPath.row {
      case 0:
        cell.valueTextField.text = AuthModule.currUser.firstName
      case 1:
        cell.valueTextField.text = AuthModule.currUser.lastName
      case 2:
        cell.valueTextField.text = AuthModule.currUser.city
      case 3:
        cell.valueTextField.text = AuthModule.currUser.email
      default:
        cell.valueTextField.text = AuthModule.currUser.firstName

    }
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
    cell.selectionStyle = .none
    cell.valueTextField.borderStyle = .none
    cell.contentView.cornerRadius = screenSize.height * (16/screenSize.height)
    cell.valueTextField.font = NewFonts.SFProDisplayRegular16
     if let myImage = UIImage(named: "VectorImage"){
       cell.valueTextField.withImage(direction: .Left, image: myImage, colorSeparator: UIColor.orange, colorBorder: UIColor.clear)
     }
    switch indexPath.row {
      case 0:
        if currentAchievement != nil {
          cell.valueTextField.text = currentAchievement?.name
        }
        if currentEducation != nil {
          cell.valueTextField.text = currentEducation?.name
        }
        if currentCertificates != nil {
          cell.valueTextField.text = currentCertificates?.name
      }
      case 1:
        if currentAchievement != nil {
          cell.valueTextField.text = currentAchievement?.achieve
        }
        if currentEducation != nil {
          cell.valueTextField.text = currentEducation?.yearFrom
        }

      case 2:
        if currentAchievement != nil {
          cell.valueTextField.text = currentAchievement?.year
        }
        if currentEducation != nil {
          cell.valueTextField.text = currentEducation?.yearFrom
        }
      case 3:
          if currentAchievement != nil {
            cell.valueTextField.text = currentAchievement?.rank
          }
          if currentEducation != nil {
            cell.valueTextField.text = currentEducation?.yearFrom
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
