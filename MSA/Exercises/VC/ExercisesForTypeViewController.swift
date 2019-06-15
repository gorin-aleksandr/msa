//
//  ExercisesForTypeViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 6/16/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import SDWebImage
import RealmSwift

let lightBlue = UIColor(rgb: 0x007AFF)
let lightGrey = UIColor(rgb: 0x030D15)

class ExercisesForTypeViewController: UIViewController {
    
    @IBOutlet weak var rightButton: UIBarButtonItem!
    
    ///////////////////
    var elementsForChoosing: [Exercise] {
        get {
            if isFiltering() {
                return filteredArray
            } else {
                return exercisesByFIlter ?? []
            }
        }
    }
    
    var selectedDataArray: [Exercise] = []
    var selectedIndexes: [Int] = [] {
        didSet {
            selectedIndexes.sort { $0 < $1 }
        }
    }
    var selectedIds: [String] = []
    ////////////////////
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewWithScroll: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var presenter: ExersisesTypesPresenter?
    var trainingManager: TrainingManager?
    private var tap: TapGesture!
    
    var exercisesByFIlter: [Exercise]?
    var filteredArray: [Exercise] = []
    var filters: [ExerciseTypeFilter] = []
    var selectedFilter = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.exerciseAddedN), name: Notification.Name("Exercise_added"), object: nil)
        
        initialDataFilling()
        configureFilterScrollView()
        configureTable_CollectionView()
        if let presenter = presenter {
            selectedDataArray = presenter.selectedExercisesForTraining
            selectedIds = presenter.selectedExercisesForTraining.map({$0.id})
        }
    }
    
    @objc
    func exerciseAddedN() {
        AlertDialog.showAlert("Упражнение добавлено", message: "", viewController: self)
        initialDataFilling()
        self.tableView.reloadData()
    }
    
    func initialDataFilling() {
        self.navigationController?.navigationBar.titleTextAttributes = [.font: UIFont(name: "Rubik-Medium", size: 17)!]
        navigationItem.title = presenter?.getCurrentExetcisesType().name
        if presenter?.getCurrentExetcisesType().name == "" {
            navigationItem.title = "Мои упражнения"
        }
        filters = presenter?.getCurrentFilters() ?? []
        let allFilter = ExerciseTypeFilter()
        allFilter.name = "Все в категории"
        filters.insert(allFilter, at: 0)
        selectedFilter = filters.first?.name ?? ""
        exercisesByFIlter = presenter?.getCurrentTypeExerceses()
        if let _ = trainingManager {
            self.navigationItem.rightBarButtonItem?.image = nil
            self.navigationItem.rightBarButtonItem?.title = "Добавить"
            self.navigationItem.rightBarButtonItem?.setTitleTextAttributes([.font: UIFont(name: "Rubik-Medium", size: 17)!], for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        trainingManager?.initView(view: self)
        presenter?.attachView(view: self)
        initialDataFilling()
        if presenter?.getCurrentExetcisesType().name == "" {
            exercisesByFIlter = presenter?.getCurrentTypeExerceses()
            tableView.reloadData()
        }
        configurateSearchController()
        hideableNavigationBar(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideableNavigationBar(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
//        trainingManager = nil
        navigationItem.searchController = nil
        
    }
    
    private func configureTable_CollectionView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func hideableNavigationBar(_ hide: Bool) {
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = hide
        }
    }
    
    private func configurateSearchController() {
        searchController.hidesNavigationBarDuringPresentation = false
        let attrs = [NSAttributedStringKey.foregroundColor: darkCyanGreen,
                     NSAttributedStringKey.font: UIFont(name: "Rubik-Medium", size: 17)!]
        self.navigationController?.navigationBar.titleTextAttributes = attrs
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Поиск"
        definesPresentationContext = true
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        }
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        }
        searchController.searchBar.setValue("Отмена", forKey:"_cancelButtonText")
    }
    
    private func getSortedArray(of array: [Exercise]) -> [Exercise] {
        var arrayForSorting = array
        arrayForSorting.sort { first, second in first.name.localizedCaseInsensitiveCompare(second.name) == .orderedAscending }
        return arrayForSorting
    }
    
    func updateSearchData() {
        tableView.reloadData()
    }
    
    func configureFilterScrollView() {
        for subView in scrollView.subviews {
            if let subView = subView as? UIButton {
                subView.removeFromSuperview()
            }
        }
        let buttonPadding:CGFloat = 10
        var xOffset:CGFloat = 8
        for item in filters {
            let button = UIButton()
            let label = UILabel()
            label.text = item.name
            label.font = UIFont(name: "Rubik", size: 14)
            label.textColor = .black
            
            let width = label.intrinsicContentSize.width + 20
            if selectedFilter == item.name {
                button.backgroundColor = lightWhiteBlue
            } else {
                button.backgroundColor = darkCyanGreen45
            }
            button.setTitle(item.name, for: .normal)
            button.titleLabel?.font = UIFont(name: "Rubik-Medium", size: 13)
            button.tag = filters.index(of: item) ?? -1
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 15
            button.frame = CGRect(x: xOffset, y: buttonPadding, width: width, height: 30)
            button.addTarget(self, action: #selector(filterTapped(_:)), for: .touchUpInside)
            xOffset = xOffset + buttonPadding + button.frame.size.width
            scrollView.addSubview(button)
        }
        scrollView.contentSize = CGSize(width: xOffset, height: scrollView.frame.height)
    }
    
    @objc func filterTapped(_ sender: UIButton) {
        exercisesByFIlter?.removeAll()
        selectedFilter = filters[sender.tag].name
        if selectedFilter == "Все в категории" {
            exercisesByFIlter = presenter?.getCurrentTypeExerceses()
        } else {
            for ex in (presenter?.getCurrentTypeExerceses())! {
                for id in ex.filterIDs {
                    if id.id == filters[sender.tag].id {
                        if !((exercisesByFIlter?.contains(ex))!) {
                            exercisesByFIlter?.append(ex)
                        }
                    }
                }
            }
        }
        if isFiltering() {
            filterContentForSearchText(searchController.searchBar.text!)
        }
        configureFilterScrollView()
        tableView.reloadData()
    }
    
    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func plus(_ sender: Any) {
        if let manager = trainingManager {
            guard let presenter = presenter else {return}
            if presenter.selectedExercisesForTraining.isEmpty {
                AlertDialog.showAlert("Добавьте хотя бы одно упражнение", message: "", viewController: self)
                return
            }
            if manager.sportsmanId != AuthModule.currUser.id {
                let newExMan = NewExerciseManager()
                newExMan.addExercisesToUser(id: manager.sportsmanId ?? "", exercises: presenter.selectedExercisesForTraining, completion: {
                    self.addExercisesToTraining(newExercises: presenter.selectedExercisesForTraining, manager: manager)
                }) { (error) in
                    AlertDialog.showAlert("Ошибка", message: error?.localizedDescription ?? "", viewController: self)
                }
            } else {
                self.addExercisesToTraining(newExercises: presenter.selectedExercisesForTraining, manager: manager)
            }
        } else {
            self.performSegue(withIdentifier: "newExerciseSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showExerciseInfoSegue":
            guard let exercise = sender as? Exercise else {return}
            guard let destination = segue.destination as? ExercisesInfoViewController else {return}
            destination.execise = exercise
            destination.presenter = self.presenter
        case "newExerciseSegue":
            guard let destination = segue.destination as? NewExerciseViewController else {return}
            destination.presenter = self.presenter
        default:
            print("default")
        }
    }
    
    func back() {
        if let NVC = self.navigationController {
            for controller in NVC.viewControllers as Array {
                if controller.isKind(of: MyTranningsViewController.self) {
                    self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
        }
    }
    
//    @objc func handleTap(sender: TapGesture) {
//        let destinationVC = UIStoryboard(name: "Trannings", bundle: .main).instantiateViewController(withIdentifier: "ExercisesInfoViewController") as! ExercisesInfoViewController
//        guard let indexPath = sender.indexPath else {return}
//
//        var exercise = Exercise()
//        if isFiltering() {
//            exercise = filteredArray[indexPath.row]
//        } else {
//            guard let ex = exercisesByFIlter?[indexPath.row] else {return}
//            exercise = ex
//        }
//        destinationVC.execise = exercise
//        self.navigationController?.pushViewController(destinationVC, animated: true)
//    }
    
}

//MARK: - TableView
extension ExercisesForTypeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredArray.count
        } else {
            return exercisesByFIlter?.count ?? 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "exerciseForTypeTableCell", for: indexPath) as? ExercisesTableViewCell else { return UITableViewCell() }
        if let _ = trainingManager {
            cell.checkBoxImage.isHidden = false
            
        } else {
            cell.checkBoxImage.isHidden = true
        }

        let exercise = elementsForChoosing[indexPath.row]
        cell.configureCell(with: exercise)
        if selectedIds.contains(exercise.id) {
            cell.cellState = .selected
        } else {
            cell.cellState = .unselected
        }
        var exercise_ = Exercise()
        if isFiltering() {
            exercise_ = filteredArray[indexPath.row]
        } else {
            guard let ex = exercisesByFIlter?[indexPath.row] else { return UITableViewCell()}
            exercise_ = ex
        }
        cell.descriptionTapped = {
            if let _ = self.trainingManager {
                let selectedCell = tableView.cellForRow(at: indexPath) ?? UITableViewCell()
                self.configureSelectedCell(selectedCell, in: tableView, at: indexPath)
            } else {
                self.presenter?.setCurrentIndex(index: indexPath.row)
                self.performSegue(withIdentifier: "showExerciseInfoSegue", sender: exercise_)
            }
        }
        cell.imageTapped = {
            self.presenter?.setCurrentIndex(index: indexPath.row)
            self.performSegue(withIdentifier: "showExerciseInfoSegue", sender: exercise)
        }

        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        var exercise = Exercise()
//        if isFiltering() {
//            exercise = filteredArray[indexPath.row]
//        } else {
//            guard let ex = exercisesByFIlter?[indexPath.row] else {return}
//            exercise = ex
//        }
        
//        if let _ = trainingManager {
//            let selectedCell = tableView.cellForRow(at: indexPath) ?? UITableViewCell()
//            configureSelectedCell(selectedCell, in: tableView, at: indexPath)
//        } else {
//            presenter?.setCurrentIndex(index: indexPath.row)
//            performSegue(withIdentifier: "showExerciseInfoSegue", sender: exercise)
//        }
//        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func addExToTraining(newExercise: Exercise, manager: TrainingManager) {
        let ex = ExerciseInTraining()
        ex.id = UUID().uuidString
        ex.name = newExercise.name
        ex.exerciseId = newExercise.id
        try! manager.realm.performWrite {
            manager.getCurrentday()?.exercises.append(ex)
            manager.editTraining(wiht: manager.dataSource?.currentTraining?.id ?? -1, success: {})
            self.back()
        }
    }
    
    private func addExercisesToTraining(newExercises: [Exercise], manager: TrainingManager) {
        for newExercise in newExercises {
            let ex = ExerciseInTraining()
            ex.id = UUID().uuidString
            ex.name = newExercise.name
            ex.exerciseId = newExercise.id
            try! manager.realm.performWrite {
                manager.getCurrentday()?.exercises.append(ex)
            }
        }
        let loader = UIActivityIndicatorView()
        loader.center = self.view.center
        loader.activityIndicatorViewStyle = .whiteLarge
        loader.color = .blue
        self.view.addSubview(loader)
        loader.startAnimating()
        self.view.isUserInteractionEnabled = false
        manager.editTraining(wiht: manager.dataSource?.currentTraining?.id ?? -1, success: {
            self.view.isUserInteractionEnabled = false
            loader.isHidden = true
            self.back()
        }) { (error) in
            self.view.isUserInteractionEnabled = false
            loader.isHidden = true
            AlertDialog.showAlert("Ошибка", message: "", viewController: self)
        }
    }
    
    private func configureSelectedCell(_ cell: UITableViewCell, in tableView: UITableView, at indexPath: IndexPath) {
        guard let selectedCell = cell as? ExercisesTableViewCell else { return }
        var selectedItem = Exercise()
        
        selectedItem = elementsForChoosing[indexPath.row]
        
        switch selectedCell.cellState {
        case .unselected:
            selectedDataArray.append(selectedItem)
            presenter?.selectedExercisesForTraining.append(selectedItem)
            selectedIndexes.append(indexPath.row)
            selectedIds.append(selectedItem.id)
        case .selected:
            selectedDataArray.remove(selectedItem)
            presenter?.selectedExercisesForTraining.remove(selectedItem)
            selectedIndexes.remove(indexPath.row)
            selectedIds.remove(selectedItem.id)
        }
        selectedCell.cellState.toggle()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { (action, indexPath) in
            var exercise = Exercise()
            if self.isFiltering() {
                exercise = self.filteredArray[indexPath.row]
                self.filteredArray.remove(at: indexPath.row)
            } else {
                if let ex = self.exercisesByFIlter?[indexPath.row] {
                    exercise = ex
                    self.exercisesByFIlter?.remove(at: indexPath.row)
                }
            }
            tableView.reloadData()
            self.presenter?.deleteExercise(with: exercise.id)
        }
        delete.backgroundColor = .red
        
        return [delete]
    }
    
}

extension ExercisesForTypeViewController: ExercisesTypesDataProtocol {
    func myExercisesLoaded() {
        if presenter?.getCurrentExetcisesType().id == 12 {
            exercisesByFIlter = presenter?.getOwnExercises()
            tableView.reloadData()
        }
    }
    func startLoading() {}
    func finishLoading() {}
    func exercisesTypesLoaded() {}
    func errorOccurred(err: String) {}
    func filtersLoaded() {}
    func exercisesLoaded() {}
    func exerciseDeleted(with id: String) {}
}

//MARK: - Search Results Updating
extension ExercisesForTypeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        //When user start searching remove indexer from the screen
    }
    
    private func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    private func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        if let filteretElements = exercisesByFIlter?.filter({ element in return element.name.lowercased().contains(searchText.lowercased()) }) {
            self.filteredArray = getSortedArray(of: filteretElements)
        }
        updateSearchData()
    }
    
}

extension ExercisesForTypeViewController: TrainingsViewDelegate {
    func synced() {}
    func trainingEdited() {}
    func trainingsLoaded() {}
    func templateCreated() {}
    func templatesLoaded() {}
}

//extension ExercisesForTypeViewController: UISearchControllerDelegate {
//    func searchDisplayControllerWillBeginSearch(controller: UISearchDisplayController) {
//        for view:UIView in (searchController.searchBar.subviews)        {
//            for subView:UIView in (view.subviews)
//            {
//                if ( subView is UIButton )
//                {
//                    let cancelBut = subView as! UIButton
//                    cancelBut.setTitle("sdfsdfsdf", for: .normal)
//                }
//            }
//        }
//    }
//}
