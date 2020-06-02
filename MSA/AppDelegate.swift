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
import CoreData
import RealmSwift
import SVProgressHUD
import StoreKit
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import FirebaseMessaging
import FBSDKLoginKit
import Siren


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var timeInBackground: Int = 0
    
    var window: UIWindow?
    let realmVersion: UInt64 = 0
    let defaults = UserDefaults.standard
    let pushManager = PushNotificationManager()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
  
        let config = Realm.Configuration(
            schemaVersion: realmVersion,
            migrationBlock: { migration, oldSchemaVersion in
                self.performMigration(migration: migration, oldSchemaVersion: oldSchemaVersion)
        })
        Realm.Configuration.defaultConfiguration = config
        
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true
        MSAppCenter.start("aa023993-9184-4c58-8f34-84dfdb1fb199", withServices:[MSAnalytics.self, MSCrashes.self])
        configureProgressHud()
        initialConf()
        
        setupIAPObserver()

        let start = StratCoordinator(nav: window?.rootViewController as! UINavigationController)
        start.start()
        logSessionEvent()
        logInAppPurhaseRenewalEvent()
        UIApplication.shared.applicationIconBadgeNumber = 0
        Siren.shared.presentationManager = PresentationManager(forceLanguageLocalization: .russian)
        Siren.shared.wail()
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


   func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
     ApplicationDelegate.shared.application( app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation] )
    return true
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
        UIApplication.shared.applicationIconBadgeNumber = 0
        let current = UNUserNotificationCenter.current()

      current.getNotificationSettings(completionHandler: { (settings) in
        if settings.authorizationStatus == .authorized {
          self.pushManager.registerForPushNotifications()
        }
      })

    }

    func applicationWillTerminate(_ application: UIApplication) {
        if !AuthModule.isLastUserCurrent {
            print("clear")
            RealmManager.shared.clearTrainings()
        }
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
  
    private func logSessionEvent() {
        if let latestSessionDate = defaults.object(forKey: "latestSession") as? Date {
          let cal = Calendar.current
          let currentDate = Date()
          let components = cal.dateComponents([.hour], from: latestSessionDate, to: currentDate)
          let diff = components.hour!
          if diff > 48 {
            Analytics.logEvent("session_start_7days", parameters: nil)
          } else if diff > 24 {
            Analytics.logEvent("session_start_48h", parameters: nil)
          } else {
            Analytics.logEvent("session_start_24h", parameters: nil)
          }
          print(diff)
        }
        defaults.set(Date(), forKey: "latestSession")
    }
   
    private func logInAppPurhaseRenewalEvent() {
        let defaults = UserDefaults.standard
        if let lastExpireDate = defaults.object(forKey: "inAppPurchaseExpireDate") as? Date {
          if let expireDate = InAppPurchasesService.shared.currentSubscription?.expiresDate {
            if lastExpireDate < expireDate {
              Analytics.logEvent("subscription_renewal", parameters: nil)
              switch AuthModule.currUser.userType {
                case .sportsman:
                Analytics.logEvent("subscription_renewal_sportsman", parameters: nil)
                case .trainer:
                Analytics.logEvent("subscription_renewal_coach", parameters: nil)
              }
              defaults.set(expireDate, forKey: "inAppPurchaseExpireDate")
            }
          } else {
            Analytics.logEvent("unsubscribe", parameters: nil)
            switch AuthModule.currUser.userType {
              case .sportsman:
              Analytics.logEvent("unsubscribe_sportsman", parameters: nil)
              case .trainer:
              Analytics.logEvent("unsubscribe_coach", parameters: nil)
            }
            defaults.set(nil, forKey: "inAppPurchaseExpireDate")
          }
        } else {
          if let expireDate = InAppPurchasesService.shared.currentSubscription?.expiresDate {
            defaults.set(expireDate, forKey: "inAppPurchaseExpireDate")
          }
        }
  }

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
                  Analytics.logEvent("in_app_purchase", parameters: nil)
                  switch AuthModule.currUser.userType {
                    case .sportsman:
                      Analytics.logEvent("in_app_p_sportsman", parameters: nil)
                    case .trainer:
                      Analytics.logEvent("in_app_p_coach", parameters: nil)
                  }
                       NotificationCenter.default.post(name: InAppPurchasesService.purchaseSuccessfulNotification, object: nil)
                } else {
                    print("Error appeared")
                }

            }
        }
    }
    
    func handleRestoredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase restored for product id: \(transaction.payment.productIdentifier)")
        NotificationCenter.default.post(name: InAppPurchasesService.restoreSuccessfulNotification, object: nil)

    }
    
    func handleFailedState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase failed for product id: \(transaction.payment.productIdentifier)")

    }
    
    func handleDeferredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
        print("Purchase deferred for product id: \(transaction.payment.productIdentifier)")
    }
}

