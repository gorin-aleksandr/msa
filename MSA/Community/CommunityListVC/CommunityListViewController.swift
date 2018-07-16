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
    func configureFilterView(dataSource: [String], selectedFilterIndex: Int)
    func setCityFilterTextField(name: String?)
    
}

class CommunityListViewController: UIViewController, CommunityListViewProtocol {
    
    @IBOutlet weak var communityTableView: UITableView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterScrollView: UIScrollView!
    @IBOutlet weak var cityTextField: UITextField!
    
    
    
    let cityPicker = UIPickerView()
    
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
        configureCityPicker()
        hideableNavigationBar(false)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideableNavigationBar(true)
    }
    
    func updateTableView() {
        communityTableView.reloadData()
    }
    
    func setCityFilterTextField(name: String?) {
        cityTextField.text = name
    }
    
    func configureFilterView(dataSource: [String], selectedFilterIndex: Int) {
        for subView in filterScrollView.subviews {
            if let subView = subView as? UIButton {
                subView.removeFromSuperview()
            }
        }
        var xOffset: CGFloat = 8
        let buttonPadding: CGFloat = 10
        var buttonIndex = 0
        for filterName in dataSource {
            let button = UIButton()
            button.tag = buttonIndex
            button.isSelected = buttonIndex == selectedFilterIndex
            button.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
            button.configureAsFilterButton(title: filterName, xOffset: xOffset, padding: buttonPadding)
            xOffset = xOffset + buttonPadding + button.frame.size.width
            filterScrollView.addSubview(button)
            buttonIndex += 1
        }
        filterScrollView.contentSize = CGSize(width: xOffset, height: filterScrollView.frame.height)
    }
    
    @objc func filterButtonTapped(_ sender: UIButton) {
        presenter.setFilterForState(index: sender.tag)
    }
    
    private func configureCityPicker() {
        cityPicker.delegate = self
        cityPicker.dataSource = self
        cityTextField.inputView = cityPicker
        cityTextField.tintColor = .clear
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

extension CommunityListViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return presenter.getCities().count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return presenter.getCities()[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        presenter.selectCityAt(index: row)
    }
}


//MARK: - Search Results Updating
extension CommunityListViewController: UISearchResultsUpdating {
   
    func updateSearchResults(for searchController: UISearchController) {
        presenter.applyFilters(with: searchController.searchBar.text)
    }
    
//
//    private func isFiltering() -> Bool {
//        return searchController.isActive && !searchBarIsEmpty()
//    }
//
//    private func searchBarIsEmpty() -> Bool {
//        // Returns true if the text is empty or nil
//        return searchController.searchBar.text?.isEmpty ?? true
//    }
//
//    private func filterContentForSearchText(_ searchText: String, scope: String = "All") {
//        let filteretElements = presenter.communityDataSource.filter { element in return element.firstName.lowercased().contains(searchText.lowercased()) }
//        self.filteredArray = getSortedArray(of: filteretElements)
//        communityTableView.reloadData()
//    }
    
}
