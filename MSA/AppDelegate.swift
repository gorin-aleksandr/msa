//
//  AppDelegate.swift
//  MSA
//
//  Created by Pavlo Kharambura on 2/15/18.
//  Copyright © 2018 easyapps.solutions. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import FBSDKCoreKit
import CoreData
import RealmSwift
import SVProgressHUD
import StoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var timeInBackground: Int = 0
    
    var window: UIWindow?
    let realmVersion: UInt64 = 0

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let config = Realm.Configuration(
            schemaVersion: realmVersion,
            migrationBlock: { migration, oldSchemaVersion in
                self.performMigration(migration: migration, oldSchemaVersion: oldSchemaVersion)
        })
        Realm.Configuration.defaultConfiguration = config
        
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        FirebaseApp.configure()
        IQKeyboardManager.sharedManager().enable = true
        
        configureProgressHud()
        initialConf()

        let start = StratCoordinator(nav: window?.rootViewController as! UINavigationController)
        start.start()

        return true
    }
    
    fileprivate func performMigration(migration: Migration, oldSchemaVersion: UInt64) {
        if (oldSchemaVersion < self.realmVersion) {
            //MARK: Migration of realm
            migrationToNewVersion(migration: migration)
        }
    }
    
    private func migrationToNewVersion(migration: Migration) {

    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        
        return handled
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        timeInBackground = Int(Date().timeIntervalSince1970)
//        registerNotification()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AppComeFromBackground"), object: Int(Date().timeIntervalSince1970)-timeInBackground)
//        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MSA")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    private func configureProgressHud() {
        SVProgressHUD.setBackgroundColor(.clear)
        SVProgressHUD.setForegroundColor(.lightBlue)
    }

    private func initialConf() {
        window?.backgroundColor = .white
    }
    
    private func setupIAPObserver() {
        SKPaymentQueue.default().add(self)
    }
    
//
//    private func registerNotification() {
//        let content = UNMutableNotificationContent()
//
//        content.title = "Подход в тренировке подходит к концу!"
//        content.subtitle = "Продолжите тренировку!"
//        content.body = "Следующий подход начнеться когда вы зайдете в приложение"
//        content.badge = 0
//
//        if NotificationTimer.timeToShow > 0 {
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: NotificationTimer.timeToShow, repeats: false)
//            let request = UNNotificationRequest(identifier: "SimplifiedIOSNotification", content: content, trigger: trigger)
//            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
//        }
//    }
}

extension AppDelegate: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue,
                      updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                handlePurchasingState(for: transaction, in: queue)
            case .purchased:
                handlePurchasedState(for: transaction, in: queue)
            case .restored:
                handleRestoredState(for: transaction, in: queue)
            case .failed:
                handleFailedState(for: transaction, in: queue)
            case .deferred:
                handleDeferredState(for: transaction, in: queue)
            }
        }
        
    }
    
    func handlePurchasingState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("User is attempting to purchase product id: \(transaction.payment.productIdentifier)")
    }
    
    func handlePurchasedState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("User purchased product id: \(transaction.payment.productIdentifier)")
        queue.finishTransaction(transaction)
        InAppPurchasesService.shared.uploadReceipt { (success) in
            DispatchQueue.main.async {
                if success {
                       NotificationCenter.default.post(name: InAppPurchasesService.restoreSuccessfulNotification, object: nil)
                } else {
                    print("Ошибка же")
                }
             
            }
        }
    }
    
    func handleRestoredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase restored for product id: \(transaction.payment.productIdentifier)")
        
    }
    
    func handleFailedState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase failed for product id: \(transaction.payment.productIdentifier)")
    
    }
    
    func handleDeferredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase deferred for product id: \(transaction.payment.productIdentifier)")
    }
}

