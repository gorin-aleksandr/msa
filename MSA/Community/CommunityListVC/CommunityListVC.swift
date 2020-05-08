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
    func showGeneralAlert()
    func showRestoreAlert()
    func showIAP()
    func hideAccessDeniedView()
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
    @IBOutlet weak var accessDeniedView: UIView!
    @IBOutlet weak var goToProductsButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    
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
        errorView.isHidden = true
        configureRefresh()
        presenter.start()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // MARK: Uncomment/commemt for IAPs
        //accessDeniedView.isHidden = InAppPurchasesService.shared.currentSubscription != nil
        accessDeniedView.isHidden = true
        
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
    
    func showIAP() {
        presentIAPViewController()
    }
    
    func showGeneralAlert() {
         AlertDialog.showGeneralErrorAlert(on: self)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func configureAccessDeniedView() {
            restoreButton.layer.masksToBounds = true
            restoreButton.layer.cornerRadius = 12
            restoreButton.layer.borderWidth = 1
            restoreButton.layer.borderColor = UIColor.darkGreenColor.cgColor
        
            goToProductsButton.layer.masksToBounds = true
            goToProductsButton.layer.cornerRadius = 12
            goToProductsButton.layer.borderWidth = 1
            goToProductsButton.layer.borderColor = UIColor.darkGreenColor.cgColor
    }
    
    func showAlertFor(user: UserVO, isTrainerEnabled: Bool) {
        let alert = UIAlertController(title: "Добавить в свое сообщество \(user.getFullName())", message: "Вы можете перейти на страницу тренера/друга на вкладке “Сообщество”", preferredStyle: .alert)
        let cancelActionButton = UIAlertAction(title: "Отмена", style: .cancel) { action -> Void in
            print("Cancel")
        }
        if presenter.getPersonState(person: user) != .friend {
            let addFriendAction = UIAlertAction(title: "Добавить в список друзей", style: .default, handler: { [weak self] action -> Void in
                SVProgressHUD.show()
                self?.presenter.addToFriends(user: user)
                
            })
             alert.addAction(addFriendAction)
        }
        
        alert.addAction(cancelActionButton)
       
        if isTrainerEnabled {
            let addTrainerAction = UIAlertAction(title: "Добавить в тренеры", style: .default, handler: { [weak self] _ in
                SVProgressHUD.show()
                self?.presenter.addAsTrainer(user: user)
            })
        alert.addAction(addTrainerAction)
        }
        self.present(alert, animated: true)
    }
    
    func hideAccessDeniedView() {
        DispatchQueue.main.async { [weak self] in
            self?.accessDeniedView.isHidden = true
        }
    }
    
    func showRestoreAlert() {
        let alert = UIAlertController(title: "Subscription Issue", message: "We are having a hard time finding your subscription. If you've recently reinstalled the app or got a new device please choose to restore your purchase. Otherwise go Back to Subscribe.", preferredStyle: .alert)
        
        let restoreAction = UIAlertAction(title: "Restore", style: .default) { [weak self] _ in
            print("Handle restore somehow---------->>>>>>>>")
//            SubscriptionService.shared.restorePurchases()
//            self?.showRestoreInProgressAlert()
        }
        
        let backAction = UIAlertAction(title: "Back", style: .cancel) { _ in
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(restoreAction)
        alert.addAction(backAction)
        
        present(alert, animated: true, completion: nil)
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
      self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: darkCyanGreen, .font: UIFont(name: "Rubik-Bold", size: 17)!]
    }
    
    private func configureSegmentedControl() {
        filterSegmentedControl.tintColor = UIColor.lightWhiteBlue
      filterSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: Fonts.medium(13)],
                                                     for: .normal)
    }
    
    private func moveToUserViewController(with user: UserVO) {
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
    
    private func presentIAPViewController() {
      DispatchQueue.main.async {
        let destinationVC = UIStoryboard(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "IAPViwController") as! IAPViewController
        let navigationController = UINavigationController()
        destinationVC.presenter = self.presenter.createIAPPresenter(for: destinationVC)
        navigationController.setViewControllers([destinationVC], animated: false)
        self.present(navigationController, animated: true, completion: nil)
      }
    }

    
    @IBAction func myCommunityButtonTapped(_ sender: Any) {
// MARK: 1
   //    if InAppPurchasesService.shared.currentSubscription != nil {
            let destinationVC = UIStoryboard(name: "Community", bundle: nil).instantiateViewController(withIdentifier: "UserCommunityViewController") as! UserCommunityViewController
            destinationVC.presenter = presenter.createNextPresenter(for: destinationVC)
            self.navigationController?.pushViewController(destinationVC, animated: true)
//          } else {
//              showNoMyComunityAlert()
//          }
    }

    private func showNoMyComunityAlert() {
        let alert = UIAlertController(title: "Мое сообщество недоступно", message: "Получите доступ к Сообщесту и дополнительным функциям оформив подписку.", preferredStyle: .alert)
        let restoreAction = UIAlertAction(title: "Перейти к покупкам", style: .default) { [weak self] _ in
            self?.presentIAPViewController()
        }
        let okAction = UIAlertAction(title: "Ок", style: .cancel) { _ in }
        alert.addAction(restoreAction)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func segmentedControlTapped(_ sender: UISegmentedControl) {
        presenter.setFilterForState(index: sender.selectedSegmentIndex)
    }
    
    @IBAction func restoreButtonDidTapped(_ sender: Any) {
        InAppPurchasesService.shared.restorePurchases()
    }
    
    @IBAction func goToProductsButtonTapped(_ sender: Any) {
        showIAP()
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
        cell.addButtonHandler = { [weak self] in
            self?.presenter?.addButtonTapped(at: indexPath.row)
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
