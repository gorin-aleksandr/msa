//
//  ExersisesTypesPresenter.swift
//  MSA
//
//  Created by Pavlo Kharambura on 6/23/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import Foundation
import Firebase
import RealmSwift
import Realm

@objc protocol ExercisesTypesDataProtocol: class {
    func startLoading()
    func finishLoading()
    func exercisesTypesLoaded()
    func exercisesLoaded()
    func myExercisesLoaded()
    func filtersLoaded()
    func errorOccurred(err: String)
    @objc optional func exerciseDeleted(with id: String)
}

class ExersisesTypesPresenter {
    
    private let exercises: ExersisesDataManager
    private weak var view: ExercisesTypesDataProtocol?
    private let realmManager = RealmManager.shared
    
    init(exercises: ExersisesDataManager) {
        self.exercises = exercises
    }
    
    func attachView(view: ExercisesTypesDataProtocol){
        self.view = view
    }
    
    func getCurrentIndex() -> Int {
        return exercises.currentExerciseIndex
    }
    
    func setCurrentIndex(index: Int) {
        exercises.currentExerciseIndex = index
    }
    
    func getTypes() -> [ExerciseType] {
        return self.exercises.exersiseTypes
    }
    
    func setCurrentExercise(exerc: Exercise) {
        exercises.currentExercise = exerc
    }
    func getCurrentExercise() -> Exercise {
        return exercises.currentExercise!
    }
    func setCurrentExetcisesType(type: ExerciseType) {
        exercises.currentExerciseeType = type
    }
    func getCurrentExetcisesType() -> ExerciseType {
        return exercises.currentExerciseeType
    }
    func setCurrentFilters(filt: [ExerciseTypeFilter]) {
        exercises.currentFilters = filt
    }
    func getCurrentFilters() -> [ExerciseTypeFilter] {
        return exercises.currentFilters
    }
    
    func getTypesFromRealm() {
        if let _ = AuthModule.currUser.id {
            exercises.exersiseTypes = realmManager.getArray(ofType: ExerciseType.self)
            self.view?.exercisesTypesLoaded()
        }
    }
    func getExercisesFromRealm() {
        if let _ = AuthModule.currUser.id {
            exercises.allExersises = realmManager.getArray(ofType: Exercise.self)
            self.view?.exercisesLoaded()
        }
    }
    func getMyExercisesFromRealm() {
        if let _ = AuthModule.currUser.id {
            exercises.ownExercises = Array(realmManager.getArray(ofType: MyExercises.self).last?.myExercises ?? List<Exercise>())
            self.view?.myExercisesLoaded()
        }
    }
    
    func getOwnExercises() -> [Exercise] {
        return exercises.ownExercises
    }
    func getFiltersFromRealm() {
        if let _ = AuthModule.currUser.id {
            exercises.allFilters = realmManager.getArray(ofType: ExerciseTypeFilter.self)
            self.view?.filtersLoaded()
        }
    }
    
    func detectTypesChanges() {
        if let _ = AuthModule.currUser.id {
            self.view?.startLoading()
            Database.database().reference().child("ExerciseType").observe(.childAdded) { (snapchot) in
                self.observeTypes(snapchot: snapchot)
            }
        }
    }
    
    func getAllTypes() {
        if let _ = AuthModule.currUser.id {
            self.view?.startLoading()
            Database.database().reference().child("ExerciseType").observeSingleEvent(of: .value) { (snapchot) in
               self.observeTypes(snapchot: snapchot)
            }
        }
    }
    
    func deleteExercise(with id: String) {
        if let userId = AuthModule.currUser.id {
            view?.startLoading()
            guard let object = self.realmManager.getElement(ofType: Exercise.self, filterWith: NSPredicate(format: "id = %@", id)) else {return}
            self.realmManager.deleteObject(object)
            Database.database().reference().child("ExercisesByTrainers").child(userId).child("\(id)").removeValue { (error, ref) in
                self.view?.finishLoading()
                if error == nil {
                    self.view?.exerciseDeleted!(with: id)
                } else {
                    self.view?.errorOccurred(err: error?.localizedDescription ?? "Unknown Error")
                }
            }
        }
    }
    
