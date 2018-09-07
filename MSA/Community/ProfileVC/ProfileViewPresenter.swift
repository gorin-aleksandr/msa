//
//  ProfileViewPresenter.swift
//  MSA
//
//  Created by Andrey Krit on 8/29/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import Foundation
import CoreData


protocol ProfileGalleryDataPresenterProtocol {
    func attachView(view: ProfileViewController)
    func clear()
    func getItems() -> [GalleryItemVO]
    func getGallery()
    func setCurrentImgUrl(url: String)
    func setCurrentVideoUrl(url: String)
    func setCurrentVideoPath(path: String)
    func getCurrentItem() -> GalleryItemVO
    func getGallery(context: NSManagedObjectContext)
    
}
