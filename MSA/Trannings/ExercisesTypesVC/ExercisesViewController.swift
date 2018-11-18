//
//  ExercisesViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 6/14/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import SDWebImage

class ExercisesViewController: UIViewController, UIGestureRecognizerDelegate {
    
    enum SegueIDs: String {
        case exercisesSegueId = "exercisesSegueId"
        case oneExerciseSegueId = "oneExerciseSegueId"
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredArray: [Exercise] = []
    
    let presenter = ExersisesTypesPresenter(exercises: ExersisesDataManager())
    var trainingManager: TrainingManager? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavContr()
        presenter.attachView(view: self)
        trainingManager?.initView(view: self)
        configureTable_CollectionView()
        initialDataPreparing()
        NotificationCenter.default.addObserver(self, selector: #selector(self.exerciseAddedN), name: Notification.Name("Exercise_added"), object: nil)
        
    }

    private func configureNavContr() {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.navigationBar.titleTextAttributes = [.font: UIFont(name: "Rubik-Medium", size: 17)!]
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configurateSearchController()
        hideableNavigationBar(false)
        guard let _ = trainingManager else { return }
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "back_"), for: .normal)
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        let barButt = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = barButt
    }
    
    @objc
    func back() {
        navigationController?.popViewController(animated: true)
    }
    
    private func getFromRealm() {
        presenter.getExercisesFromRealm()
        presenter.getTypesFromRealm()
        presenter.getFiltersFromRealm()
        presenter.getMyExercisesFromRealm()
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    private func initialDataPreparing() {
        getFromRealm()
        //        if presenter.getFilters().isEmpty {
        presenter.getAllFilters()
        //        } else {
        //            presenter.detectFiltersChanges()
        //        }
        
        //        if presenter.getExercises().isEmpty {
        presenter.getAllExersises()
        //        } else {
        //            presenter.detectExersisesChanges()
        //        }
        
        //        if presenter.getTypes().isEmpty {
        presenter.getAllTypes()
        //        } else {
        //            presenter.detectTypesChanges()
        //        }
        presenter.getMyExercises()
    }
    
    @objc func exerciseAddedN(notfication: NSNotification) {
        AlertDialog.showAlert("Упражнение добавлено", message: "", viewController: self)
        initialDataPreparing()
    }
    
    private func configureTable_CollectionView() {
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func hideableNavigationBar(_ hide: Bool) {
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = hide
        }
    }
    
    private func configurateSearchController() {
        let attrs = [NSAttributedStringKey.foregroundColor: darkCyanGreen,
                     NSAttributedStringKey.font: UIFont(name: "Rubik-Medium", size: 17)!]
        self.navigationController?.navigationBar.titleTextAttributes = attrs
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        }
        if #available(iOS 11.0, *) {
            navigationItem.searchController = nil
            navigationItem.searchController = searchController
        }
        searchController.searchBar.placeholder = "Search"
    }
    
    private func getSortedArray(of array: [Exercise]) -> [Exercise] {
        var arrayForSorting = array
        arrayForSorting.sort { first, second in first.name.localizedCaseInsensitiveCompare(second.name) == .orderedAscending }
        return arrayForSorting
    }
    
    func updateSearchData() {
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueIDs.exercisesSegueId.rawValue:
            if let destination = segue.destination as? ExercisesForTypeViewController {
                destination.presenter = self.presenter
                destination.trainingManager = self.trainingManager
            }
        case SegueIDs.oneExerciseSegueId.rawValue:
            if let destination = segue.destination as? ExercisesInfoViewController {
                destination.execise = presenter.getCurrentExercise()
            }
        default:
            print("Another segue")
        }
    }
    
}

