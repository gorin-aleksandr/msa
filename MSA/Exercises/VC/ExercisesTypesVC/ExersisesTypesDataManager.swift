//
//  ExersisesTypesDataManager.swift
//  MSA
//
//  Created by Pavlo Kharambura on 6/23/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import Foundation

class ExersisesDataManager {
    
    var exersiseTypes: [ExerciseType] = []
    var currentExerciseeType = ExerciseType()
    
    var ownExercises: [Exercise] = []
    var allExersises: [Exercise] = []
    var currentTypeExercisesArray: [Exercise] = []
    var currentExercise: Exercise? = nil
    
    var allFilters: [ExerciseTypeFilter] = []
    var currentFilters: [ExerciseTypeFilter] = []
    
}
