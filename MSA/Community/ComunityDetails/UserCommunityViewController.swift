//
//  ComunityDetailsViewController.swift
//  MSA
//
//  Created by Andrey Krit on 8/22/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

protocol UserCommunityViewProtocol: class {
   func reloadData()
}

class UserCommunityViewController: UIViewController, UserCommunityViewProtocol {
    
    @IBOutlet weak var stateSegmentedControl: UISegmentedControl!
    @IBOutlet weak var userCommunityTableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var presenter: UserCommunityPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        userCommunityTableView.delegate = self
        userCommunityTableView.dataSource = self
        presenter.start()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideableNavigationBar(false)
        configureSearchController()
        configureSegmentedControl()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        hideableNavigationBar(true)
    }
    
    func reloadData() {
        userCommunityTableView.reloadData()
    }
    
    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Поиск"
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        }
        if #available(iOS 11.0, *) {
            navigationItem.searchController = nil
            navigationItem.searchController = searchController
        }
    }
    
    private func hideableNavigationBar(_ hide: Bool) {
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = hide
        }
    }
    
    private func configureSegmentedControl() {
        stateSegmentedControl.tintColor = UIColor.lightBlue
        stateSegmentedControl.setTitleTextAttributes([NSAttributedStringKey.font: Fonts.medium(13)],
                                                for: .normal)
    }
    
    private func moveToUserViewController() {
        let destinationVC = UIStoryboard(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        navigationController?.pushViewController(destinationVC, animated: true)
    }

    @IBAction func segmetedControlDidTapped(_ sender: UISegmentedControl) {
        presenter.setDataSource(with: searchController.searchBar.text, and: sender.selectedSegmentIndex)
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
        cell.configure(with: presenter.userCommunityDataSource[indexPath.row])
      return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        moveToUserViewController()
    }
}

//MARK: - Search Results Updating

extension UserCommunityViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        presenter.setDataSource(with: searchController.searchBar.text, and:stateSegmentedControl.selectedSegmentIndex)
    }
}
