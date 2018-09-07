//
//  CommunityListPresenter.swift
//  MSA
//
//  Created by Andrey Krit on 7/4/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import Foundation

// Mock data for UI Replace after UI is ready

protocol CommunityListPresenterProtocol {
    func start() -> ()
    var communityDataSource: [UserVO] { get }
    func setFilterForState(index: Int)
    func selectCityAt(index: Int)
    func getCities() -> [String]
    func applyFilters(with: String?)
    func getPersonState(person: UserVO) -> PersonState
    func addToFriends(user: UserVO)
    func createNextPresenter(for view: UserCommunityViewProtocol) -> UserCommunityPresenterProtocol
    func addButtonTapped(at index: Int)
    func addAsTrainer(user: UserVO)
}

enum CommunityFilterState: Int {
    case all = 0
    case sportsmen = 1
    case trainers = 2
    
    func fromInt(index: Int) -> CommunityFilterState {
        switch index {
        case 1:
            return .sportsmen
        case 2:
            return .trainers
        default:
            return .all
        }
    }
    
    func getUserTypeString() -> String? {
        switch self {
        case .sportsmen:
            return "СПОРТСМЕН"
        case .trainers:
            return "ТРЕНЕР"
        default:
            return nil
        }
    }
}

final class CommunityListPresenter: CommunityListPresenterProtocol {
    
    private unowned var view: CommunityListViewProtocol
    private var dataLoader: UserDataManager
    
    var users: [UserVO] = [] {
        didSet {
            communityDataSource = users
        }
    }
    
    var currentUser: UserVO?
    
    
    private var typeFilterState: CommunityFilterState = .all
    private var filterDataSource = ["ВСЕ", "СПОРТСМЕНЫ", "ТРЕНЕРЫ"]
    private var cities = [String]()
    private var selectedCity: String?
    private var searchText: String?
    
    var communityDataSource = [UserVO]()
    
    init(view: CommunityListViewProtocol) {
        self.view = view
        self.dataLoader = UserDataManager()
    }
    
    func start() {
        selectFilter()
        dataLoader.getUser { [weak self] user in
            self?.currentUser = user
        }
        dataLoader.loadAllUsers { [weak self] (users) in
            self?.users = users
            self?.setCitiesDataSource(from: users)
            self?.view.updateTableView()
        }
    }
    
    private func setCitiesDataSource(from users: [UserVO]) {
        var citiesList = [String]()
        for user in users {
            if let city = user.city, !city.isEmpty {
                citiesList.append(city)
            }
        }
        cities = Array(Set(citiesList)).sorted()
        cities.insert("Все", at: 0)
    }
    
    func setFilterForState(index: Int) {
       typeFilterState = typeFilterState.fromInt(index: index)
        selectFilter()
    }
    
    func getCities() -> [String] {
        return cities
    }
    
    func selectCityAt(index: Int) {
        selectedCity = index == 0 ? nil : cities[index]
        view.setCityFilterTextField(name: selectedCity)
        applyFilters(with: searchText)
    }
    
   private func searchBy(string: String?) {
        searchText = string
        guard let text = searchText, !text.isEmpty else {return}
        communityDataSource = communityDataSource.filter {$0.getFullName().lowercased().contains(text.lowercased())}
    }
    
    func applyFilters(with searchText: String?) {
        applyTypeFilter()
        applyCityFilter()
        searchBy(string: searchText)
        view.updateTableView()
    }
    
    func getPersonState(person: UserVO) -> PersonState {
        guard let personId = person.id else { return PersonState.all}
        if personId == currentUser?.trainerId {
            return PersonState.userTrainer
        }
        if let isFriend = currentUser?.friends?.contains(personId), isFriend {
            return PersonState.friend
        }
        return PersonState.all
    }
    
