//
//  CommunityDetailsPresenter.swift
//  MSA
//
//  Created by Andrey Krit on 8/22/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

enum UserCommunityState {
    case requests, friends, trainers, sportsmen
}

import Foundation

protocol UserCommunityPresenterProtocol {
    var userCommunityDataSource: [UserVO] { get }
    var isTrainer: Bool { get }
    func start()
    func setDataSource(with searchText: String?, and selectedState: Int)
    func acceptRequest(atIndex: Int)
    var state: UserCommunityState { get }
    func deleteButtonTapped(atIndex: Int)
    func deleteAction(for user: UserVO)
    func createProfilePresenter(user: UserVO, for view: ProfileViewProtocol) -> ProfilePresenterProtocol
    func refresh()
}


class UserCommunityPresenter: UserCommunityPresenterProtocol {

    private unowned var view: UserCommunityViewProtocol
    
    var state: UserCommunityState = .requests
    var isTrainer: Bool {
        return AuthModule.currUser.userType == .trainer
    }
    
    private var users = [UserVO]()
    private var searchText: String?
    var userCommunityDataSource = [UserVO]() {
        didSet {
            view.reloadData()
        }
    }
    
    let dataLoader = UserDataManager() 
    
    init(view: UserCommunityViewProtocol, loadedUsers: [UserVO]) {
        self.view = view
        self.users = loadedUsers
    }
    
    func start() {
        setRequestDataSource()
    }
    
    private func searchBy(string: String?) {
        searchText = string
        guard let text = searchText, !text.isEmpty else {
            
            return}
        userCommunityDataSource = userCommunityDataSource
                                    .filter {$0.getFullName().lowercased().contains(text.lowercased())}
                                    .sorted { $0.getFullName() < $1.getFullName() }
    }
    
    private func setFriendsDataSource() {
        state = .friends
        var friends = [UserVO]()
        guard let friendsArray = AuthModule.currUser.friends else {
             userCommunityDataSource = []
            return}
        for friendId in friendsArray {
            let friend = users.first {$0.id == friendId}
            if let friend = friend {
                friends.append(friend)
            }
        }
        userCommunityDataSource = friends.sorted { $0.getFullName() < $1.getFullName() }
    }
    
    private func setRequestDataSource() {
        state = .requests
        var requests = [UserVO]()
        guard let requestsArray = AuthModule.currUser.requests else {
            userCommunityDataSource = []
            return}
        for requestId in requestsArray {
            let request = users.first {$0.id == requestId}
            if let request = request {
                requests.append(request)
            }
        }
        userCommunityDataSource = requests.sorted { $0.getFullName() < $1.getFullName() }
    }
    
    private func setTrainerDataSource() {
        state = .trainers
        var trainers = [UserVO]()
        guard let trainerId = AuthModule.currUser.trainerId else {
            userCommunityDataSource = []
            return
        }
            let trainer = users.first {$0.id == trainerId}
            if let trainer = trainer {
                trainers.append(trainer)
            }
        userCommunityDataSource = trainers.sorted { $0.getFullName() < $1.getFullName() }
    }
    
    private func setSportsmenDataSource() {
        state = .sportsmen
        var sportsmen = [UserVO]()
        guard let sportsmenArray = AuthModule.currUser.sportsmen else {
            userCommunityDataSource = []
            return}
        for sportsmanId in sportsmenArray {
            let sportsman = users.first {$0.id == sportsmanId}
            if let sportsman = sportsman {
                sportsmen.append(sportsman)
            }
        }
        userCommunityDataSource = sportsmen.sorted { $0.getFullName() < $1.getFullName() }
    }
    
    func refresh() {
        dataLoader.getUser { [weak self] (user, error) in
            if error != nil {
                Errors.handleError(error, completion: { message in
                    print(message)
                })
            } else {
                guard let user = user  else {return}
                AuthModule.currUser = user
                    self?.setDatasourceFor(self?.state ?? .requests)

            }
        }
    }
    
    private func setDatasourceFor(_ state: UserCommunityState) {
        switch state {
        case .friends:
            setFriendsDataSource()
        case .sportsmen:
            setSportsmenDataSource()
        case .trainers:
            setTrainerDataSource()
        case .requests:
            setRequestDataSource()
        }
        searchBy(string: searchText)
    }
    
