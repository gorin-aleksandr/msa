//
//  TrainingManager.swift
//  MSA
//
//  Created by Pavlo Kharambura on 8/30/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import Foundation
import RealmSwift
import Firebase


protocol TrainingsViewDelegate {
    func startLoading()
    func finishLoading()
    func trainingsLoaded()
    func templateCreated()
    func templatesLoaded()
    func trainingEdited()
    func errorOccurred(err: String)
}

class TrainingManager {
    
    let realm = RealmManager.shared
    var dataSource: TrainingsDataSource?
    private var view: TrainingsViewDelegate?
    
    func initDataSource(dataSource: TrainingsDataSource) {
        self.dataSource = dataSource
    }
    
    func initView(view: TrainingsViewDelegate) {
        self.view = view
    }
    
    func getTrainings() -> [Training]? {
        return dataSource?.trainings
    }
    
    func setCurrent(day: TrainingDay?) {
        dataSource?.currentDay = day
    }
    func getCurrentday() -> TrainingDay? {
        return dataSource?.currentDay
    }
    
    func setCurrent(training: Training?) {
        dataSource?.currentTraining = training
    }
    func getCurrentTraining() -> Training? {
        return realm.getElement(ofType: Training.self, filterWith: NSPredicate(format: "id = %d", dataSource?.currentTraining?.id ?? -1))
    }
    func setCurrent(exercise: ExerciseInTraining) {
        dataSource?.currentExerciseInDay = exercise
    }
    func getCurrentExercise() -> ExerciseInTraining? {
        return realm.getElement(ofType: ExerciseInTraining.self, filterWith: NSPredicate(format: "id = %d", dataSource?.currentExerciseInDay?.id ?? -1))
    }
    func setCurrent(iteration: Iteration) {
        dataSource?.currentIteration = iteration
    }
    func getCurrentIteration() -> Iteration? {
        return dataSource?.currentIteration
    }
    func getTrainingsFromRealm() -> [Training]? {
        return realm.getArray(ofType: Training.self)
    }
    func getTemplatesFromRealm() -> [TrainingTemplate]? {
        return realm.getArray(ofType: TrainingTemplate.self)
    }
    func getDay(by id: Int) -> TrainingDay? {
        return realm.getElement(ofType: TrainingDay.self, filterWith: NSPredicate(format: "id = %d", id))
    }
    func getWeek(by id: Int) -> TrainingWeek? {
        return realm.getElement(ofType: TrainingWeek.self, filterWith: NSPredicate(format: "id = %d", id))
    }
    func getExercise(by id: Int) -> ExerciseInTraining? {
        return realm.getElement(ofType: ExerciseInTraining.self, filterWith: NSPredicate(format: "id = %d", id))
    }
    func getIteration(by id: Int) -> Iteration? {
        return realm.getElement(ofType: Iteration.self, filterWith: NSPredicate(format: "id = %d", id))
    }
    func getTemplatesby(trainer id: Int) -> [TrainingTemplate]? {
        return realm.getArray(ofType: TrainingTemplate.self, filterWith: NSPredicate(format: "trianerId = %d", id))
    }
    func saveTemplateToRealm(templates: [TrainingTemplate]) {
        realm.saveObjectsArray(templates)
    }
    func saveTrainingsToRealm(trainings: [Training]) {
        realm.saveObjectsArray(trainings)
    }
    func saveDaysToRealm(days: [TrainingDay]) {
        realm.saveObjectsArray(days)
    }
    func saveWeeksToRealm(weeks: [TrainingWeek]) {
        realm.saveObjectsArray(weeks)
    }
    func saveExersInTrainingToRealm(ex: [ExerciseInTraining]) {
        realm.saveObjectsArray(ex)
    }
    func saveIterationsToRealm(iterations: [Iteration]) {
        realm.saveObjectsArray(iterations)
    }
    
    func saveTemplate() {
        if let id = AuthModule.currUser.id {
            self.view?.startLoading()
            let index = dataSource?.newTemplate?.incrementID() ?? 0
            let newInfo = makeTemplateForFirebase(trainerId: id, edit: false)
            Database.database().reference().child("Templates").child(id).child("\(index)").setValue(newInfo) { (error, databaseFer) in
                self.view?.finishLoading()
                if error == nil {
                    guard let newTemplate = self.dataSource?.newTemplate else {return}
            
                    self.realm.saveObject(newTemplate, update: false)
                    self.view?.templateCreated()
                } else {
                    self.view?.errorOccurred(err: error?.localizedDescription ?? "Unknown error")
                }
            }
        }
    }
    
