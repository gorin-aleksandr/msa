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
