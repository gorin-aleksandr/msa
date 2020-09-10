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

class ProfileViewModel {

  var editSettingsControllerType: EditSettingsControllerType = .userInfo
  private var dataLoader = UserDataManager()

  var selectedUser: UserVO?
  var userSkills: [String] = []
  var selectedAchievements:[(id: String, name: String, rank: String, achieve: String, year: String)] = []
  var selectedEducation:[(id: String, name: String, yearFrom: String, yearTo: String)] = []
  var selectedCertificates:[(id: String, name: String)] = []

  var users: [UserVO] = [] {
      didSet {
          communityDataSource = users
      }
  }
  
  var communityDataSource = [UserVO]()

  init() {  }
  
  func numberOfRowInSectionForDataController() -> Int {
    return editSettingsControllerType == .userInfo ? 5 : 3
  }
  
  func getUser(success: @escaping ()->()) {
    UserDataManager().getUser(callback: { (user, error) in
      if let user = user {
        AuthModule.currUser = user
        success()
      }
    })
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
     if let key = AuthModule.currUser.id {
      dataLoader.userRef.child(key).child("coachDetail").child("specialization").observeSingleEvent(of: .value, with: { snapshot in
         for child in snapshot.children {
           let snap = child as! DataSnapshot
           let specialization = snap.value as! String
           self.userSkills.append(specialization)
         }
         completion(true)
         print(self.userSkills)
       })
     }
   }
   
  
   
   func fetchAchievements(completion: @escaping (Bool) -> Void) {
     if let key = AuthModule.currUser.id {
      dataLoader.userRef.child(key).child("coachDetail").child("achievements").observeSingleEvent(of: .value, with: { snapshot in
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
   }
   

   
   func fetchEducation(completion: @escaping (Bool) -> Void) {
    if let key = AuthModule.currUser.id {
      dataLoader.userRef.child(key).child("coachDetail").child("education").observeSingleEvent(of: .value, with: { snapshot in
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
   }
   
   func fetchCertificate(completion: @escaping (Bool) -> Void) {
     if let key = AuthModule.currUser.id {
      dataLoader.userRef.child(key).child("coachDetail").child("certificates").observeSingleEvent(of: .value, with: { snapshot in
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
