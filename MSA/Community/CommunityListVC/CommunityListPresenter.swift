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
}

enum CommunityFilterState: Int {
    case all = 0
    case friends = 1
    case sportsmen = 2
    case trainers = 3
    
    func fromInt(index: Int) -> CommunityFilterState {
        switch index {
        case 1:
            return .friends
        case 2:
            return .sportsmen
        case 3:
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
    
    
    private var typeFilterState: CommunityFilterState = .all
    private var filterDataSource = ["ВСЕ", "ДРУЗЬЯ", "СПОРТСМЕНЫ", "ТРЕНЕРЫ"]
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
        dataLoader.loadAllUsers { [weak self] (users) in
            self?.users = users
            self?.setCitiesDataSource(from: users)
            self?.view.updateTableView()
            print(AuthModule.currUser.friends)
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
    
    private func applyCityFilter() {
        guard let cityFilter = selectedCity else {
            return
        }
        view.setCityFilterTextField(name: cityFilter)
        communityDataSource = communityDataSource.filter {$0.city == cityFilter}
    }
    
    private func applyTypeFilter() {
        switch  typeFilterState {
        case .friends:
            var friends = [UserVO]()
            guard let friendsArray = AuthModule.currUser.friends else {return}
            for friendId in friendsArray {
                let friend = communityDataSource.first {$0.id == friendId}
                if let friend = friend {
                    friends.append(friend)
                }
                communityDataSource = friends
            }
            
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
