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
import Instabug
import Bugsnag
import SwiftRater
import AVKit
import Amplitude

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var timeInBackground: Int = 0

  var window: UIWindow?
  let realmVersion: UInt64 = 0
  let defaults = UserDefaults.standard
  let pushManager = PushNotificationManager()
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let schemeName = Bundle.main.infoDictionary!["CURRENT_SCHEME_NAME"] as! String
    print("Scheme name = \(schemeName)")

    FirebaseApp.configure()
    Instabug.start(withToken: "031800b655ec71682ba7e49b1eb649cd", invocationEvents: [.shake, .screenshot])
    Instabug.setLocale(.russian)
  
    BugReporting.shouldCaptureViewHierarchy = true
    Bugsnag.start()
   
    let config = Realm.Configuration(
      schemaVersion: realmVersion,
      migrationBlock: { migration, oldSchemaVersion in
        self.performMigration(migration: migration, oldSchemaVersion: oldSchemaVersion)
    })
    Realm.Configuration.defaultConfiguration = config
    
    ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    
    IQKeyboardManager.shared.enable = true
    MSAppCenter.start("aa023993-9184-4c58-8f34-84dfdb1fb199", withServices:[MSAnalytics.self, MSCrashes.self])
    Amplitude.instance()?.initializeApiKey("af115dbe191333220b83850908f6b50b")
    
    configureProgressHud()
    initialConf()
    setupIAPObserver()
    
    let start = StratCoordinator(nav: window?.rootViewController as! UINavigationController)
    start.start()
    logSessionEvent()
   
    UIApplication.shared.applicationIconBadgeNumber = 0
    UITabBar.appearance().barTintColor = UIColor.white // your color
    UITabBar.appearance().tintColor = .newBlue
    UITabBar.appearance().layer.borderWidth = 0.0
    UITabBar.appearance().clipsToBounds = true
    
    Siren.shared.presentationManager = PresentationManager(forceLanguageLocalization: .russian)
    Siren.shared.rulesManager = RulesManager(globalRules: .critical,
                                      showAlertAfterCurrentVersionHasBeenReleasedForDays: 1)

    Siren.shared.wail()
   
    SwiftRater.daysUntilPrompt = 7
    SwiftRater.usesUntilPrompt = 5
    SwiftRater.significantUsesUntilPrompt = 3
    SwiftRater.daysBeforeReminding = 7
    SwiftRater.showLaterButton = true
    SwiftRater.debugMode = false
    SwiftRater.countryCode = "ru"
    SwiftRater.appLaunched()
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
    timeInBackground = Int(Date().timeIntervalSince1970)
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AppComeToBackground"), object: nil)
    print("Enter background timer v1 = Date:\(Date())")
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    //        registerNotification()
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    
    let timeDifference = Int(Date().timeIntervalSince1970) - timeInBackground > 0 ? Int(Date().timeIntervalSince1970) - timeInBackground - 1 : Int(Date().timeIntervalSince1970) - timeInBackground
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AppComeFromBackground"), object: timeDifference)
    print("Timer value v1 = \(Int(Date().timeIntervalSince1970)-timeInBackground)) - Date:\(Date())")
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
    SVProgressHUD.setForegroundColor(.newBlue)
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
        AnalyticsSender.shared.logEvent(eventName: "session_start_7days")
      } else if diff > 24 {
        AnalyticsSender.shared.logEvent(eventName: "session_start_48h")
      } else {
        AnalyticsSender.shared.logEvent(eventName: "session_start_24h")
      }
      print(diff)
    }
    defaults.set(Date(), forKey: "latestSession")
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
          switch AuthModule.currUser.userType {
            case .sportsman:
              AnalyticsSender.shared.logEvent(eventName: "in_app_p_sportsman")
              if transaction.payment.productIdentifier == "s_one_month" {
                AnalyticsSender.shared.logEvent(eventName: "in_app_p_sportsman")
              } else if transaction.payment.productIdentifier == "s_twelve_month" {
                AnalyticsSender.shared.logEvent(eventName: "in_app_p_sportsman_1y")
              } else if transaction.payment.productIdentifier == "s_fullAcess" {
                AnalyticsSender.shared.logEvent(eventName: "in_app_p_sportsman_fullAccess")
              }
            case .trainer:
              AnalyticsSender.shared.logEvent(eventName: "in_app_p_coach")
              if transaction.payment.productIdentifier == "t_one_month" {
                AnalyticsSender.shared.logEvent(eventName: "in_app_p_coach_1m")
              } else if transaction.payment.productIdentifier == "t_twelve_month" {
                AnalyticsSender.shared.logEvent(eventName: "in_app_p_coach_1y")
              } else if transaction.payment.productIdentifier == "t_fullAcess" {
                AnalyticsSender.shared.logEvent(eventName: "in_app_p_coach_fullAcsess")
              }
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
    AnalyticsSender.shared.logEvent(eventName: "in_app_p_restored", params: ["subscription": transaction.payment.productIdentifier])
    queue.finishTransaction(transaction)
  }
  
  func handleFailedState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
    queue.finishTransaction(transaction)
    print("Purchase failed for product id: \(transaction.payment.productIdentifier)")
    
  }
  
  func handleDeferredState(for transaction: SKPaymentTransaction, in queue: SKPaymentQueue) {
    queue.finishTransaction(transaction)
    print("Purchase deferred for product id: \(transaction.payment.productIdentifier)")
  }
}

extension AppDelegate {
  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
       let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url)
       if dynamicLink != nil {
            print("Dynamic link : \(String(describing: dynamicLink?.url))")
            return true
       }
       return false
  }
  
  func application(_ application: UIApplication, continue userActivity:
  NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
       guard let inCommingURL = userActivity.webpageURL else { return false }
       print("Incomming Web Page URL: \(inCommingURL)")
       shareLinkHandling(inCommingURL)
       return true
  }
  
  fileprivate func shareLinkHandling(_ inCommingURL: URL) {
    
    _ = DynamicLinks.dynamicLinks().handleUniversalLink(inCommingURL) { (dynamiclink, error) in
      
      guard error == nil else {
        print("Found an error: \(error?.localizedDescription ?? "")")
        return
      }
      print("Dynamic link : \(String(describing: dynamiclink?.url))")
      let path = dynamiclink?.url?.path
      var userId = ""
      if let range = path?.range(of: "/users=") {
         let id = path?[range.upperBound...]
         userId = id?.description ?? ""
      }
      if userId != "" {
        if let window = self.window, let rootViewController = window.rootViewController {
               var currentController = rootViewController
               while let presentedController = currentController.presentedViewController {
                   currentController = presentedController
               }
              let vc = newProfileStoryboard.instantiateViewController(withIdentifier: "NewProfileViewController") as! NewProfileViewController
               vc.viewModel = ProfileViewModel()
               vc.viewModel?.selectedUserId = userId
               let nc = UINavigationController(rootViewController: vc)
               nc.modalPresentationStyle = .fullScreen
               currentController.present(nc, animated: true, completion: nil)
          }
      }
    }
  
  }
}