    func makeTemplateForFirebase(trainerId: String, edit: Bool) -> [String:Any] {
        var index = Int()
        if edit {
            index = dataSource?.newTemplate?.id ?? 0
        } else {
            index = dataSource?.newTemplate?.incrementID() ?? 0
        }
        dataSource?.newTemplate?.id = index
        return [
        "id": dataSource?.newTemplate?.id ?? 0,
        "name": dataSource?.newTemplate?.name ?? "",
        "trainerId": trainerId,
        "typeId": dataSource?.newTemplate?.typeId ?? -1,
        "days": dataSource?.newTemplate?.days ?? 0,
        "trainingId": dataSource?.newTemplate?.trainingId ?? -1
        ]
    }
    
    func editTraining(wiht id: Int) {
        if let userId = AuthModule.currUser.id {
            self.view?.startLoading()
            let newInfo = makeTrainingForFirebase(id: id, or: true)
            Database.database().reference().child("Trainings").child(userId).child("\(id)").updateChildValues(newInfo) { (error, ref) in
                self.view?.finishLoading()
                self.view?.trainingEdited()
                if error == nil {
                    
                } else {
                    self.view?.errorOccurred(err: error?.localizedDescription ?? "")
                }
            }
        }
    }
    
    func loadTrainings() {
        if let id = AuthModule.currUser.id {
            self.view?.startLoading()
            Database.database().reference().child("Trainings").child(id).observeSingleEvent(of: .value) { (snapchot) in
                self.observeTrainings(snapchot: snapchot)
            }
        }
    }
    
    func loadTrainingsFromRealm() {
        let trainings = Array(realm.getArray(ofType: Training.self))
        dataSource?.set(trainings: trainings)
        dataSource?.currentTraining = trainings.first
        self.view?.trainingsLoaded()
    }
    
    func loadTemplates() {
        if let id = AuthModule.currUser.id {
            self.view?.startLoading()
            Database.database().reference().child("Templates").child(id).observeSingleEvent(of: .value) { (snapchot) in
                self.observeTemplates(snapchot: snapchot)
            }
        }
    }
    
    func deleteTraining(with id: String) {
        if let userId = AuthModule.currUser.id {
            self.view?.startLoading()
            Database.database().reference().child("Trainings").child(userId).child(id).removeValue { (error, ref) in
                self.view?.finishLoading()
                if error == nil {
                    // DELETED
                } else {
                    self.view?.errorOccurred(err: error?.localizedDescription ?? "")
                }
            }
        }
    }
    
    func deleteTemplate(with id: String) {
        if let userId = AuthModule.currUser.id {
            self.view?.startLoading()
            Database.database().reference().child("Templates").child(userId).child(id).removeValue { (error, ref) in
                self.view?.finishLoading()
                if error == nil {
                    // DELETED
                } else {
                    self.view?.errorOccurred(err: error?.localizedDescription ?? "")
                }
            }
        }
    }
    
    func makeTrainingForFirebase(id: Int, or edit: Bool) -> [String:Any] {
        var newiterations = [[String:Any]]()
        var newexercises = [[String:Any]]()
        var newdays = [[String:Any]]()
        var newWeeks = [[String:Any]]()

        let training = dataSource?.currentTraining
        if let weeks = training?.weeks {
            newWeeks.removeAll()
            for week in weeks {
                newdays.removeAll()
                for day in week.days {
                    newexercises.removeAll()
                    for e in day.exercises {
                        newiterations.removeAll()
                        for i in e.iterations {
                            newiterations.append([
                                    "id": i.id,
                                    "exerciseInTrainingId": i.exerciseInTrainingId,
                                    "weight": i.weight,
                                    "counts": i.counts,
                                    "workTime": i.workTime,
                                    "restTime": i.restTime
                                ])
                        }
                        newexercises.append([
                               "id": e.id,
                               "name": e.name,
                               "exerciseId": e.exerciseId,
                               "iterations": newiterations
                            ])
                    }
                    newdays.append([
                           "id": day.id,
                           "name": day.name,
                           "date": day.date,
                           "exercises": newexercises
                        ])
                }
                newWeeks.append([
                    "id": week.id,
                    "days": newdays
                    ])
            }
        }
        return [
            "id": dataSource?.currentTraining?.id ?? "",
            "name": dataSource?.currentTraining?.name ?? "",
            "trainerId": dataSource?.currentTraining?.trianerId ?? "",
            "userId": dataSource?.currentTraining?.userId ?? "",
            "weeks": newWeeks
        ]
    }
    
