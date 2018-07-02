//
//  NewExerciseManager.swift
//  MSA
//
//  Created by Pavlo Kharambura on 7/1/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import Foundation
import RealmSwift

class NewExerciseManager {
    
    static let shared = NewExerciseManager()
    var dataSource = NewExerciseDataSource()
    
    func setName(name: String) {
        dataSource.name = name
    }
    
    func setType(type: Int) {
        dataSource.typeId = type
    }
    
    func setFilter(filter: Int) {
        dataSource.filterId = filter
    }
    
    func setDescription(description: String) {
        dataSource.descript = description
    }
    func setHowToDo(howToDo: String) {
        dataSource.howToDo = howToDo
    }
    
    func addPictures(picData: Data) {
        dataSource.pictures.append(picData)
    }
    func deletePicture(at index: Int) {
        dataSource.pictures.remove(at: index)
    }
    
}
