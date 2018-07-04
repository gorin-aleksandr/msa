//
//  CommunityListPresenter.swift
//  MSA
//
//  Created by Andrey Krit on 7/4/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import Foundation

protocol CommunityListPresenterProtocol {
    
}

final class CommunityListPresenter: CommunityListPresenterProtocol {
    
    unowned var view: CommunityListViewProtocol
    
    init(view: CommunityListViewProtocol) {
        self.view = view
    }
}
