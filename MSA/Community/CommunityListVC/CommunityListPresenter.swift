//
//  CommunityListPresenter.swift
//  MSA
//
//  Created by Andrey Krit on 7/4/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import Foundation
import UIKit

protocol CommunityListPresenterProtocol {
    func fetchData() -> ()
    var communityDataSource: [UserVO] { get }
    var isTrainerEnabled: Bool { get }
    func setFilterForState(index: Int)
    func selectCityAt(index: Int)
    func getCities() -> [String]
    func applyFilters(with: String?)
    func getPersonState(person: UserVO) -> PersonState
    func addToFriends(user: UserVO)
    func createNextPresenter(for view: UserCommunityViewProtocol) -> UserCommunityPresenterProtocol
    func addButtonTapped(at index: Int)
    func addAsTrainer(user: UserVO)
    func createProfilePresenter(user: UserVO, for view: ProfileViewProtocol) -> ProfilePresenterProtocol
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
    
    var currentUser: UserVO? {
        return AuthModule.currUser
    }
    
    var isTrainerEnabled: Bool {
        if let _ = AuthModule.currUser.trainerId {
            return false
        }
        return true
    }
    
    
    private var typeFilterState: CommunityFilterState = .all
    private var filterDataSource = ["Все", "Спортсмены", "Тренеры"]
    private var cities = [String]()
    private var selectedCity: String?
    private var searchText: String?
    
    var communityDataSource = [UserVO]()
    
    init(view: CommunityListViewProtocol) {
        self.view = view
        self.dataLoader = UserDataManager()
    }
    
    func fetchData() {
        dataLoader.getUser { [weak self] user, error  in
            if let user = user {
                AuthModule.currUser = user
            } else {
                Errors.handleError(error, completion: { [weak self] _ in
                    if let _ = error as? MSAError {
                        self?.view.setErrorViewHidden(false)
                    } else {
                        guard let `self` = self else { return }
                        self.view.showGeneralAlert()
                    }
                    self?.view.stopLoadingViewState()
                })
            }
        }
        dataLoader.loadAllUsers { [weak self] (users, error) in
            if let error = error {
                Errors.handleError(error, completion: { [weak self] message in
                    if let _ = error as? MSAError {
                        self?.view.setErrorViewHidden(false)
                    } else {
                        guard let `self` = self else { return }
                        self.view.showGeneralAlert()
                    }
                    self?.view.stopLoadingViewState()
                })
            } else {
                self?.users = users.filter { $0.id != self?.currentUser?.id }
                self?.setCitiesDataSource(from: users)
                self?.view.setErrorViewHidden(true)
                self?.selectFilter()
                self?.view.stopLoadingViewState()
            }
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
        if let isSportsman = currentUser?.sportsmen?.contains(personId), isSportsman {
            return PersonState.trainersSportsman
        }
        return PersonState.all
    }
    
    func addToFriends(user: UserVO) {
        guard let id = user.id, let currentId = currentUser?.id else { return }
        dataLoader.addToFriend(with: id) { [weak self] (success, error) in
            if error != nil {
                self?.view.stopLoadingViewState()
                self?.view.showGeneralAlert()
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
                self?.view.stopLoadingViewState()
                self?.view.showGeneralAlert()
            } else {
                self?.removeFromRequests(idToRemove: currentId, userId: id)
                self?.addAsSportsman(idToAdd: currentId, userId: id)
               // self?.removeFromFriends()
                self?.updateTrainerInDataSource(for: id)
            }
        }
    }

    private func addAsSportsman(idToAdd: String, userId: String) {
        dataLoader.addToSportsmen(idToAdd: idToAdd, userId: userId, callback: { [weak self] (success, error) in
            if error != nil {
                self?.view.stopLoadingViewState()
                self?.view.showGeneralAlert()
            }
        })
    }
    
    private func removeFromRequests(idToRemove: String, userId: String) {
        dataLoader.removeFromRequests(idToRemove: idToRemove, userId: userId, callback: { [weak self] (success, error) in
            if error != nil {
                self?.view.stopLoadingViewState()
                self?.view.showGeneralAlert()
            } else {
                guard let currentId = self?.currentUser?.id, currentId == userId else {return}
                if let index = self?.currentUser?.requests?.index(of: idToRemove) {
                    AuthModule.currUser.requests?.remove(at: index)
                }
            }
        })
    }
    
    private func addRequest(idToAdd: String, userId: String) {
        dataLoader.addToRequests(idToAdd: idToAdd, userId: userId, callback: { [weak self] (success, error) in
            if error != nil {
                self?.view.stopLoadingViewState()
                self?.view.showGeneralAlert()
            }
        })
    }
    
    private func updateFriendInDatasource(for id: String) {
        AuthModule.currUser.friends?.append(id)
        view.updateTableView()
    }
    
    private func updateTrainerInDataSource(for id: String) {
        AuthModule.currUser.trainerId = id
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
        let presenter = UserCommunityPresenter(view: view, loadedUsers: users)
        return presenter
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
    
    private func applyCityFilter() {
        guard let cityFilter = selectedCity else {
            return
        }
        view.setCityFilterTextField(name: cityFilter)
        communityDataSource = communityDataSource.filter {$0.city == cityFilter}
    }
    
    private func applyTypeFilter() {
        switch  typeFilterState {
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
