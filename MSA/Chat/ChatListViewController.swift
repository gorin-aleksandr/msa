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
import SPPermissions

class ChatListViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  var viewModel: ChatListViewModel = ChatListViewModel()
  var permissionController: SPPermissionsDialogController?

    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.show()
        viewModel.getChatList(success: {
          self.setBadgeForChatCounter()
          self.tableView.reloadData()
          SVProgressHUD.dismiss()
        }) {
        }
        setupUI()
        setupPermissionAlert()
    }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    
  }
  
  func setupPermissionAlert() {
    let defaults = UserDefaults.standard
    let mainPermission = defaults.bool(forKey: "allowedChatNotificationPermission")
    permissionController = SPPermissions.dialog([.notification])
       permissionController!.titleText = "Нужно разрешение"
       permissionController!.headerText = ""
       permissionController!.footerText = ""
       permissionController!.dataSource = self
       permissionController!.delegate = self
       let state = SPPermission.notification.isAuthorized
    if !state && !mainPermission {
       defaults.set(true, forKey: "allowedChatNotificationPermission")
          permissionController!.present(on: self)
        }
  }
  
  func setBadgeForChatCounter() {
    var count = 0
    for chat in viewModel.chats {
      if chat.newMessages == true {
        count = count + 1
      }
    }
      super.tabBarController?.viewControllers![2].tabBarItem.badgeValue = count > 0 ? "\(count)" : nil
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
    DispatchQueue.main.async {
        self.present(nc, animated: true, completion: nil)
    }
  }
}

extension ChatListViewController: SPPermissionsDataSource, SPPermissionsDelegate{
  func configure(_ cell: SPPermissionTableViewCell, for permission: SPPermission) -> SPPermissionTableViewCell {
    cell.permissionDescriptionLabel.text = "Получай уведомления о новых сообщениях в чате и новостях"
    cell.permissionTitleLabel.text = "Включи пуш - уведомления в настройках приложения"
    cell.button.allowTitle = "В настройки"
    cell.iconView.color = .darkCyanGreen
    cell.button.allowTitleColor = .darkCyanGreen
    cell.button.allowedBackgroundColor = .darkCyanGreen

    return cell
  }
  
  func didAllow(permission: SPPermission) {
  }
  
  func didDenied(permission: SPPermission) {
  if let bundleIdentifier = Bundle.main.bundleIdentifier, let appSettings = URL(string: UIApplication.openSettingsURLString + bundleIdentifier) {
    if UIApplication.shared.canOpenURL(appSettings) {
      UIApplication.shared.open(appSettings)
      permissionController?.dismiss(animated: true, completion: nil)
    }
  }
  }
  
  func didHide(permissions ids: [Int]) {
    
  }
  
}
