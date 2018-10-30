//
//  NewExerciseDataSource.swift
//  MSA
//
//  Created by Pavlo Kharambura on 7/1/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import Foundation

class NewExerciseDataSource {
    
    static let shared = NewExerciseDataSource()

    var imagesEdited = false
    var editMode = false
    var newExerciseModel = Exercise() {
        didSet {
            name = newExerciseModel.name
            typeId = newExerciseModel.realTypeId
            filterId = newExerciseModel.filterIDs.first?.id ?? -1
            descript = newExerciseModel.exerciseDescriprion
            howToDo = newExerciseModel.howToDo
            picturesUrls = Array(newExerciseModel.pictures)
            videoUrl = newExerciseModel.videoUrl
        }
    }
        
    var name = ""
    var typeId = -1
    var filterId = -1
    var descript = ""
    var howToDo = ""
    var pictures: [Data] = []
    var picturesUrls: [Image] = []
    var videoUrl = ""
    var videoPath = ""
    
    var curretnTextViewTag = 0
    
    var createButtonTapped = false
}
