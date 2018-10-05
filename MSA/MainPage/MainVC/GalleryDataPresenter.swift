//
//  GalleryDataPresenter.swift
//  MSA
//
//  Created by Pavlo Kharambura on 4/17/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import Foundation
import CoreData
import Firebase
import UIKit

class GalleryDataPresenter: ProfileGalleryDataPresenterProtocol {
    
    
    
    private let gallery: GalleryDataManager
    private weak var view: GalleryDataProtocol?
    private weak var profileView: ProfileViewController?
    
    init(gallery: GalleryDataManager) {
        self.gallery = gallery
    }
    
    func attachView(view: GalleryDataProtocol){
        self.view = view
    }
    
    func attachView(view: ProfileViewController) {
        self.profileView = view
    }

    
    func addItem(item: GalleryItemVO) {
        GalleryDataManager.addItem(item: item)
        view?.galleryLoaded()
    }
    func clear() {
        gallery.clear()
    }
    
    func getItems() -> [GalleryItemVO] {
        return GalleryDataManager.GalleryItems
    }
    
    func uploadVideo(_ path: String,_ img: UIImage) {
        if let id = AuthModule.currUser.id {
            self.view?.startLoading()
            Storage.storage().reference().child(id).child(path).putFile(from: URL(string:path)!, metadata: nil, completion: { (metadata, error) in
                self.view?.finishLoading()
                if error == nil {
                    self.view?.videoLoaded(url: (metadata?.downloadURL()?.absoluteString)!, and: img)
                } else {
                    print(error?.localizedDescription)
                }
            })
        }
    }
    
    func updateGalleryItems(items: [GalleryItemVO]) {
        var params = [[String:Any]]()
        for item in items {
            params.append(["imageData":item.imageUrl,"videoUrl":item.video_url,"videoPath":item.videoPaht])
        }
        self.view?.startLoading()
        let gallery = ["gallery":params] as [String:Any]
        if let id = AuthModule.currUser.id {
            Database.database().reference().child("Users").child(id).updateChildValues(gallery, withCompletionBlock: { (error, ref) in
                    self.view?.finishLoading()
            })
        }
    }
    
    func deleteGaleryItem(index: Int) {
        view?.startLoading()
        if let id = AuthModule.currUser.id {
            Database.database().reference().child("Users").child(id).child("gallery").child("\(index)").removeValue(completionBlock: { (error, ref) in
                self.view?.finishLoading()
                if error == nil {
                    GalleryDataManager.GalleryItems.remove(at: index)
                    self.view?.galleryLoaded()
                } else {
                    if let err = error?.localizedDescription {
                        self.view?.errorOccurred(err: err)
                    }
                }
            })
        }
    }
    
    func getGallery(for userID: String?) {
        if let id = userID {
            print(id)
           self.view?.startLoading()
            Database.database().reference().child("Users").child(id).child("gallery").observeSingleEvent(of: .value, with: { (snapchot) in
                self.view?.finishLoading()
                var items = [GalleryItemVO]()
                for snap in snapchot.children {
                    let s = snap as! DataSnapshot
                    let item = GalleryItemVO(imageUrl: s.childSnapshot(forPath: "imageData").value as? String, videoPaht: s.childSnapshot(forPath: "videoPath").value as? String, video_url: s.childSnapshot(forPath: "videoUrl").value as? String)
                    items.append(item)
                }
                GalleryDataManager.GalleryItems = items
                self.view?.galleryLoaded()
            })
        }
    }

    func uploadPhoto(image: UIImage) {
        view?.startLoading()
        gallery.uploadPhoto(chosenImage: image) { (data, error) in
            self.view?.finishLoading()
            if error == nil {
                do {
                    let jsonResp = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:Any]
                    if let myData = jsonResp["data"] as? [String:Any] {
                        if let url = myData["link"] as? String {
                            self.setCurrentImgUrl(url: url)
                            self.view?.photoUploaded()
                        }
                    }
                } catch {
                    self.view?.errorOccurred(err: error.localizedDescription)
                }
            }
        }
    }
    
    func setCurrentImgUrl(url: String) {
        gallery.setCurrItemUrl(url: url)
    }
    func setCurrentVideoUrl(url: String) {
        gallery.setCurrItemVideoUrl(url: url)
    }
    func setCurrentVideoPath(path: String) {
        gallery.setCurrItemVideoPath(path: path)
    }
    func getCurrentItem() -> GalleryItemVO{
        return gallery.currentItem
    }
    
    func deleteGalleryBlock(context: NSManagedObjectContext) {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "GalleryItem")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            let _ = try context.execute(request)
        } catch {}
    }
    
    func saveGallery(context: NSManagedObjectContext) {
        DispatchQueue.main.async {
            for item in GalleryDataManager.GalleryItems {
                let task = GalleryItem(context: context)
                if let imageUrl = item.imageUrl {
                    task.imageUrl = imageUrl
                }
                if let path = item.videoPaht {
                    task.videoPath = path
                }
                if let url = item.video_url {
                    task.video_Url = url
                }
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            }
        }
    }
    
    func getGallery(context: NSManagedObjectContext) {
        var gallery = [GalleryItemVO]()
        do {
            let gallery_: [GalleryItem] = try context.fetch(GalleryItem.fetchRequest())
            for item_ in gallery_ {
                if let imageUrl = item_.imageUrl {
                    var item = GalleryItemVO(imageUrl: imageUrl, videoPaht: nil, video_url: nil)
                    if let url = item_.video_Url {
                        item.video_url = url
                    }
                    if let path = item_.videoPath {
                        item.videoPaht = path
                    }
                        gallery.append(item)
                }
            }
            GalleryDataManager.GalleryItems = gallery
            self.view?.galleryLoaded()
        } catch {
            print("Fetching Failed")
        }
    }
}
