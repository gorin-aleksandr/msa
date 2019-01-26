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
    func setErrorViewHidden(_ isHidden: Bool)
    func setLoaderVisible(_ visible: Bool)
    func stopLoadingViewState()
}

class CommunityListViewController: UIViewController, CommunityListViewProtocol, UIGestureRecognizerDelegate, ErrorViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var communityTableView: UITableView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterScrollView: UIScrollView!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var myCommunityButton: UIBarButtonItem!
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var errorView: ErrorView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private let refreshControl = UIRefreshControl()
    
    let cityPicker = UIPickerView()
    
    var presenter: CommunityListPresenterProtocol!
    
    let button = UIButton()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        searchBar.delegate = self
        presenter = CommunityListPresenter(view: self)
        communityTableView.delegate = self
        communityTableView.dataSource = self
        errorView.delegate = self
        configureRefresh()
        setLoaderVisible(true)
        presenter.fetchData()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        configureCityPicker()
        updateTableView()
        configureSegmentedControl()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //hideableNavigationBar(true)
    }
    
    func updateTableView() {
        DispatchQueue.main.async { [weak self] in
            self?.communityTableView.reloadData()
        }
        
    }
    
    func setCityFilterTextField(name: String?) {
        cityTextField.text = name
    }
    
    func setErrorViewHidden(_ isHidden: Bool) {
        errorView.isHidden = isHidden
    }
    
    func configureFilterView(dataSource: [String], selectedFilterIndex: Int) {
        var segmentIndex = 0
        for filterName in dataSource {
            filterSegmentedControl.setTitle(filterName, forSegmentAt: segmentIndex)
            segmentIndex += 1
        }
    }
    
    func tryAgainButtonDidTapped() {
        setErrorViewHidden(true)
        setLoaderVisible(true)
        presenter.fetchData()
    }
    
    func stopLoadingViewState() {
        refreshControl.endRefreshing()
        setLoaderVisible(false)
    }
    
    func setLoaderVisible(_ visible: Bool) {
        visible ? SVProgressHUD.show() : SVProgressHUD.dismiss()
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
    
    private func configureRefresh() {
//        let attributes = [NSAttributedStringKey.foregroundColor: darkCyanGreen,
//                     NSAttributedStringKey.font: UIFont(name: "Rubik-Medium", size: 14)!]
//          refreshControl.attributedTitle = NSAttributedString(string: "Синхронизация ...", attributes: attributes)
        if #available(iOS 10.0, *) {
            communityTableView.refreshControl = refreshControl
        } else {
            communityTableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    
    @objc private func refreshData(_ sender: Any) {
            self.presenter.fetchData()
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = UIColor.darkCyanGreen
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: darkCyanGreen, .font: UIFont(name: "Rubik-Bold", size: 17)!]
    }
    
    private func configureSegmentedControl() {
        filterSegmentedControl.tintColor = UIColor.lightWhiteBlue
        filterSegmentedControl.setTitleTextAttributes([NSAttributedStringKey.font: Fonts.medium(13)],
                                                     for: .normal)
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
    
    @IBAction func segmentedControlTapped(_ sender: UISegmentedControl) {
        presenter.setFilterForState(index: sender.selectedSegmentIndex)
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
extension CommunityListViewController {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
          presenter.applyFilters(with: searchBar.text)
    }
    
}
