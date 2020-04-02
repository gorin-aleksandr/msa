//
//  Chat.swift
//  MSA
//
//  Created by Nik on 30.03.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import Foundation

class Chat {
  var id: String
  var chatUserId: String
  var chatUserName: String
  var lastMessage: String
  var userAvatar: String
  var lastAction: String
  var newMessages: Bool


  init(id: String, chatUserId: String, chatUserName: String, lastMessage: String, userAvatar: String, lastAction: String, newMessages: Bool) {
    self.id = id
    self.chatUserId = chatUserId
    self.chatUserName = chatUserName
    self.lastMessage = lastMessage
    self.userAvatar = userAvatar
    self.lastAction = lastAction
    self.newMessages = newMessages
  }
}
