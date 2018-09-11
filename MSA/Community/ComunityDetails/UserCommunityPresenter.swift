//
//  CommunityDetailsPresenter.swift
//  MSA
//
//  Created by Andrey Krit on 8/22/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import Foundation

protocol UserCommunityPresenterProtocol {
    var userCommunityDataSource: [UserVO] { get }
    func start()
    func setDataSource(with searchText: String?, and selectedState: Int)
}


class UserCommunityPresenter: UserCommunityPresenterProtocol {

    private unowned var view: UserCommunityViewProtocol
    
    private var users = [UserVO]()
    private var searchText: String?
    var userCommunityDataSource = [UserVO]() {
        didSet {
            view.reloadData()
        }
    }
    
    init(view: UserCommunityViewProtocol, loadedUsers: [UserVO]) {
        self.view = view
        self.users = loadedUsers
        print(loadedUsers)
    }
    
    func start() {
        print("Community and trainings merge")
        setTrainerDataSource()
    }
    
    private func searchBy(string: String?) {
        searchText = string
        guard let text = searchText, !text.isEmpty else {
            
            return}
        userCommunityDataSource = userCommunityDataSource.filter {$0.getFullName().lowercased().contains(text.lowercased())}
    }
    
    private func setFriendsDataSource() {
        var friends = [UserVO]()
        guard let friendsArray = AuthModule.currUser.friends else {return}
        for friendId in friendsArray {
            let friend = users.first {$0.id == friendId}
            if let friend = friend {
                friends.append(friend)
            }
        }
        userCommunityDataSource = friends
    }
    
    private func setRequestDataSource() {
        var requests = [UserVO]()
        guard let requestsArray = AuthModule.currUser.requests else {return}
        for requestId in requestsArray {
            let request = users.first {$0.id == requestId}
            if let request = request {
                requests.append(request)
            }
        }
        userCommunityDataSource = requests
    }
    
    private func setTrainerDataSource() {
        var trainers = [UserVO]()
        guard let trainerId = AuthModule.currUser.trainerId else {return}
            let trainer = users.first {$0.id == trainerId}
            if let trainer = trainer {
                trainers.append(trainer)
            }
        userCommunityDataSource = trainers
    }
    
    func setDataSource(with searchText: String?, and selectedState: Int) {
        switch selectedState {
        case 0:
            setRequestDataSource()
        case 1:
            setFriendsDataSource()
        default:
            setTrainerDataSource()
        }
        searchBy(string: searchText)
        view.reloadData()
    }
}
