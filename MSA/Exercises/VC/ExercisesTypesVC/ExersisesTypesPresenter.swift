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

protocol ExercisesTypesDataProtocol {
    func startLoading()
    func finishLoading()
    func exercisesTypesLoaded()
    func exercisesLoaded()
    func filtersLoaded()
    func errorOccurred(err: String)
}

class ExersisesTypesPresenter {
    
    private let exercises: ExersisesDataManager
    private var view: ExercisesTypesDataProtocol?
    private let realmManager = RealmManager.shared
    
    init(exercises: ExersisesDataManager) {
        self.exercises = exercises
    }
    
    func attachView(view: ExercisesTypesDataProtocol){
        self.view = view
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
                self.observeExercises(snapchot: snapchot)
            }
        }
    }
    
    func getAllExersises() {
        if let _ = AuthModule.currUser.id {
            self.view?.startLoading()
            Database.database().reference().child("Exercise").observeSingleEvent(of: .value) { (snapchot) in
                self.observeExercises(snapchot: snapchot)
            }
        }
    }
    
    func observeExercises(snapchot: DataSnapshot) {
        self.view?.finishLoading()
        var items = [Exercise]()
        for snap in snapchot.children {
            let s = snap as! DataSnapshot
            if let _ = s.childSnapshot(forPath: "id").value as? NSNull {
                return
            }
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
            exercise.id = s.childSnapshot(forPath: "id").value as! Int
            exercise.name = s.childSnapshot(forPath: "name").value as! String
            exercise.pictures = picturesUrls
            exercise.typeId = s.childSnapshot(forPath: "typeId").value as! Int
            exercise.trainerId = s.childSnapshot(forPath: "trainerId").value as? Int ?? 0
            exercise.videoUrl = s.childSnapshot(forPath: "videoUrl").value as? String ?? ""
            exercise.exerciseDescriprion = s.childSnapshot(forPath: "description").value as? String ?? "No description"
            exercise.howToDo = s.childSnapshot(forPath: "howToDo").value as? String ?? "No info about doing"
            exercise.link = s.childSnapshot(forPath: "link").value as? String ?? "No attached link"
            exercise.filterIDs = filterIds
            items.append(exercise)
        }
        DispatchQueue.main.async {
            self.realmManager.saveObjectsArray(items)
        }
        self.exercises.allExersises = items
        self.view?.exercisesLoaded()
    }
    
    func setExercisesForType(with id: Int) {
        exercises.currentTypeExercisesArray = self.realmManager.getArray(ofType: Exercise.self, filterWith: NSPredicate(format: "typeId = %d", id))
    }
    
    func getCurrentTypeExerceses() -> [Exercise] {
        return exercises.currentTypeExercisesArray
    }
    
    func getFiltersByType(with ids: [Int]) -> [ExerciseTypeFilter]? {
        return exercises.allFilters.filter { ids.contains($0.id) }
    }
    
}
