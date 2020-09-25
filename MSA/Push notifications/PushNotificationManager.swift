//
//  PushNotificationManager.swift
//  FirebaseStarterKit
//
//  Created by Florian Marcu on 1/28/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import Firebase
import FirebaseFirestore
import FirebaseMessaging
import UIKit
import UserNotifications
import AVKit

class PushNotificationManager: NSObject, MessagingDelegate, UNUserNotificationCenterDelegate {
   
    override init() {
        super.init()
    }

  func registerForPushNotifications() {
    UNUserNotificationCenter.current().delegate = self
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(
      options: authOptions,
      completionHandler: {_, _ in })
    Messaging.messaging().delegate = self
    
    DispatchQueue.main.async {
      UIApplication.shared.registerForRemoteNotifications()
    }
    updateFirestorePushTokenIfNeeded()
  }

    func updateFirestorePushTokenIfNeeded() {
        if let token = Messaging.messaging().fcmToken {
          print("token: \(token)")
          UserDataManager().updateFcmToken(token: token)
        }
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        updateFirestorePushTokenIfNeeded()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response)
    }
  
  
    // Function call when App is in foreground State

    func userNotificationCenter(_ center: UNUserNotificationCenter,
      willPresent notification: UNNotification,
      withCompletionHandler completionHandler: @escaping
     (UNNotificationPresentationOptions) -> Void) {
      print("Foreg")
    }

   // Function call when App in Background State

  func application(_ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable : Any],
    fetchCompletionHandler completionHandler: @escaping
   (UIBackgroundFetchResult) -> Void) {
    print("Backgrond")
   }
  
}
