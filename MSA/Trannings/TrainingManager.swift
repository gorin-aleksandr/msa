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
    func errorOccurred(err: String)
}

class TrainingManager {
    
    let realm = RealmManager.shared
    private var dataSource: TrainingsDataSource?
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
        return dataSource?.currentTraining
    }
    func setCurrent(exercise: ExerciseInTraining) {
        dataSource?.currentExerciseInDay = exercise
    }
    func getCurrentExercise() -> ExerciseInTraining? {
        return dataSource?.currentExerciseInDay
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
    
    func saveTemplateToRealm(template: TrainingTemplate) {
        realm.saveObject(template)
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
    
    func loadTrainings() {
        if let id = AuthModule.currUser.id {
            self.view?.startLoading()
            Database.database().reference().child("Trainings").observeSingleEvent(of: .value) { (snapchot) in
                self.observeTrainings(snapchot: snapchot)
            }
        }
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
            training.trianerId = s.childSnapshot(forPath: "trainerId").value as! Int
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
        self.saveTrainingsToRealm(trainings: items)
        self.view?.trainingsLoaded()
    }
    
    
    
}