    func observeTypes(snapchot: DataSnapshot) {
        self.view?.finishLoading()
        var items = [ExerciseType]()
        for snap in snapchot.children {
            let s = snap as! DataSnapshot
            if let _ = s.childSnapshot(forPath: "id").value as? NSNull {
                return
            }
            let exIds = List<Id>()
            let filIds = List<Id>()
            if let exersises = s.childSnapshot(forPath: "exerciseIDs").value as? NSArray {
                for ex in (exersises as! [[String:Int]]) {
                    let id = Id()
                    id.id = ex["id"]!
                    exIds.append(id)
                }
            }
            if let filters = s.childSnapshot(forPath: "filterIDs").value as? NSArray {
                for f in (filters as! [[String:Int]]) {
                    let id = Id()
                    id.id = f["id"]!
                    filIds.append(id)
                }
            }
            let type = ExerciseType()
            type.id = s.childSnapshot(forPath: "id").value as! Int
            type.name = s.childSnapshot(forPath: "name").value as! String
            type.picture = s.childSnapshot(forPath: "picture").value as! String
            type.exercisesIds = exIds
            type.filterIDs = filIds
            items.append(type)
        }
        items.sort {
            return $0.id < $1.id
        }
        DispatchQueue.main.async {
            self.realmManager.saveObjectsArray(items)
        }
        self.exercises.exersiseTypes = items
        self.view?.exercisesTypesLoaded()
    }
    
    func getFilters() -> [ExerciseTypeFilter] {
        return exercises.allFilters
    }
    
    func getAllFilters() {
        if let _ = AuthModule.currUser.id {
            self.view?.startLoading()
            Database.database().reference().child("ExerciseTypeFilter").observeSingleEvent(of: .value) { (snapchot) in
                self.observeFilters(snapchot: snapchot)
            }
        }
    }
    
    func detectFiltersChanges() {
        if let _ = AuthModule.currUser.id {
            self.view?.startLoading()
            Database.database().reference().child("ExerciseTypeFilter").observe(.childAdded) { (snapchot) in
                self.observeFilters(snapchot: snapchot)
            }
        }
    }
    
    func observeFilters(snapchot: DataSnapshot) {
        self.view?.finishLoading()
        var items = [ExerciseTypeFilter]()
        for snap in snapchot.children {
            let s = snap as! DataSnapshot
            if let _ = s.childSnapshot(forPath: "id").value as? NSNull {
                return
            }
            let filter = ExerciseTypeFilter()
            filter.id = s.childSnapshot(forPath: "id").value as! Int
            filter.name = s.childSnapshot(forPath: "name").value as! String
            items.append(filter)
        }
        DispatchQueue.main.async {
            self.realmManager.saveObjectsArray(items)
        }
        self.exercises.allFilters = items
        self.view?.filtersLoaded()
    }
    
    func getExercises() -> [Exercise] {
        return exercises.allExersises
    }
    
    func detectExersisesChanges() {
        if let _ = AuthModule.currUser.id {
            self.view?.startLoading()
            Database.database().reference().child("Exercise").observe(.childAdded) { (snapchot) in
                self.observeExercises(snapchot: snapchot, all: true)
            }
        }
    }
    
    func getAllExersises() {
        if let _ = AuthModule.currUser.id {
            self.view?.startLoading()
            Database.database().reference().child("Exercise").observeSingleEvent(of: .value) { (snapchot) in
                self.observeExercises(snapchot: snapchot, all: true)
            }
        }
    }
    