    func addToFriends(user: UserVO) {
        guard let id = user.id, let currentId = currentUser?.id else { return }
        dataLoader.addToFriend(with: id) { [weak self] (success, error) in
            if error != nil {
                print((error?.localizedDescription)! +  "unable to add to friends")
            } else {
                self?.updateFriendInDatasource(for: id)
                self?.removeFromRequests(idToRemove: id, userId: currentId)
                if let currentIsInUserFriends = user.friends?.contains(id), !currentIsInUserFriends {
                    self?.addRequest(idToAdd: currentId, userId: id)
                }
            }
        }
    }
    
    func addAsTrainer(user: UserVO) {
        guard let id = user.id, let currentId = currentUser?.id else { return }
        dataLoader.addAsTrainer(with: id) { [weak self] (success, error) in
            if error != nil {
                print((error?.localizedDescription)! +  "unable to add to friends")
            } else {
                self?.removeFromRequests(idToRemove: currentId, userId: id)
                self?.addAsSportsman(idToAdd: currentId, userId: id)
               // self?.removeFromFriends()
                self?.updateTrainerInDataSource(for: id)
//                self?.removeFromRequests(idToRemove: id, userId: currentId)
//                if let currentIsInUserFriends = user.friends?.contains(id), !currentIsInUserFriends {
//                    self?.addRequest(idToAdd: currentId, userId: id)
//                }
            }
        }
    }

    private func addAsSportsman(idToAdd: String, userId: String) {
        dataLoader.addToSportsmen(idToAdd: idToAdd, userId: userId, callback: { [weak self] (success, error) in
            if error != nil {
                print(error?.localizedDescription)
            }
        })
    }
    
    private func removeFromRequests(idToRemove: String, userId: String) {
        dataLoader.removeFromRequests(idToRemove: idToRemove, userId: userId, callback: { [weak self] (success, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                guard let currentId = self?.currentUser?.id, currentId == userId else {return}
                if let index = self?.currentUser?.requests?.index(of: idToRemove) {
                    self?.currentUser?.requests?.remove(at: index)
                }
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
    
    private func updateFriendInDatasource(for id: String) {
        currentUser?.friends?.append(id)
        view.updateTableView()
    }
    
    private func updateTrainerInDataSource(for id: String) {
        currentUser?.trainerId = id
        view.updateTableView()
    }
    
    func addButtonTapped(at index: Int) {
        guard communityDataSource[index].userType == .trainer else {
             view.showAlertFor(user: communityDataSource[index], isTrainerEnabled: false)
            return
        }
        guard let trainerExists = currentUser?.trainerId?.isEmpty else {
            print(communityDataSource[index].userType)
            view.showAlertFor(user: communityDataSource[index], isTrainerEnabled: true)
            return
        }
        view.showAlertFor(user: communityDataSource[index], isTrainerEnabled: trainerExists)
    }
    
    func createNextPresenter(for view: UserCommunityViewProtocol) -> UserCommunityPresenterProtocol {
        print(users)
        let presenter = UserCommunityPresenter(view: view, loadedUsers: users)
        return presenter
    }
    
    private func applyCityFilter() {
        guard let cityFilter = selectedCity else {
            return
        }
        view.setCityFilterTextField(name: cityFilter)
        communityDataSource = communityDataSource.filter {$0.city == cityFilter}
    }
    
    private func applyTypeFilter() {
        switch  typeFilterState {
//        case .friends:
//            var friends = [UserVO]()
//            guard let friendsArray = AuthModule.currUser.friends else {return}
//            for friendId in friendsArray {
//                let friend = communityDataSource.first {$0.id == friendId}
//                if let friend = friend {
//                    friends.append(friend)
//                }
//                communityDataSource = friends
//            }
            
        case .sportsmen:
            communityDataSource = users.filter {$0.type == typeFilterState.getUserTypeString()}
        case .trainers:
            communityDataSource = users.filter {$0.type == typeFilterState.getUserTypeString()}
        default:
            communityDataSource = users
        }
    }
    
    private func selectFilter() {
        view.configureFilterView(dataSource: filterDataSource, selectedFilterIndex: typeFilterState.rawValue)
        applyFilters(with: searchText)
    }
}
