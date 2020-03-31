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
  var currentUserName = "\(AuthModule.currUser.firstName ?? "") \(AuthModule.currUser.lastName  ?? "")"
  var code  = ""
  var isValidCode = false

  init(chatId: String, chatUserId: String, chatUserName: String) {
    self.chatId = chatId
    self.chatUserId = chatUserId
    self.chatUserName = chatUserName
  }

  
}
    
