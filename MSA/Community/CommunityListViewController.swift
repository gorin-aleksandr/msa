//
//  CummunityListViewController.swift
//  MSA
//
//  Created by Andrey Krit on 7/4/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

protocol CommunityListViewProtocol: class {
    func updateTableView()
    func configureFilterView(dataSource: [String])
}

class CommunityListViewController: UIViewController, CommunityListViewProtocol {
    
    @IBOutlet weak var communityTableView: UITableView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterScrollView: UIScrollView!
    
    var presenter: CommunityListPresenterProtocol!
    let searchController = UISearchController(searchResultsController: nil)
    
    let button = UIButton()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = CommunityListPresenter(view: self)
        communityTableView.delegate = self
        communityTableView.dataSource = self
        presenter.start()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureSearchController()
        hideableNavigationBar(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideableNavigationBar(true)
    }
    
    func updateTableView() {
        communityTableView.reloadData()
    }
    
    func configureFilterView(dataSource: [String]) {
        var xOffset: CGFloat = 8
        let buttonPadding: CGFloat = 10
        for filterName in dataSource {
            let button = UIButton()
            button.configureAsFilterButton(title: filterName, xOffset: xOffset, padding: buttonPadding)
            xOffset = xOffset + buttonPadding + button.frame.size.width
            filterScrollView.addSubview(button)
        }
        filterScrollView.contentSize = CGSize(width: xOffset, height: filterScrollView.frame.height)
    }
    
    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Enter search text..."
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
}


extension CommunityListViewController: UITableViewDelegate, UITableViewDataSource {
   
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.communityDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonTableViewCell", for: indexPath) as! PersonTableViewCell
        cell.configure(with: presenter.communityDataSource[indexPath.row])
        return cell
    }
}


//MARK: - Search Results Updating
extension CommunityListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        
    }
    
    private func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    private func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private func filterContentForSearchText(_ searchText: String, scope: String = "All") {
//        let filteretElements = presenter.communityDataSource.filter { element in return element.firstName.lowercased().contains(searchText.lowercased()) }
       // self.filteredArray = getSortedArray(of: filteretElements)
        communityTableView.reloadData()
    }
    
}
