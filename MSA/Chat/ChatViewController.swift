/*
 * Copyright (c) 2015 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import Photos
import Firebase
import FirebaseFirestore
import JSQMessagesViewController
import FirebaseAuth
import SDWebImage
import PhotoSlider

final class ChatViewController: JSQMessagesViewController {
  
  // MARK: Properties
  var hideView:UIView!
  let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
  
  var imageURLNotSetKey = "NOTSET"
  
 // var uploadImage = false
  //var uploadImageUrl:String?
  
  let db = Firestore.firestore()
  var ref: DatabaseReference!
  var viewModel: ChatViewModel?
  
  fileprivate lazy var storageRef: StorageReference = Storage.storage().reference(forURL: "gs://msa-progect.appspot.com")
  
  private var messages: [JSQMessage] = []
  private var photoMessageMap = [String: JSQPhotoMediaItem]()
  
  var firstMessage = ""
  var firstMessageProductId = 0
  var isAutoResponseShown = false
  
  private var localTyping = false
  var channel: Channel?
  
  var isTyping: Bool {
    get {
      return localTyping
    }
    set {
      localTyping = newValue
    }
  }
  
  lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
  lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
  
  // MARK: View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
  
    self.senderId = self.viewModel!.currentUserId
    actInd.frame = CGRect(x: 0, y: 0, width: 40, height: 40);
    actInd.center = self.view.center
    actInd.hidesWhenStopped = true
    actInd.style =
      UIActivityIndicatorView.Style.whiteLarge
    observeMessages()
    title = self.viewModel!.chatUserName
    // No avatars
    collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
    collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
    
    inputToolbar.toggleSendButtonEnabled()
    let button: UIButton = UIButton(type: UIButton.ButtonType.custom)
       button.setImage(UIImage(named: "convert_send"), for: .normal)
       button.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
       inputToolbar.contentView.rightBarButtonItem = button
    configureNavigationItem()
  }
  
  func configureNavigationItem() {
      let button2 = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(self.back))
      button2.tintColor = darkCyanGreen
      self.navigationItem.leftBarButtonItem = button2
    let attrs = [NSAttributedString.Key.foregroundColor: darkCyanGreen,
                 NSAttributedString.Key.font: UIFont(name: "Rubik-Medium", size: 17)!]
      self.navigationController?.navigationBar.titleTextAttributes = attrs
  }
  
  @objc func back() {
    self.navigationController?.dismiss(animated: true, completion: nil)
  }
  
  func showHUD() {
    self.view.addSubview(actInd)
    actInd.startAnimating()
  }
  
  func dismissHUD() {
    actInd.stopAnimating()
    actInd.removeFromSuperview()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    readAllMessages()
    isAutoResponseShown = false
    // observeTyping()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    
    readAllMessages()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    self.tabBarController?.tabBar.isTranslucent = false
    //self.tabBarController?.tabBar.isHidden = true
    self.tabBarController?.tabBar.layer.zPosition = 0
  }
  
  deinit {}
  
  func readAllMessages() {
    db.collection("UsersChat").document(self.viewModel!.currentUserId!).collection("Chats").document(self.viewModel!.chatId).updateData([
       "newMessages": false
     ])
     
  }
  
  // MARK: Collection view data source (and related) methods
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
    return messages[indexPath.item]
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return messages.count
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
    let message = messages[indexPath.item] // 1
    if message.senderId == senderId { // 2
      return outgoingBubbleImageView
    } else { // 3
      return incomingBubbleImageView
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
    
    let message = messages[indexPath.item]
    if message.senderId == senderId { // 1
      cell.textView?.textColor = UIColor.black // 2
    } else {
      cell.textView?.textColor = UIColor.white // 3
    }
    return cell
    
  }
  
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapCellAt indexPath: IndexPath!, touchLocation: CGPoint) {
    self.view.endEditing(true)
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
    
    let index = indexPath.row
    let message = messages[index]
    if message.isMediaMessage {
      if let msg = message.media as? JSQPhotoMediaItem {
        if let img = msg.image {
          let photoSlider = PhotoSlider.ViewController(images: [img])
          photoSlider.pageControl.isHidden = true
          present(photoSlider, animated: true, completion: nil)
        }
      }
    }
    
    self.view.endEditing(true)
  }
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
    return nil
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
    return 15
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView?, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString? {
    let message = messages[indexPath.item]
    switch message.senderId {
      case senderId:
        return nil
      default:
        guard let senderDisplayName = message.senderDisplayName else {
          assertionFailure()
          return nil
        }
        return NSAttributedString(string: senderDisplayName)
    }
  }
  
  // MARK: Firebase related methods
  
  private func observeMessages() {
    
    showHUD()
    let ref = db.collection("Chats")
     if self.viewModel!.chatId == "" {
       self.viewModel!.chatId = ref.document().documentID
     }
    db.collection("Chats").document(self.viewModel!.chatId).collection("Messages").order(by: "timeStamp", descending: false).addSnapshotListener { querySnapshot, error in
        guard let snapshot = querySnapshot else {
          print("Error fetching snapshots: \(error!)")
          return
        }
        
        if snapshot.documentChanges.count == 0 {
          self.dismissHUD()
        }
        snapshot.documentChanges.forEach { diff in
          if (diff.type == .added) {
            print("New message: \(diff.document.data())")
            let item = diff.document.data()
            
            
            if let id = item["senderId"] as? Int, let text = item["text"] as? String {
              self.addMessage(withId: "\(id)", name: "", text: text, date: item["date"] as! String)
              self.finishReceivingMessage()
            } else if let id = item["senderId"] as? String, let text = item["text"] as? String {
              self.addMessage(withId: "\(id)", name: "", text: text, date: item["date"] as! String)
              self.finishReceivingMessage()
            } else if let photoURL = item["photoURL"] as! String? {
              
              var ids = ""
              if let id = item["senderId"] as? Int {
                ids = "\(id)"
              } else if let id = item["senderId"] as? String {
                ids = id
              }
              
              let outgoing = ids == self.senderId
              if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: outgoing) {
                self.addPhotoMessage(withId: ids, key: "", mediaItem: mediaItem, date: item["date"] as! String)
                
                if photoURL.hasPrefix("gs://") {
                  self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil, hasPrefix: true)
                } else {
                  self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil, hasPrefix: false)
                }
              }
            } else {
              print(item)
            }
            
            if diff == snapshot.documentChanges.last {
              self.dismissHUD()
            }
          }
          if (diff.type == .modified) {
            print("Modified message: \(diff.document.data())")
          }
          if (diff.type == .removed) {
            print("Removed message: \(diff.document.data())")
          }
        }
      }
    

  }
  
  private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?, hasPrefix: Bool) {
    
    
    if hasPrefix {
      let storageRef = Storage.storage().reference(forURL: photoURL)
      storageRef.getData(maxSize: INT64_MAX) { (data, error) in
        if let error = error {
          print("Error downloading image data: \(error)")
          return
        }
        
        storageRef.getMetadata(completion: { (metadata, metadataErr) in
          if let error = metadataErr {
            print("Error downloading metadata: \(error)")
            return
          }
          
          if (metadata?.contentType == "image/gif") {
            mediaItem.image = UIImage.gifWithData(data!)
          } else {
            mediaItem.image = UIImage.init(data: data!)
          }
          self.collectionView.reloadData()
          
          guard key != nil else {
            return
          }
          self.photoMessageMap.removeValue(forKey: key!)
        })
      }
    } else {
      
      SDWebImageManager.shared().imageDownloader?.downloadImage(with: URL(string: photoURL), options: .continueInBackground, progress: { (value, second, url) in
        
      }, completed: { (image, data, error, value) in
        mediaItem.image = image
        self.collectionView.reloadData()
        
      })
    }
    
  }
  
  private func observeTyping() {
    //    let typingIndicatorRef = channelRef!.child("typingIndicator")
    //    userIsTypingRef = typingIndicatorRef.child(senderId)
    //    userIsTypingRef.onDisconnectRemoveValue()
    //    usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqual(toValue: true)
    //
    //    usersTypingQuery.observe(.value) { (data: DataSnapshot) in
    //
    //      // You're the only typing, don't show the indicator
    //      if data.childrenCount == 1 && self.isTyping {
    //        return
    //      }
    //
    //      // Are there others typing?
    //      self.showTypingIndicator = data.childrenCount > 0
    //      self.scrollToBottom(animated: true)
    //    }
  }
  
  override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
       
    db.collection("Chats").document(self.viewModel!.chatId).collection("Messages").addDocument(data: [
      "senderId": self.viewModel!.currentUserId!,
      "senderName": viewModel!.currentUserName,
      "text": text!,
      "date" : nowDateString(),
      "timeStamp": FieldValue.serverTimestamp()
    ])
    
    //for me
  db.collection("UsersChat").document(self.viewModel!.currentUserId!).collection("Chats").document(self.viewModel!.chatId).setData([
      "chatId": self.viewModel!.chatId,
      "chatUserId": viewModel!.chatUserId,
      "chatUserName": viewModel!.chatUserName,
      "chatUserAvatar": viewModel!.chatUserAvatar ?? viewModel!.chatUser?.avatar ?? "",
      "newMessages": false,
      "lastMessage": text!,
      "lastAction": nowDateString(),
      "timeStamp": FieldValue.serverTimestamp()
    ])
    
    //for user
    db.collection("UsersChat").document(viewModel!.chatUserId).collection("Chats").document(self.viewModel!.chatId).setData([
      "chatId": self.viewModel!.chatId,
      "chatUserId": self.viewModel!.currentUserId!,
      "chatUserName": viewModel!.currentUserName,
      "chatUserAvatar": viewModel!.currentUserAvatar,
      "newMessages": true,
      "lastMessage": text!,
      "lastAction": nowDateString(),
      "timeStamp": FieldValue.serverTimestamp()
    ])
    
    
    
    // 4
    JSQSystemSoundPlayer.jsq_playMessageSentSound()
    
    // 5
    finishSendingMessage()
    isTyping = false
    
    //    M2mProvider.request(.sendChatMessagePush(title: name,body: text!)) { (result) in
    //    }
    
  }
  
  func sendPhotoMessage() -> String? {
    
    //productId": firstMessageProductId,
    
    var messageItem = [
      "photoURL": imageURLNotSetKey,
      "senderId": self.viewModel!.currentUserId!,
      "senderName": viewModel!.currentUserName,
      "timeStamp": FieldValue.serverTimestamp(),
      "date" : nowDateString()
      ] as [String : Any]

        
    db.collection("Chats").document(self.viewModel!.chatId).collection("Messages").addDocument(data: messageItem)
    
    
    //for me
    db.collection("UsersChat").document(self.viewModel!.currentUserId!).collection("Chats").document(self.viewModel!.chatId).setData([
      "chatId": self.viewModel!.chatId,
      "chatUserId": viewModel!.chatUserId,
      "chatUserName": viewModel!.chatUserName,
      "chatUserAvatar": viewModel!.chatUserAvatar ?? viewModel!.chatUser?.avatar ?? "",
      "newMessages": false,
      "lastMessage": "Фотография 🖼",
      "lastAction": nowDateString(),
      "timeStamp": FieldValue.serverTimestamp()
    ])
    
    //for user
    db.collection("UsersChat").document(viewModel!.chatUserId).collection("Chats").document(self.viewModel!.chatId).setData([
      "chatId": self.viewModel!.chatId,
      "chatUserId": self.viewModel!.currentUserId!,
      "chatUserName": viewModel!.currentUserName,
      "chatUserAvatar": viewModel!.currentUserAvatar,
      "newMessages": true,
      "lastMessage": "Фотография 🖼",
      "lastAction": nowDateString(),
      "timeStamp": FieldValue.serverTimestamp()
    ])
    
    JSQSystemSoundPlayer.jsq_playMessageSentSound()
    //let name  = "\(Defaults[.userLastName] ?? "\("801")") \(Defaults[.userFirstName] ?? "\("801")") " Имя и фамиля отправителя
    
//    if !uploadImage  {
//      //        M2mProvider.request(.sendChatMessagePush(title: name,body: "Отправил(а) Вам фото 🖼️")) { (result) in
//      //        }
//    } else {
//      uploadImage = false
//    }
    finishSendingMessage()
    return ""
    
  }
  
  //  func setImageURL(_ url: String, forPhotoMessageWithKey key: String) {
  //  }
  //
  // MARK: UI and User Interaction
  
  private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
    let bubbleImageFactory = JSQMessagesBubbleImageFactory()
    return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
  }
  
  private func setupIncomingBubble() -> JSQMessagesBubbleImage {
    let bubbleImageFactory = JSQMessagesBubbleImageFactory()
    return bubbleImageFactory!.incomingMessagesBubbleImage(with: darkCyanGreen)
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
       return 15
   }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView?, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString? {
      let message = messages[indexPath.item]
      switch message.senderId {
      case senderId:
          return NSAttributedString(string: "\(convertDateToString(date:message.date))")
      default:
          return NSAttributedString(string: "\(convertDateToString(date:message.date))")
      }
  }
  
  override func didPressAccessoryButton(_ sender: UIButton) {
    let picker = UIImagePickerController()
    picker.delegate = self
    let alert = UIAlertController(title: "", message: "Отправить фото", preferredStyle: .actionSheet)
    
    alert.addAction(UIAlertAction(title: "Сделать фото", style: .default , handler:{ (UIAlertAction) in
      picker.sourceType = UIImagePickerController.SourceType.camera
      self.present(picker, animated: true, completion:nil)
      
    }))
    
    alert.addAction(UIAlertAction(title: "Открыть галерею", style: .default , handler:{ (UIAlertAction) in
      picker.sourceType = UIImagePickerController.SourceType.photoLibrary
      self.present(picker, animated: true, completion:nil)
    }))
    
    alert.addAction(UIAlertAction(title: "Отменить", style: .cancel , handler:{ (UIAlertAction) in
    }))
    
    DispatchQueue.main.async {
      self.present(alert, animated: true, completion: {
        print("completion block")
        // self.present(picker, animated: true, completion:nil)
        
      })
    }
  }
  
  private func addMessage(withId id: String, name: String, text: String, date: String) {
    if let validDate = date.toDateTime() {
      if let message = JSQMessage(senderId: id, senderDisplayName: name, date: validDate, text: text) {
           messages.append(message)
         }
    }

  }
  
  private func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem, date: String) {
    if let validDate = date.toDateTime() {
      if let message = JSQMessage(senderId: id, senderDisplayName: "", date: validDate, media: mediaItem) {
        messages.append(message)
        if (mediaItem.image == nil) {
          photoMessageMap[key] = mediaItem
        }
        collectionView.reloadData()
      }
    }
  }
  
  // MARK: UITextViewDelegate methods
  
  override func textViewDidChange(_ textView: UITextView) {
    super.textViewDidChange(textView)
    // If the text is not empty, the user is typing
    isTyping = textView.text != ""
  }
  
}

// MARK: Image Picker Delegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

    picker.dismiss(animated: true, completion:nil)
    
    do {
      let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
      let fileURL = try documentsURL[0].appendingPathComponent("fileName.jpg")
      
      let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
      
      try (image as! UIImage).jpegData(compressionQuality: 0.0)?.write(to: fileURL, options: [])
      
      let path : String = "\(String(describing: Auth.auth().currentUser?.uid))/\(Int(Date.timeIntervalSinceReferenceDate * 1000))"
      self.storageRef.child(path).putFile(from: fileURL, metadata: nil) { (metadata, error) in
        if let error = error {
          print("Error uploading: \(error)")
          return
        }
        //    self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: self.sendPhotoMessage()!)
        
        self.imageURLNotSetKey = self.storageRef.child((metadata?.path)!).description
        self.sendPhotoMessage()
        
      }
    }
    catch {
      print("error is ", error)
    }
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion:nil)
  }
}
