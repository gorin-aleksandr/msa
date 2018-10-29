//
//  NewExerciseManager.swift
//  MSA
//
//  Created by Pavlo Kharambura on 7/1/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import Foundation
import RealmSwift
import Firebase

class NewExerciseManager {
    
    static let shared = NewExerciseManager()
    var dataSource = NewExerciseDataSource()
    private weak var view: NewExerciseProtocol?
    let exerciseRef = Database.database().reference().child("Exercise")
    //    let typesRef = Database.database().reference().child("<#T##pathString: String##String#>")
    func setName(name: String) {
        dataSource.name = name
    }
    
    func created() -> Bool {
        return dataSource.createButtonTapped
    }
    
    func attachView(view: NewExerciseProtocol) {
        self.view = view
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
    
    func setVideo(url: String) {
        dataSource.videoUrl = url
    }
    func deleteVideo() {
        dataSource.videoUrl = ""
    }
    func makeImagesForExersice(urls: [String]) {
        var images = [Image]()
        for url in urls {
            let image = Image()
            image.url = url
            images.append(image)
        }
        dataSource.picturesUrls = images
        self.view?.photoUploaded()
    }
    
    func addPictures(picData: Data) {
        dataSource.pictures.append(picData)
    }
    func deletePicture(at index: Int) {
        dataSource.pictures.remove(at: index)
    }
    
    func finish() {
        dataSource.name = ""
        dataSource.typeId = -1
        dataSource.filterId = -1
        dataSource.descript = ""
        dataSource.howToDo = ""
        dataSource.pictures = []
        dataSource.picturesUrls = []
        dataSource.videoUrl = ""
        dataSource.videoPath = ""
        dataSource.curretnTextViewTag = 0
        dataSource.createButtonTapped = false
    }
    
    func uploadVideo(_ path: String, success: @escaping (_ bool: Bool)->()) {
        if let _ = AuthModule.currUser.id {
            if path == "" {
                success(true)
            } else {
                Storage.storage().reference().child("ExercisesVideoUrls").child(path).putFile(from: URL(string:path)!, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        self.view?.errorOccurred(err: error?.localizedDescription ?? "")
                        success(false)
                    } else {
                        self.view?.videoLoaded(url: (metadata?.downloadURL()?.absoluteString)!)
                        success(true)
                    }
                })
            }
        }
    }
    
    func sendNewExerciseInfoBlock(id: String, completion: @escaping ()->()) {
        let newInfo = makeExerciseForFirebase(id: id, or: false)
        guard let index = newInfo["id"] as? String else {return}
        Database.database().reference().child("ExercisesByTrainers").child(id).child(index).setValue(newInfo) { (error, databaseFer) in
            self.view?.finishLoading()
            if error == nil {
                let ex = self.makeModel()
                RealmManager.shared.saveObject(ex, update: true)
//                let myEx = MyExercises()
//                myEx.myExercises = ex
//                myEx.id = UUID().uuidString
                self.view?.exerciseCreated()
                self.finish()
                completion()
            } else {
                self.view?.errorOccurred(err: error?.localizedDescription ?? "Unknown error")
            }
        }
    }
    
    func deleteExercise(deleted: @escaping ()->(), failure: @escaping (_ error: Error?)->()) {
        guard let id = AuthModule.currUser.id else { return }
        let newInfo = makeExerciseForFirebase(id: id, or: true)
        guard let index = newInfo["id"] as? String else {return}
        Database.database().reference().child("ExercisesByTrainers").child(id).child(index).removeValue { (error, ref) in
            self.finish()
            if error == nil {
                RealmManager.shared.deleteObject(self.dataSource.newExerciseModel)
                deleted()
            } else {
                failure(error)
            }
        }
    }
    
    func addExerciseToUser(id: String, ex: Exercise, completion: @escaping ()->(), failure: @escaping (_ error: Error?)->()) {
        fillData(exercise: ex)
        let newInfo = makeExerciseForFirebase(id: id, or: true)
        guard let index = newInfo["id"] as? String else {return}
        Database.database().reference().child("ExercisesByTrainers").child(id).child(index).setValue(newInfo) { (error, databaseFer) in
            if error == nil {
                completion()
                self.finish()
            } else {
                failure(error)
                self.finish()
            }
        }
    }
    
    func fillData(exercise: Exercise) {
        self.dataSource.newExerciseModel = exercise
    }
    
    func makeExerciseForFirebase(id: String, or edit: Bool) -> [String:Any] {
        var filters = [[String:Any]]()
        filters.append(["id":self.dataSource.filterId])
        var pictures = [[String:Any]]()
        for url in self.dataSource.picturesUrls {
            pictures.append(["url": url.url])
        }
        var index = String()
        if edit {
            index = dataSource.newExerciseModel.id
        } else {
            index = UUID().uuidString
        }
        return [
            "description": self.dataSource.descript,
            "howToDo": self.dataSource.howToDo,
            "filterIDs": filters,
            "id": index,
            "link": self.dataSource.newExerciseModel.link,
            "name": self.dataSource.name,
            "pictures": pictures,
            "trainerId": id,
            "realTypeId": self.dataSource.typeId,
            "typeId": 12,
            "videoUrl": self.dataSource.videoUrl,
            "own": 1
            ] as [String:Any]
    }
    
    func createNewExerciseInFirebase() {
        if let id = AuthModule.currUser.id {
            self.view?.startLoading()
            uploadVideo(dataSource.videoPath) { (success) in
                if success {
                    var images = [UIImage]()
                    for image in self.dataSource.pictures {
                        if let image = UIImage(data: image) {
                            images.append(image)
                        }
                    }
                    self.uploadPhoto(images: images, success: { (success) in
                        if success {
                            self.sendNewExerciseInfoBlock(id: id, completion: {})
                        } else {
                            self.view?.finishLoading()
                        }
                    })
                } else {
                    self.view?.finishLoading()
                }
            }
        }
    }
    
    func updateExerciseBlock(id: String) {
        let newInfo = makeExerciseForFirebase(id: id, or: true)
        //        let child = [self.dataSource.newExerciseModel.id:newInfo] as! [Int:Any]
        Database.database().reference().child("ExercisesByTrainers").child(id).child("\(self.dataSource.newExerciseModel.id)").updateChildValues(newInfo) { (error, databaseFer) in
            self.view?.finishLoading()
            if error == nil {
                DispatchQueue.main.async {
                    let ex = self.makeModel()
                    RealmManager.shared.saveObject(ex, update: true)
                    
                    self.view?.exerciseUpdated()
                    self.finish()
                }
            } else {
                self.view?.errorOccurred(err: error?.localizedDescription ?? "Unknown error")
            }
        }
    }
    
    func makeModel() -> Exercise {
        let exercise = Exercise()
        exercise.id = dataSource.newExerciseModel.id
        exercise.exerciseDescriprion = dataSource.descript
        let filt = Id()
        filt.id = dataSource.filterId
        exercise.filterIDs.append(filt)
        exercise.howToDo = dataSource.howToDo
        exercise.name = dataSource.name
        for image in dataSource.picturesUrls {
            exercise.pictures.append(image)
        }
        exercise.realTypeId = dataSource.typeId
        exercise.trainerId = AuthModule.currUser.id ?? ""
        exercise.typeId = 12
        exercise.videoUrl = dataSource.videoUrl
        return exercise
    }
    
    func updateNewExerciseInFirebase() {
        if let id = AuthModule.currUser.id {
            self.view?.startLoading()
            uploadVideo(dataSource.videoPath) { (success) in
                if success {
                    var images = [UIImage]()
                    if self.dataSource.imagesEdited {
                        for image in self.dataSource.pictures {
                            if let image = UIImage(data: image) {
                                images.append(image)
                            }
                        }
                        self.uploadPhoto(images: images, success: { (success) in
                            if success {
                                self.updateExerciseBlock(id: id)
                            } else {
                                self.view?.finishLoading()
                            }
                        })
                    } else {
                        self.updateExerciseBlock(id: id)
                    }
                } else {
                    self.view?.finishLoading()
                }
            }
        }
    }
    
    func uploadPhoto(images: [UIImage], success: @escaping (_ bool: Bool)->()) {
        let dispatchGroup = DispatchGroup()
        
        var pictureUrls = [String]()
        var errors = [Error]()
        
        for image in images {
            dispatchGroup.enter()
            GalleryDataManager().uploadPhoto(chosenImage: image) { (data, error) in
                if error == nil {
                    do {
                        let jsonResp = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                        if let myData = jsonResp["data"] as? [String:Any] {
                            if let url = myData["link"] as? String {
                                pictureUrls.append(url)
                            }
                        }
                        dispatchGroup.leave()
                    } catch {
                        errors.append(error)
                        dispatchGroup.leave()
                    }
                } else {
                    if let er = error {
                        errors.append(er)
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if errors.isEmpty {
                self.makeImagesForExersice(urls: pictureUrls)
                success(true)
            } else {
                success(false)
                self.view?.errorOccurred(err: "Error with photos uploading")
            }
        }
    }
    
}
