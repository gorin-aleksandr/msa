//
//  ExercisesVO.swift
//  MSA
//
//  Created by Pavlo Kharambura on 6/14/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Exercise: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    var pictures = List<Image>()
    @objc dynamic var typeId: Int = 0
    @objc dynamic var trainerId: Int = 0
    @objc dynamic var videoUrl: String = ""
    @objc dynamic var exerciseDescriprion: String = "No description"
    @objc dynamic var howToDo: String = "No info about doing"
    @objc dynamic var link: String = "No attached link"
    var filterIDs = List<Id>()

    override static func primaryKey() -> String? {
        return "id"
    }
    
    func incrementID() -> Int {
        let realm = try! Realm()
        return (realm.objects(Exercise.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
}

class Image: Object {
    @objc dynamic var url: String = ""
}

class Id: Object {
    @objc dynamic var id: Int = 0
}

class ExerciseType: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var picture: String = ""
    var exercisesIds = List<Id>()
    var filterIDs = List<Id>()

    func incrementID() -> Int {
        let realm = try! Realm()
        return (realm.objects(ExerciseType.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class ExerciseTypeFilter: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    
    func incrementID() -> Int {
        let realm = try! Realm()
        return (realm.objects(ExerciseTypeFilter.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
