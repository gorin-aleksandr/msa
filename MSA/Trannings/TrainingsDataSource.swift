//
//  TrainingsDataSource.swift
//  MSA
//
//  Created by Pavlo Kharambura on 8/30/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import Foundation

class TrainingsDataSource {
    
    static let shared = TrainingsDataSource()
    
    var trainings: [Training] = []
    var templates: [TrainingTemplate] = []
    var currentTraining: Training? = nil
    var currentDay: TrainingDay? = nil
    var currentExerciseInDay: ExerciseInTraining? = nil
    var currentIteration: Iteration? = nil
    var newTemplate: TrainingTemplate? = nil
    
    func set(trainings: [Training]) {
        self.trainings = trainings
    }
    
    func setCurrent(training: Training) {
        self.currentTraining = training
    }
    
    func templateCreated() {
        newTemplate = nil
    }
    
}
