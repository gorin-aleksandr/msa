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
    var secondName: String?
    var imageUrl: String?
    var city: String?
    var type: PersonType?
}

protocol CommunityListPresenterProtocol {
    func start() -> ()
    var communityDataSource: [PersonVO] { get }
}

final class CommunityListPresenter: CommunityListPresenterProtocol {
    
    var communityDataSource = [PersonVO(firstName: "Андрей", secondName: "Крит", imageUrl: TEMP_IMAGE_URL, city: "Киев", type: .sportsman), PersonVO(firstName: "Гоша", secondName: "Куценко", imageUrl: TEMP_IMAGE_URL, city: "Москва", type: .sportsman), PersonVO(firstName: "Вася", secondName: "Пукин", imageUrl: nil, city: nil, type: .trainer)]
    
    
    private unowned var view: CommunityListViewProtocol
    
    init(view: CommunityListViewProtocol) {
        self.view = view
    }
    
    func start() {

    }
}
