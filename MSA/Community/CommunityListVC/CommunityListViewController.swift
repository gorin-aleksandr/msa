//
//  CummunityListViewController.swift
//  MSA
//
//  Created by Andrey Krit on 7/4/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol CommunityListViewProtocol: class {
    func updateTableView()
    func configureFilterView(dataSource: [String], selectedFilterIndex: Int)
    func setCityFilterTextField(name: String?)
    func showAlertFor(user: UserVO, isTrainerEnabled: Bool)
}

class CommunityListViewController: UIViewController, CommunityListViewProtocol {
    
    @IBOutlet weak var communityTableView: UITableView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterScrollView: UIScrollView!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var myCommunityButton: UIBarButtonItem!
    
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
        setupNavigationBar()
        configureSearchController()
        configureCityPicker()
        hideableNavigationBar(false)
        updateTableView()
        //presenter.applyFilters(with: cityTextField.text)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideableNavigationBar(true)
    }
    
    func updateTableView() {
        communityTableView.reloadData()
        SVProgressHUD.dismiss()
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
    
    func showAlertFor(user: UserVO, isTrainerEnabled: Bool) {
        let alert = UIAlertController(title: "Добавить в свое сообщество \(user.getFullName())", message: "Вы можете перейти на страницу тренера/друга на вкладке “Сообщество”", preferredStyle: .alert)
        let cancelActionButton = UIAlertAction(title: "Отмена", style: .cancel) { action -> Void in
            print("Cancel")
        }
        if presenter.getPersonState(person: user) != .friend {
            let addFriendAction = UIAlertAction(title: "Добавить в список друзей", style: .default, handler: { [weak self] action -> Void in
                self?.presenter.addToFriends(user: user)
                SVProgressHUD.show()
                
            })
             alert.addAction(addFriendAction)
        }
        
        alert.addAction(cancelActionButton)
       
        if isTrainerEnabled {
            let addTrainerAction = UIAlertAction(title: "Добавить в тренеры", style: .default, handler: { [weak self] _ in
                self?.presenter.addAsTrainer(user: user)
                SVProgressHUD.show()
            })
        alert.addAction(addTrainerAction)
        }
        self.present(alert, animated: true)
    }
    
    @objc func filterButtonTapped(_ sender: UIButton) {
        print(sender.tag)
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
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.titleTextAttributes = [.font: UIFont(name: "Rubik-Medium", size: 17)!]
    }
    
    private func moveToUserViewController(with user: UserVO) {
        let destinationVC = UIStoryboard(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        destinationVC.profilePresenter = presenter.createProfilePresenter(user: user, for: destinationVC)
        navigationController?.pushViewController(destinationVC, animated: true)
    }

    
    @IBAction func myCommunityButtonTapped(_ sender: Any) {
        let destinationVC = UIStoryboard(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "UserCommunityViewController") as! UserCommunityViewController
        destinationVC.presenter = presenter.createNextPresenter(for: destinationVC)
        self.navigationController?.pushViewController(destinationVC, animated: true)
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
        let person = presenter.communityDataSource[indexPath.row]
        let personState =  presenter.getPersonState(person: person)
        cell.configure(with: person, userCommunityState: .friends)
        cell.addButtonHandler = { [weak self] in self?.presenter?.addButtonTapped(at: indexPath.row)
        }
        cell.setupCell(basedOn: personState, isTrainerEnabled: presenter.isTrainerEnabled)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        moveToUserViewController(with: presenter.communityDataSource[indexPath.row])
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
