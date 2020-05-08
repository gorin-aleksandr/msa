//
//  SignInViewModel.swift
//  m2mMarket
//
//  Created by Nik on 4/24/18.
//  Copyright © 2018 m2mMarket. All rights reserved.
//

import UIKit
import Firebase

class ChatViewModel {

  var chatUserId: String
  var chatUserName: String
  var chatUserAvatar: String?
  var chatUser: UserVO?
  var chatId: String
  var currentUserId = AuthModule.currUser.id
  var currentUserAvatar = AuthModule.currUser.avatar ?? ""
  var avatarImage: UIImage?
  var currentUserName = "\(AuthModule.currUser.firstName ?? "") \(AuthModule.currUser.lastName  ?? "")"
  var code  = ""
  var usersFcmToken  = ""
  var isValidCode = false
  let pushSender = PushNotificationSender()
  let userDataManager = UserDataManager()
  
  
  init(chatId: String, chatUserId: String, chatUserName: String) {
    self.chatId = chatId
    self.chatUserId = chatUserId
    self.chatUserName = chatUserName
  }

  func fetchFcmToken() {
    userDataManager.userRef.child(chatUserId).observeSingleEvent(of: .value, with: { (snapshot) in
        // Get user value
        let value = snapshot.value as? [String : Any]
      if let token = value?["fcmToken"] as? String {
        self.usersFcmToken = token
      }
    }) { (error) in
        print(error.localizedDescription)
    }
  }
  
  func sendPush(text: String) {
      pushSender.sendPushNotification(to: usersFcmToken, title: currentUserName, body: text)
  }
  
}
    
