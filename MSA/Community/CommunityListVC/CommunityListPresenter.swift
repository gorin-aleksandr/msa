//
//  CommunityListPresenter.swift
//  MSA
//
//  Created by Andrey Krit on 7/4/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import Foundation

// Mock data for UI Replace after UI is ready

let TEMP_IMAGE_URL = "https://st3.depositphotos.com/1046535/13923/i/1600/depositphotos_139239428-stock-photo-hairdresser-cutting-man-hair-in.jpg"

enum PersonType: String {
    case sportsman = "СПОРТСМЕН"
    case trainer = "ТРЕНЕР"
}

struct PersonVO {
    var firstName: String
    var secondName: String? = nil
    var imageUrl: String? = nil
    var city: String? = nil
    var type: PersonType? = nil
}

protocol CommunityListPresenterProtocol {
    func start() -> ()
    var communityDataSource: [UserVO] { get }
}

final class CommunityListPresenter: CommunityListPresenterProtocol {
    
    var communityDataSource = [UserVO]()
    
    private unowned var view: CommunityListViewProtocol
    private var dataLoader: UserDataManager
    
    init(view: CommunityListViewProtocol) {
        self.view = view
        self.dataLoader = UserDataManager()
    }
    
    func start() {
        dataLoader.loadAllUsers { [weak self] (users) in
            self?.communityDataSource = users
            self?.view.updateTableView()
        }
    }
}
