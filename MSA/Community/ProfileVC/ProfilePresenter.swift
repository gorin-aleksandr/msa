//
//  ProfileViewPresenter.swift
//  MSA
//
//  Created by Andrey Krit on 8/29/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import Foundation
import CoreData


protocol ProfileGalleryDataPresenterProtocol {
    func attachView(view: GalleryDataProtocol)
    func clear()
    func getItems() -> [GalleryItemVO]
    func getGallery(for userId: String?)
    func setCurrentImgUrl(url: String)
    func setCurrentVideoUrl(url: String)
    func setCurrentVideoPath(path: String)
    func getCurrentItem() -> GalleryItemVO
    func getGallery(context: NSManagedObjectContext)
}

protocol ProfilePresenterProtocol {
    var userId: String? { get }
    var userType: UserType { get }
    var gallery: [GalleryItemVO] { get }
    var avatar: String? { get }
    var state: PersonState { get }
    var iconsDataSource: [String] { get }
    func start()
    func addOrRemoveUserAction()
    func deleteAction(for: UserVO)
    func addToFriends(user: UserVO)
    func addAsTrainer(user: UserVO)
    
}

class ProfilePresenter: ProfilePresenterProtocol {
    
    let user: UserVO
    let dataLoader = UserDataManager()
    
    var iconsDataSource: [String] = [] {
        didSet {
            view?.reloadIconsCollectionView()
        }
    }
    
    var state: PersonState = .all {
        didSet {
            view?.configureViewBasedOnState(state: state)
        }
    }
    
    var currentUser: UserVO {
        return AuthModule.currUser
    }
    var userId: String? {
        return user.id
    }
    var gallery: [GalleryItemVO]  {
        return user.gallery ?? []
    }
    var avatar: String? {
        return user.avatar
    }
    var userType: UserType {
        return user.userType
    }
    var isTrainerEnabled: Bool {
        guard let _ = currentUser.trainerId else {
            return userType == .trainer }
        return false
    }

    
    private weak var view: ProfileViewProtocol?
    
    init(user: UserVO, view: ProfileViewProtocol) {
        self.user = user
        self.view = view
    }
    
    func start() {
        state = getPersonState(person: user)
        view?.updateProfile(with: user)
    }
    
    func addOrRemoveUserAction() {
        switch state {
        case .friend, .trainersSportsman, .userTrainer:
            view?.showDeleteAlert(for: user)
        default:
            view?.showAddAlertFor(user: user, isTrainerEnabled: isTrainerEnabled)
        }
    }
    
    func deleteAction(for user: UserVO) {
        guard let userToRemove = user.id, let id = AuthModule.currUser.id else {return}
        switch state {
        case .friend:
            dataLoader.removeFromFriends(idToRemove: userToRemove, userId: id) { [weak self] (success, error) in
                if error != nil {
                    print("error ocurred")
                } else {
                    if let index = AuthModule.currUser.friends?.index(of: userToRemove) {
                        AuthModule.currUser.friends?.remove(at: index)
                    }
                    self?.view?.dismiss()
                }
            }
        case .userTrainer:
            dataLoader.removeTrainer(with: userToRemove, from: id) { [weak self] (success, error) in
                if error != nil {
                    print("error ocurred")
                } else {
                    self?.dataLoader.removeFromSportsmen(idToRemove: id, userId: userToRemove, callback: { (_, error) in
                        if error != nil {
                            print("error occured")
                        }
                    })
                    AuthModule.currUser.trainerId = nil
                    self?.view?.dismiss()
                }
            }
        case .trainersSportsman:
            dataLoader.removeFromSportsmen(idToRemove: userToRemove, userId: id) { [weak self] (success, error) in
                if error != nil {
                    print("error ocurred")
                } else {
                    self?.dataLoader.removeTrainer(with: userToRemove, from: id, callback: { [weak self] (success, error) in
                        if error != nil {
                            print("error ocurred")
                        }})
                    if let index = AuthModule.currUser.sportsmen?.index(of: userToRemove) {
                        AuthModule.currUser.sportsmen?.remove(at: index)
                    }
                    self?.view?.dismiss()
                }
            }
        case .all:
            print("Critial error")
        }
    }
    
    func addToFriends(user: UserVO) {
        guard let id = user.id, let currentId = currentUser.id else { return }
        dataLoader.addToFriend(with: id) { [weak self] (success, error) in
            if error != nil {
                print((error?.localizedDescription)! +  "unable to add to friends")
            } else {
                self?.removeFromRequests(idToRemove: id, userId: currentId)
                if let currentIsInUserFriends = user.friends?.contains(id), !currentIsInUserFriends {
                    self?.addRequest(idToAdd: currentId, userId: id)
                }
                self?.state = .friend
                AuthModule.currUser.friends?.append(id)
            }
        }
    }
    
    func addAsTrainer(user: UserVO) {
        guard let id = user.id, let currentId = currentUser.id else { return }
        dataLoader.addAsTrainer(with: id) { [weak self] (success, error) in
            if error != nil {
                print((error?.localizedDescription)! +  "unable to add to friends")
            } else {
                self?.removeFromRequests(idToRemove: currentId, userId: id)
                self?.addAsSportsman(idToAdd: currentId, userId: id)
                self?.state = .userTrainer
                AuthModule.currUser.trainerId = id
            }
        }
    }
    
    private func removeFromRequests(idToRemove: String, userId: String) {
        dataLoader.removeFromRequests(idToRemove: idToRemove, userId: userId, callback: { [weak self] (success, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                guard let currentId = self?.currentUser.id, currentId == userId else {return}
                if let index = self?.currentUser.requests?.index(of: idToRemove) {
                    AuthModule.currUser.requests?.remove(at: index)
                }
            }
        })
    }
    
    private func addAsSportsman(idToAdd: String, userId: String) {
        dataLoader.addToSportsmen(idToAdd: idToAdd, userId: userId, callback: { [weak self] (success, error) in
            if error != nil {
                print(error?.localizedDescription)
            }
        })
    }
    
    private func addRequest(idToAdd: String, userId: String) {
        dataLoader.addToRequests(idToAdd: idToAdd, userId: userId, callback: { [weak self] (success, error) in
            if error != nil {
                print(error?.localizedDescription)
            }
        })
    }
    
   private func getPersonState(person: UserVO) -> PersonState {
        guard let personId = person.id else { return PersonState.all}
        if personId == currentUser.trainerId {
            return PersonState.userTrainer
        }
        if let isFriend = currentUser.friends?.contains(personId), isFriend {
            return PersonState.friend
        }
        if let isSportsman = currentUser.sportsmen?.contains(personId), isSportsman {
            return PersonState.trainersSportsman
        }
        return PersonState.all
    }
    
}

