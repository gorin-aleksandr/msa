//
//  ChatListViewController.swift
//  MSA
//
//  Created by Nik on 30.03.2020.
//  Copyright © 2020 Pavlo Kharambura. All rights reserved.
//

import UIKit
import SDWebImage
import SVProgressHUD

class ChatListViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  var viewModel: ChatListViewModel = ChatListViewModel()
  
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
      
      
    }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    SVProgressHUD.show()
    viewModel.getChatList(success: {
      self.setBadgeForChatCounter()
      self.tableView.reloadData()
      SVProgressHUD.dismiss()
    }) {
    }
  }
  
  func setBadgeForChatCounter() {
    var count = 0
    for chat in viewModel.chats {
      if chat.newMessages == true {
        count = count + 1
      }
    }
      super.tabBarController?.viewControllers![3].tabBarItem.badgeValue = count > 0 ? "\(count)" : nil
  }
  
  func setupUI() {
    tableView.tableFooterView = UIView()
    tableView.dataSource = self
    tableView.delegate = self
    let attrs = [NSAttributedString.Key.foregroundColor: darkCyanGreen,
                 NSAttributedString.Key.font: UIFont(name: "Rubik-Medium", size: 17)!]
    self.navigationController?.navigationBar.titleTextAttributes = attrs
    self.title = "Чаты"

  }

}

extension ChatListViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.viewModel.chats.count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell", for: indexPath) as! ChatListCell
    cell.selectionStyle = UITableViewCell.SelectionStyle.none
    let user = self.viewModel.chats[indexPath.row]
    cell.fullNameLabel.text = user.chatUserName
    cell.lastMessageLabel.text = user.lastMessage
    if user.userAvatar.isEmpty == false {
      cell.avatarImageView!.sd_setImage(with: URL(string: user.userAvatar), completed: nil)
    } else {
      cell.avatarImageView!.image = #imageLiteral(resourceName: "avatarPlaceholder")
    }
    if !user.newMessages {
      cell.newMessageDot.isHidden = true
    } else {
      cell.newMessageDot.isHidden = false
    }
    //cell.dateTimeLabel.text = user.lastAction
    cell.dateTimeLabel.isHidden = true
    return cell
  }
}

extension ChatListViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let chatViewController = chatStoryboard.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController
    let chat = self.viewModel.chats[indexPath.row]
    chatViewController?.viewModel = ChatViewModel(chatId: chat.id, chatUserId: chat.chatUserId, chatUserName: chat.chatUserName)
    chatViewController?.senderDisplayName = ""
    chatViewController?.firstMessage = ""
    chatViewController?.viewModel?.chatUserAvatar = chat.userAvatar
    let nc = UINavigationController(rootViewController: chatViewController!)
    nc.modalPresentationStyle = .fullScreen
    self.present(nc, animated: true, completion: nil)
  }
}