    func observeTemplates(snapchot: DataSnapshot) {
        self.view?.finishLoading()
        var items = [TrainingTemplate]()
        for snap in snapchot.children {
            let s = snap as! DataSnapshot
            if let _ = s.childSnapshot(forPath: "id").value as? NSNull {return}
            let template = TrainingTemplate()
            template.id = s.childSnapshot(forPath: "id").value as! Int
            template.name = s.childSnapshot(forPath: "name").value as! String
            template.trianerId = s.childSnapshot(forPath: "trainerId").value as! String
            template.trainingId = s.childSnapshot(forPath: "trainingId").value as! Int
            template.days = s.childSnapshot(forPath: "days").value as! Int
            template.typeId = s.childSnapshot(forPath: "typeId").value as! Int
            items.append(template)
        }
        self.dataSource?.templates = items
        self.saveTemplateToRealm(templates: items)
        self.view?.templatesLoaded()
    }
    
    func observeTrainings(snapchot: DataSnapshot) {
        self.view?.finishLoading()
        var items = [Training]()
        for snap in snapchot.children {
            let s = snap as! DataSnapshot
            if let _ = s.childSnapshot(forPath: "id").value as? NSNull {
                return
            }
            let training = Training()
            training.id = s.childSnapshot(forPath: "id").value as! Int
            training.name = s.childSnapshot(forPath: "name").value as! String
            training.trianerId = s.childSnapshot(forPath: "trainerId").value as! String
            training.userId = s.childSnapshot(forPath: "userId").value as! Int

            if let weeks = s.childSnapshot(forPath: "weeks").value as? NSArray {
                for w in (weeks as! [[String:Any]]) {
                    let week = TrainingWeek()
                    week.id = w["id"] as! Int
                    let daysInWeek = List<TrainingDay>()
                    if let days = w["days"] as? [[String:Any]] {
                        for d in days {
                            let day = TrainingDay()
                            day.id = d["id"] as! Int
                            day.name = d["name"] as! String
                            day.date = d["date"] as! String
                            let exercisesInDay = List<ExerciseInTraining>()
                            if let exercises = d["exercises"] as? [[String:Any]] {
                                for e in exercises {
                                    let exercise = ExerciseInTraining()
                                    exercise.id = e["id"] as! Int
                                    exercise.name = e["name"] as! String
                                    exercise.exerciseId = e["exerciseId"] as! Int
                                    let exerciseIterations = List<Iteration>()
                                    if let iterations = e["iterations"] as? [[String:Any]] {
                                        for i in iterations {
                                            let iteration = Iteration()
                                            iteration.id = i["id"] as! Int
                                            iteration.exerciseInTrainingId = i["exerciseInTrainingId"] as! Int
                                            iteration.counts = i["counts"] as! Int
                                            iteration.weight = i["weight"] as! Int
                                            iteration.restTime = i["restTime"] as! Int
                                            iteration.workTime = i["workTime"] as! Int
                                            exerciseIterations.append(iteration)
                                        }
                                    }
                                    exercise.iterations = exerciseIterations
                                    exercisesInDay.append(exercise)
                                }
                            }
                            day.exercises = exercisesInDay
                            daysInWeek.append(day)
                        }
                    }
                    week.days = daysInWeek
                    training.weeks.append(week)
                }
            }
            items.append(training)
        }
        dataSource?.set(trainings: items)
        dataSource?.currentTraining = items.first
        self.saveTrainingsToRealm(trainings: items)
        self.view?.trainingsLoaded()
    }
    
    
    
}
