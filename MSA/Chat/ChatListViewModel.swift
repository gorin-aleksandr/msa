//
//  SignInViewModel.swift
//  m2mMarket
//
//  Created by Nik on 4/24/18.
//  Copyright © 2018 m2mMarket. All rights reserved.
//

import UIKit
import Firebase

class ChatListViewModel {
  
  let db = Firestore.firestore()
  var chats: [Chat] = []
  
  init() {  }
  
  func getChatList(success: @escaping ()->(),failedBlock: @escaping ()->()) {
    let docRef = db.collection("UsersChat").document(AuthModule.currUser.id!).collection("Chats")
    
    docRef.getDocuments { (document, error) in
      print(document!.documents)
      var chatsNew: [Chat] = []
      for item in document!.documents {
        print(item)
        let chatId = item["chatId"] as! String
        let chatUserId = item["chatUserId"] as! String
        let chatUserName = item["chatUserName"] as! String
        let lastMessage = item["lastMessage"] as! String
        let userAvatar = item["chatUserAvatar"] as! String
        let lastAction = item["lastAction"] as! String
        let newMessages = item["newMessages"] as! Bool
        let chat = Chat(id: chatId, chatUserId: chatUserId, chatUserName: chatUserName, lastMessage: lastMessage, userAvatar: userAvatar, lastAction: lastAction, newMessages: newMessages)
        chatsNew.append(chat)
      }
      self.chats = chatsNew
      success()
    }
  }
}

