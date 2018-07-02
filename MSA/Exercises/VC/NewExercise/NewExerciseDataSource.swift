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

    var newExerciseModel = Exercise()
 
    var name = ""
    var typeId = -1
    var filterId = -1
    var descript = ""
    var howToDo = ""
    var pictures: [Data] = []
    var video = ""
    
    var curretnTextViewTag = 0
    
}