//MARK: - TableView
extension ExercisesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredArray.count
        } else {
            return presenter.getExercises().count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "exerciseTableCell", for: indexPath) as! ExercisesTableViewCell
        if isFiltering() {
            cell.configureCell(with: filteredArray[indexPath.row])
        } else {
            cell.configureCell(with: presenter.getExercises()[indexPath.row])
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFiltering() {
            presenter.setCurrentExercise(exerc: filteredArray[indexPath.row])
        } else {
            presenter.setCurrentExercise(exerc: presenter.getExercises()[indexPath.row])
        }
        if let manager = trainingManager {
            let newExercise = presenter.getCurrentExercise()
            let ex = ExerciseInTraining()
            ex.id = UUID().uuidString
            ex.name = newExercise.name
            ex.exerciseId = newExercise.id
            try! manager.realm.performWrite {
                manager.getCurrentday()?.exercises.append(ex)
                manager.editTraining(wiht: manager.dataSource?.currentTraining?.id ?? -1, success: {})
                self.back()
            }
        } else {
            self.performSegue(withIdentifier: SegueIDs.oneExerciseSegueId.rawValue, sender: nil)
        }
    }
}

//MARK: - CollectionView
extension ExercisesViewController : UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width/3, height: self.view.frame.width/3)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if presenter.getOwnExercises().count != 0 {
            return presenter.getTypes().count + 1
        } else {
            return presenter.getTypes().count
        }
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "exerciseCollectionCell", for: indexPath) as! ExercisesCollectionViewCell
        if presenter.getOwnExercises().count != 0 && indexPath.row == presenter.getTypes().count {
            cell.nameLabel.text = "Свои"
            cell.imageView.sd_setImage(with: URL(string: "https://firebasestorage.googleapis.com/v0/b/msa-progect.appspot.com/o/%D0%A1%D0%B2%D0%BE%D0%B8.png?alt=media&token=2f923b39-8d90-43ff-97ce-c0fa7960de23"), placeholderImage: nil, options: .allowInvalidSSLCertificates, completed: nil)
        } else {
            cell.configureCell(with: presenter.getTypes()[indexPath.row])
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if presenter.getOwnExercises().count != 0 && indexPath.row == presenter.getTypes().count {
            presenter.setExercisesForType(with: 12)
            let type = ExerciseType()
            for exers in presenter.getCurrentTypeExerceses() {
                let ID = Id()
                ID.id = exers.filterIDs.first?.id ?? -1
                if type.filterIDs.contains(where: { $0.id == ID.id }) {} else {
                    type.filterIDs.append(ID)
                }
            }
            presenter.setCurrentExetcisesType(type: type)
        } else {
            presenter.setExercisesForType(with: presenter.getTypes()[indexPath.row].id)
            presenter.setCurrentExetcisesType(type: presenter.getTypes()[indexPath.row])
        }
        performSegue(withIdentifier: SegueIDs.exercisesSegueId.rawValue, sender: nil)
    }
}

extension ExercisesViewController: ExercisesTypesDataProtocol {
    func startLoading() {}
    
    func finishLoading() {}
    
    func exercisesTypesLoaded() {
        print("Types")
        collectionView.reloadData()
    }
    
    func errorOccurred(err: String) {}
    
    func filtersLoaded() {
        print("Filters")
    }
    
    func myExercisesLoaded() {
        collectionView.reloadData()
    }
    
    func exercisesLoaded() {
        print("Exercises")
        tableView.reloadData()
    }
    
}

//MARK: - Search Results Updating
extension ExercisesViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        //When user start searching remove indexer from the screen
    }
    
    private func isFiltering() -> Bool {
        if searchController.isActive && !searchBarIsEmpty() {
            collectionView.alpha = 0
            tableView.alpha = 1
        } else {
            collectionView.alpha = 1
            tableView.alpha = 0
        }
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    private func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        let filteretElements = presenter.getExercises().filter { element in return element.name.lowercased().contains(searchText.lowercased()) }
        self.filteredArray = getSortedArray(of: filteretElements)
        updateSearchData()
    }
    
}

extension ExercisesViewController: TrainingsViewDelegate {
    func synced() {}
    
    func trainingEdited() {}
    
    func trainingsLoaded() {}
    
    func templateCreated() {}
    
    func templatesLoaded() {}
}
