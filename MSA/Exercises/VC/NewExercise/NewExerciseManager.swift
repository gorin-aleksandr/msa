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
    private var view: NewExerciseProtocol?
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
    
    func uploadVideo(_ path: String, success: @escaping (_ bool: Bool)->()) {
        if let _ = AuthModule.currUser.id {
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
                            var filters = [[String:Any]]()
                            filters.append(["id":self.dataSource.filterId])
                            var pictures = [[String:Any]]()
                            for url in self.dataSource.picturesUrls {
                                pictures.append(["url": url.url])
                            }
                            let index = RealmManager.shared.getArray(ofType: Exercise.self).count
                            let newInfo = [
                                "description": self.dataSource.descript,
                                "howToDo": self.dataSource.howToDo,
                                "filterIDs":filters,
                                "id":index,
                                "link": self.dataSource.newExerciseModel.link,
                                "name": self.dataSource.name,
                                "pictures": pictures,
                                "trainerId": id,
                                "typeId": self.dataSource.typeId,
                                "videoUrl": self.dataSource.videoUrl
                                ] as [String:Any]
                            self.exerciseRef.child("\(index)").setValue(newInfo) { (error, databaseFer) in
                                self.view?.finishLoading()
                                if error == nil {
                                    self.view?.exerciseCreated()
                                } else {
                                    self.view?.errorOccurred(err: error?.localizedDescription ?? "Unknown error")
                                }
                            }
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
