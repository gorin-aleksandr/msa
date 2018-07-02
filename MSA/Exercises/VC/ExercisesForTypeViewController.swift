//
//  ExercisesForTypeViewController.swift
//  MSA
//
//  Created by Pavlo Kharambura on 6/16/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit
import SDWebImage

let lightBlue = UIColor(rgb: 0x007AFF)

class ExercisesForTypeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewWithScroll: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var presenter: ExersisesTypesPresenter? = nil
    
    var exercisesByFIlter: [Exercise]? = nil
    var filteredArray: [Exercise] = []
    var filters: [ExerciseTypeFilter] = []
    var selectedFilter = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialDataFilling()
        configureFilterScrollView()
        configureTable_CollectionView()
    }
    
    func initialDataFilling() {
        filters = presenter?.getCurrentFilters() ?? []
        let allFilter = ExerciseTypeFilter()
        allFilter.name = "ВСЕ УПРАЖНЕНИЯ"
        filters.insert(allFilter, at: 0)
        selectedFilter = filters.first?.name ?? ""
        exercisesByFIlter = presenter?.getCurrentTypeExerceses()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configurateSearchController()
        hideableNavigationBar(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideableNavigationBar(true)
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
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Enter search text..."
        definesPresentationContext = true
        if #available(iOS 9.1, *) {
            searchController.obscuresBackgroundDuringPresentation = false
        }
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        }
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
        var xOffset:CGFloat = 5
        for item in filters {
            let button = UIButton()
            let label = UILabel()
            label.text = item.name
            label.font = UIFont(name: "Rubik", size: 18)
            label.textColor = .black
            
            let width = label.intrinsicContentSize.width + 20
            if selectedFilter == item.name {
                button.backgroundColor = lightBlue
            } else {
                button.backgroundColor = .gray
            }
            button.setTitle(item.name, for: .normal)
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
        if selectedFilter == "ВСЕ УПРАЖНЕНИЯ" {
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
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showExerciseInfoSegue":
            guard let exercise = sender as? Exercise else {return}
            guard let destination = segue.destination as? ExercisesInfoViewController else {return}
            destination.execise = exercise
        default:
            print("default")
        }
    }

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
        if isFiltering() {
            cell.configureCell(with: filteredArray[indexPath.row])
        } else {
            guard let ex = exercisesByFIlter?[indexPath.row] else {return UITableViewCell()}
            cell.configureCell(with: ex)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var exercise = Exercise()
        if isFiltering() {
            exercise = filteredArray[indexPath.row]
        } else {
            guard let ex = exercisesByFIlter?[indexPath.row] else {return}
            exercise = ex
        }
        performSegue(withIdentifier: "showExerciseInfoSegue", sender: exercise)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ExercisesForTypeViewController: ExercisesTypesDataProtocol {
    func startLoading() {}
    func finishLoading() {}
    func exercisesTypesLoaded() {}
    func errorOccurred(err: String) {}
    func filtersLoaded() {}
    func exercisesLoaded() {}
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
