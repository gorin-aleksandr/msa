//
//  StartCoordinator.swift
//  MSA
//
//  Created by Pavlo Kharambura on 5/8/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class StratCoordinator {
    
    var navContr: UINavigationController?
    var context: NSManagedObjectContext!
    
    init(nav: UINavigationController) {
        navContr = nav
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    func start()  {
        var loggedUser = UserVO()
        do {
            let user: [User] = try context.fetch(User.fetchRequest())
            loggedUser.id = user.first?.id
            loggedUser.avatar = user.first?.avatar
            loggedUser.email = user.first?.email
            loggedUser.firstName = user.first?.name
            loggedUser.lastName = user.first?.surname
            loggedUser.level = user.first?.level
            loggedUser.type = user.first?.type
            loggedUser.sex = user.first?.sex
            loggedUser.weightType = user.first?.weightType
            loggedUser.heightType = user.first?.heightType
            loggedUser.avatar = user.first?.avatar
            loggedUser.purpose = user.first?.purpose
            loggedUser.trainerId = user.first?.trainerId
            
            if let age = user.first?.age {
                loggedUser.age = Int(age)
            }
            if let height = user.first?.height {
                loggedUser.height = Int(height)
            }
            if let weight = user.first?.weight {
                loggedUser.weight = Int(weight)
            }
            if let _ = loggedUser.id {
                AuthModule.currUser = loggedUser
            }
            if let _ = AuthModule.currUser.id {
                let storyBoard = UIStoryboard(name: "Profile", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "tabBarVC") as! UITabBarController
                navContr?.show(nextViewController, sender: nil)
            } else {
                let storyBoard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "signInVC") as! UIViewController
                navContr?.show(nextViewController, sender: nil)
            }
        } catch {
            print("Fetching Failed")
        }
    }
    
}