    func getMyExercises(success: (() -> Void)? = nil, failture: (([NSError]) -> Void)? = nil) {
        if let id = AuthModule.currUser.id {
            self.view?.startLoading()
            Database.database().reference().child("ExercisesByTrainers").child(id).observeSingleEvent(of: .value) { (data) in
                self.observeExercises(snapchot: data, all: false)
                success?()
            }
        }
    }
    
//    func listenForUpdates() {
//        if let id = AuthModule.currUser.id {
//
//        }
//    }
    
    
    func observeExercises(snapchot: DataSnapshot, all: Bool) {
        self.view?.finishLoading()
        var items = [Exercise]()
        items = parseExercises(snapchot: snapchot)
        if all {
            DispatchQueue.main.async {
                self.realmManager.saveObjectsArray(items)
            }
            self.exercises.allExersises = items
            self.view?.exercisesLoaded()
        } else {
            let myExerc = MyExercises()
            myExerc.id = AuthModule.currUser.id ?? ""
            for item in items {
                myExerc.myExercises.append(item)
            }
            DispatchQueue.main.async {
                self.realmManager.saveObject(myExerc)
            }
            self.exercises.ownExercises = Array(Set(myExerc.myExercises))
            self.view?.myExercisesLoaded()
        }
    }
    
    func setExercisesForType(with id: Int) {
        if id == 12 {
            exercises.currentTypeExercisesArray = exercises.ownExercises
        } else {
            exercises.currentTypeExercisesArray = self.realmManager.getArray(ofType: Exercise.self, filterWith: NSPredicate(format: "typeId = %d", id))
            var exerc = [Exercise]()
            for e in exercises.ownExercises {
                if e.realTypeId == id {
                    exerc.append(e)
                }
            }
            exercises.currentTypeExercisesArray.append(contentsOf: exerc)
            exercises.currentTypeExercisesArray.sort {$0.name < $1.name}
            
        }
        var filters = [ExerciseTypeFilter]()
        for exercise in exercises.currentTypeExercisesArray {
            guard let id_ = exercise.filterIDs.first?.id else {continue}
            guard let filter = self.realmManager.getElement(ofType: ExerciseTypeFilter.self, filterWith: NSPredicate(format: "id = %d", id_)) else {continue}
            filters.append(filter)
        }
        exercises.currentFilters = Array(Set(filters))
    }
    
    func getCurrentTypeExerceses() -> [Exercise] {
        return exercises.currentTypeExercisesArray
    }
    
    func deleteAt(i: Int) {
        
        exercises.currentTypeExercisesArray.remove(at: i)
    }
    
    func getFiltersByType(with ids: [Int]) -> [ExerciseTypeFilter]? {
        return exercises.allFilters.filter { ids.contains($0.id) }
    }
    
}

func parseExercises(snapchot: DataSnapshot) -> [Exercise] {
    var items = [Exercise]()
    for snap in snapchot.children {
        let s = snap as! DataSnapshot
        if let _ = s.childSnapshot(forPath: "id").value as? NSNull {
            return []
        }
        guard let _ = s.childSnapshot(forPath: "id").value as? String else {continue}
        let picturesUrls = List<Image>()
        let filterIds = List<Id>()
        if let pictures = s.childSnapshot(forPath: "pictures").value as? NSArray {
            for p in (pictures as! [[String:String]]) {
                let image = Image()
                image.url = p["url"]!
                picturesUrls.append(image)
            }
        }
        if let filters = s.childSnapshot(forPath: "filterIDs").value as? NSArray {
            for f in (filters as! [[String:Int]]) {
                let filt = Id()
                filt.id = f["id"]!
                filterIds.append(filt)
            }
        }
        let exercise = Exercise()
        
        exercise.id = s.childSnapshot(forPath: "id").value as! String
        exercise.realTypeId = s.childSnapshot(forPath: "realTypeId").value as? Int ?? -1
        exercise.name = s.childSnapshot(forPath: "name").value as? String ?? ""
        exercise.pictures = picturesUrls
        exercise.typeId = s.childSnapshot(forPath: "typeId").value as! Int
        exercise.trainerId = s.childSnapshot(forPath: "trainerId").value as? String ?? ""
        exercise.videoUrl = s.childSnapshot(forPath: "videoUrl").value as? String ?? ""
        exercise.exerciseDescriprion = s.childSnapshot(forPath: "description").value as? String ?? "No description"
        exercise.howToDo = s.childSnapshot(forPath: "howToDo").value as? String ?? "No info about doing"
        exercise.link = s.childSnapshot(forPath: "link").value as? String ?? "No attached link"
        exercise.filterIDs = filterIds
        items.append(exercise)
    }
    return items
}
