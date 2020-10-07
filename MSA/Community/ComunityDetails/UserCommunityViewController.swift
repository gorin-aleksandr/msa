//
//  ComunityDetailsViewController.swift
//  MSA
//
//  Created by Andrey Krit on 8/22/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol UserCommunityViewProtocol: class {
    func reloadData()
    func showAlert(for user: UserVO)
}

class UserCommunityViewController: UIViewController, UserCommunityViewProtocol, UISearchBarDelegate {
    
    @IBOutlet weak var stateSegmentedControl: UISegmentedControl!
    @IBOutlet weak var userCommunityTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private let refreshControl = UIRefreshControl()
    
    var presenter: UserCommunityPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        userCommunityTableView.delegate = self
        userCommunityTableView.dataSource = self
        configureRefresh()
        presenter.start()
        searchBar.delegate = self
        if presenter.isTrainer {
            stateSegmentedControl.insertSegment(withTitle: "Спортсмены", at: 3, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        //configureSearchController()
        configureSegmentedControl()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func reloadData() {
        SVProgressHUD.dismiss()
        DispatchQueue.main.async { [weak self] in
            self?.userCommunityTableView.reloadData()
            self?.refreshControl.endRefreshing()
        }
    }
    
    func showAlert(for user: UserVO) {
        if self.presenter.state == .trainers {
            self.showDeleteTrainerAlert(for: user)
        } else {
            let alert = UIAlertController(title: nil, message: "Ты дейсвительно хочешь удалить из запросов/друзей? ", preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
                self?.presenter.deleteAction(for: user)
            }
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            present(alert, animated: true)
        }
    }
    
    func showDeleteTrainerAlert(for user: UserVO) {
        let alert = UIAlertController(title: nil, message: "Ты уверен(а), что хочешь удалить тренера?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.presenter.deleteAction(for: user)
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func configureSearchBar() {
        searchBar.backgroundImage = nil
    }
    
    private func configureRefresh() {
//        let attributes = [NSAttributedStringKey.foregroundColor: darkCyanGreen,
//                          NSAttributedStringKey.font: UIFont(name: "Rubik-Medium", size: 14)!]
//        refreshControl.attributedTitle = NSAttributedString(string: "Синхронизация ...", attributes: attributes)
        if #available(iOS 10.0, *) {
            userCommunityTableView.refreshControl = refreshControl
        } else {
            userCommunityTableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    
    @objc private func refreshData(_ sender: Any) {
        presenter.refresh()
    }
    
//    private func hideableNavigationBar(_ hide: Bool) {
//        if #available(iOS 11.0, *) {
//            navigationItem.hidesSearchBarWhenScrolling = hide
//        }
//    }
    
    private func configureSegmentedControl() {
        stateSegmentedControl.tintColor = UIColor.lightWhiteBlue
      stateSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.medium(13)],
                                                for: .normal)
        
    }
    
    private func moveToUserViewController(user: UserVO) {

      let state = presenter.getPersonState(person: user)
      print("state:\(state)")
      
      if user.userType == .trainer && state == .trainersSportsman {
        let destinationVC = UIStoryboard(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        destinationVC.profilePresenter = presenter.createProfilePresenter(user: user, for: destinationVC)
        navigationController?.pushViewController(destinationVC, animated: true)
      } else if user.userType == .trainer {
        let destinationVC = UIStoryboard(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            destinationVC.profilePresenter = presenter.createProfilePresenter(user: user, for: destinationVC)
            navigationController?.pushViewController(destinationVC, animated: true)
      } else {
        let destinationVC = UIStoryboard(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        destinationVC.profilePresenter = presenter.createProfilePresenter(user: user, for: destinationVC)
        navigationController?.pushViewController(destinationVC, animated: true)
      }
    }

    @IBAction func segmetedControlDidTapped(_ sender: UISegmentedControl) {
        presenter.setDataSource(with: searchBar.text, and: sender.selectedSegmentIndex)
    }
}


//MARK: - TableViewDelegate & DataSource

extension UserCommunityViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return presenter.userCommunityDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonTableViewCell") as! PersonTableViewCell
        cell.state = .caseMyCommunity
        cell.configure(with: presenter.userCommunityDataSource[indexPath.row], userCommunityState: presenter.state)
        cell.acceptButtonHandler = { [weak self] in
            SVProgressHUD.show()
            self?.presenter.acceptRequest(atIndex: indexPath.row)}
        cell.deleteButtonHandler = { [weak self] in self?.presenter.deleteButtonTapped(atIndex: indexPath.row)}
      return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      let vc = newProfileStoryboard.instantiateViewController(withIdentifier: "NewProfileViewController") as! NewProfileViewController
           vc.viewModel = ProfileViewModel()
           vc.viewModel?.selectedUser = presenter.userCommunityDataSource[indexPath.row]
           let nc = UINavigationController(rootViewController: vc)
           nc.modalPresentationStyle = .fullScreen
           self.present(nc, animated: true, completion: nil)
    //    moveToUserViewController(user: presenter.userCommunityDataSource[indexPath.row])
    }
}

//MARK: - Search Results Updating

extension UserCommunityViewController: UISearchResultsUpdating {
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
         presenter.setDataSource(with: searchText, and:stateSegmentedControl.selectedSegmentIndex)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        presenter.setDataSource(with: searchController.searchBar.text, and:stateSegmentedControl.selectedSegmentIndex)
    }
}