    func setDataSource(with searchText: String?, and selectedState: Int) {
        switch selectedState {
        case 0:
            setRequestDataSource()
        case 1:
            setFriendsDataSource()
        case 2:
            setTrainerDataSource()
        default:
            setSportsmenDataSource()
        }
        searchBy(string: searchText)
        view.reloadData()
    }
    
    func acceptRequest(atIndex: Int) {
        guard let friendId = userCommunityDataSource[atIndex].id, let id = AuthModule.currUser.id else {
            print("fatal error")
            return
        }
        dataLoader.addToFriend(with: friendId) { [weak self] (succes, error) in
            if error != nil {
                print("error ocerred while adding to friends")
            } else {
                if let index = AuthModule.currUser.requests?.index(of: friendId) {
                    AuthModule.currUser.requests?.remove(at: index)
                    AuthModule.currUser.friends?.append(friendId)
                }
                self?.setRequestDataSource()
                self?.view.reloadData()
                self?.dataLoader.removeFromRequests(idToRemove: friendId, userId: id
                    , callback: { (succes, error) in
                    if error != nil {
                        print("Error occured while removing from friends")
                    }
                })
            }
        }
    }
    
    func createProfilePresenter(user: UserVO, for view: ProfileViewProtocol) -> ProfilePresenterProtocol {
        let presenter = ProfilePresenter(user: user, view: view)
        presenter.iconsDataSource = preparedIconsForProfile(for: user)
        return presenter
    }
    
    private func preparedIconsForProfile(for user: UserVO) -> [String] {
        switch user.userType {
        case .sportsman:
            guard let userTainerId = user.trainerId, let trainer = users.first(where: { $0.id == userTainerId }), let photo = trainer.avatar  else  { return [] }
            return [photo]
        case .trainer:
            guard let sporsmenIds = user.sportsmen else { return [] }
            var trainerSportsmen = [UserVO]()
            for id in sporsmenIds {
                if let sportsman = users.first(where: {$0.id == id }) {
                    trainerSportsmen.append(sportsman)
                }
            }
            let photos = trainerSportsmen.compactMap { $0.avatar }
            return photos
        }
    }
    
    func deleteButtonTapped(atIndex: Int) {
        view.showAlert(for: userCommunityDataSource[atIndex])
    }
    
    func deleteAction(for user: UserVO) {
        guard let userToRemove = user.id, let id = AuthModule.currUser.id else {return}
        switch state {
        case .requests:
            dataLoader.removeFromRequests(idToRemove: userToRemove, userId: id) { [weak self] (success, error) in
                if error != nil {
                    print("error ocurred")
                } else {
                    if let index = AuthModule.currUser.friends?.index(of: userToRemove) {
                        AuthModule.currUser.requests?.remove(at: index)
                    }
                    self?.setRequestDataSource()
                    self?.view.reloadData()
                }
            }
        case .friends:
            dataLoader.removeFromFriends(idToRemove: userToRemove, userId: id) { [weak self] (success, error) in
                if error != nil {
                    print("error ocurred")
                } else {
                    if let index = AuthModule.currUser.friends?.index(of: userToRemove) {
                        AuthModule.currUser.friends?.remove(at: index)
                    }
                    self?.setFriendsDataSource()
                    self?.view.reloadData()
                }
            }
        case .trainers:
            dataLoader.removeTrainer(with: userToRemove, from: id) { [weak self] (success, error) in
                if error != nil {
                    print("error ocurred")
                } else {
                    self?.dataLoader.removeFromSportsmen(idToRemove: id, userId: userToRemove, callback: { (_, error) in
                        if error != nil {
                            print("Error occured")
                        }
                    })
                    AuthModule.currUser.trainerId = nil
                    self?.setTrainerDataSource()
                    self?.view.reloadData()
                }
            }
        case .sportsmen:
            dataLoader.removeFromSportsmen(idToRemove: userToRemove, userId: id) { [weak self] (success, error) in
                if error != nil {
                    print("error ocurred")
                } else {
                    self?.dataLoader.removeTrainer(with: id, from: userToRemove, callback: { (_, error) in
                        if error != nil {
                            print("error occured")
                        }
                    })
                    if let index = AuthModule.currUser.sportsmen?.index(of: userToRemove) {
                        AuthModule.currUser.sportsmen?.remove(at: index)
                    }
                    self?.setSportsmenDataSource()
                    self?.view.reloadData()
                }
            }
        }
    }
}
