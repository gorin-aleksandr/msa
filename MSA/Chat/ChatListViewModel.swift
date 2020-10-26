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
  let pushManager = PushNotificationManager()

  init() {  }
  
  func getChatList(success: @escaping ()->(),failedBlock: @escaping ()->()) {
    if let userId = AuthModule.currUser.id {
      let docRef = db.collection("UsersChat").document(userId).collection("Chats").order(by: "timeStamp", descending: true)
      
      docRef.addSnapshotListener { querySnapshot, error in
          guard let documents = querySnapshot?.documents else {
              print("Error fetching documents: \(error!)")
              return
          }
           var chatsNew: [Chat] = []
               for item in documents {
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
    } else {
      failedBlock()
    }


  }
  

}

