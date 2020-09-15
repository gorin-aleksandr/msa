//
//  searchSignInViewController.swift
//  
//
//  Created by Nik on 17.03.2020.
//

import UIKit
import PaginatedTableView

class SearchViewController: BaseViewController {
  
  var viewModel: SignInViewModel?
  var orderViewModel: OrderViewModel?
  
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var tableView: PaginatedTableView!
  var itemSelected: ((Int,String) -> ())?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.tableView.reloadData()
  }
  
  @IBAction func nextAction(_ sender: Any) {
    switch viewModel?.searchControllerType {
      case .city:
        self.navigate(MyNavigation.searchSignInViewController(.auto, viewModel!))
      case .auto:
        self.navigate(MyNavigation.searchSignInViewController(.model, viewModel!))
      case .model:
        self.navigate(MyNavigation.signInPickerViewController(.year, viewModel!))
      case .bodyType:
        self.navigate(MyNavigation.signInPickerViewController(.capacity, viewModel!))
      default: self.viewModel?.selectedCapacity = 0
    }
    
    switch orderViewModel?.searchControllerType {
      case .usersCars:
        self.navigate(MyNavigation.searchOrderViewController(.servicesList, orderViewModel!))
      case .servicesList:
        self.navigate(MyNavigation.orderDescriptionViewController(orderViewModel!))
      default: self.viewModel?.selectedCapacity = 0
    }
  }
  
  func setupUI() {
    switch viewModel?.searchControllerType {
      case .city:
        self.title = "Выберите город"
      case .auto:
        self.title = "Марка авто"
      case .model:
        self.title = "Моделб"
      case .bodyType:
        self.title = "Тип кузова"
      case .modifications:
        self.title = "Коробка передач"
      case .generations:
        self.title = "Поколение"
      case .usersCars:
        self.title = "Выберите авто"
      default:
        self.title = ""
    }
    
    if orderViewModel?.searchControllerType == .usersCars {
      createAddBarButton(on: .left, by: .set) { item in
        //self.navigate(MyNavigation.searchViewController(.usersCars, SignInViewModel()))
        self.navigationController!.dismiss(animated: true)
      }
    }
    
    createBackBarButton(on: .left, by: .set) { (action) in
      self.dismiss(animated: true, completion: nil)
    }
    
    switch orderViewModel?.searchControllerType {
      case .usersCars:
        self.title = "Выберите авто"
      case .servicesList:
        self.title = "Тип сервиса"
      default:
        self.title = ""
    }
    
    tableView.paginatedDelegate = self
    tableView.paginatedDataSource = self
    tableView.enablePullToRefresh = true
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    self.navigationController?.navigationBar.prefersLargeTitles = true
    let search = UISearchController(searchResultsController: nil)
    search.searchResultsUpdater = self
    search.searchBar.delegate = self
    switch viewModel?.searchControllerType {
      case .auto,.model:
      self.navigationItem.searchController = search
      self.navigationItem.hidesSearchBarWhenScrolling = false
      default: return
    }
  }
  
  func fetchData() {
    self.viewModel!.resetPage()
    switch viewModel!.searchControllerType {
      case .auto:
        self.viewModel?.loadManufactures(success: { value in
          self.tableView.reloadData()
        }, shouldLoadNew:{}, failedBlock: { (error) in
          print(error)
        })
      case .model:
        self.viewModel?.loadAutoModels(success: { value in
          self.tableView.reloadData()
        }, shouldLoadNew: {}, failedBlock: { (error) in
          print(error)
        })
      default: return
    }
  }
}

// MARK: - Search control result

extension SearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
  func updateSearchResults(for searchController: UISearchController) {
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    self.viewModel?.updateSearchTextValue(searchText)
    fetchData()
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    self.viewModel?.updateSearchTextValue("")
  }
}

// MARK: - TableViewDataSource
extension SearchViewController: PaginatedTableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if viewModel != nil {
      return viewModel!.numberOfRowsInSectionForSearchController()
    } else {
      return orderViewModel!.numberOfRowsInSectionForSearchController()
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if viewModel != nil {
      return viewModel!.cellForSearchController(tableView, indexPath: indexPath)
    } else {
      return orderViewModel!.cellForSearchController(tableView, indexPath: indexPath)
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    tableView.resetAccessoryType()
    if viewModel != nil {
      viewModel!.selectCell(index: indexPath.row)
      switch self.viewModel?.searchControllerType {
        case .auto:
          itemSelected?(indexPath.row, (self.viewModel?.manufactures[indexPath.row].title)!)
        case .model:
          itemSelected?(indexPath.row, (self.viewModel?.autoModels[indexPath.row].title)!)
        case .generations:
          itemSelected?(indexPath.row,(self.viewModel?.autoGenerations[indexPath.row].title)!)
        case .bodyType:
          itemSelected?(indexPath.row,(self.viewModel?.autoBodyTypes[indexPath.row].title)!)
        case .modifications:
          itemSelected?(indexPath.row,(self.viewModel?.autoModifications[indexPath.row].title)!)
        default:
          return
      }
      self.dismiss(animated: true, completion: nil)
    } else {
      orderViewModel!.selectCell(index: indexPath.row)
    }
    cell?.accessoryType = .checkmark
  }
  
}

// MARK: Paginated Delegate - Where magic happens

extension SearchViewController: PaginatedTableViewDelegate {
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
  
  func loadMore(_ pageNumber: Int, _ pageSize: Int, onSuccess: ((Bool) -> Void)?, onError: ((Error) -> Void)?) {
    
    switch viewModel!.searchControllerType {
      case .auto:
        self.viewModel?.loadManufactures(success: { value in
          onSuccess?(value)
        }, shouldLoadNew:{}, failedBlock: { (error) in
          print(error)
          onError?(error)
        })
      case .model:
        self.viewModel?.loadAutoModels(success: { value in
          onSuccess?(value)
        }, shouldLoadNew: {}, failedBlock: { (error) in
          print(error)
          onError?(error)
        })
      default:
        onSuccess?(false)
      //      case .bodyType:
      //        self.viewModel?.loadBodyTypes(success: {
      //          onSuccess?(true)
      //        }, failedBlock: { (error) in
      //          print(error)
      //        })
      //      case .generations:
      //        self.viewModel?.loadGenerations(success: {
      //          onSuccess?(true)
      //        }, failedBlock: { (error) in
      //          print(error)
      //        })
      //      case .gearBoxType:
      //        self.viewModel?.loadGearTypes(success: {
      //          onSuccess?(true)
      //        }, failedBlock: { (error) in
      //          print(error)
      //        })
      //      case .usersCars:
      //        self.orderViewModel?.loadUsersCars(success: {
      //          onSuccess?(true)
      //        }, failedBlock: { (error) in
      //          print(error)
      //        })
      //      case .servicesList:
      //        self.orderViewModel?.loadServicesList(success: {
      //          onSuccess?(true)
      //        }, failedBlock: { (error) in
      //          print(error)
      //        })
      //      case .capacity:
      //        return
    }
    
    
    //  showHUD()
    //    if viewModel != nil {
    //      switch viewModel!.searchControllerType {
    //        case .city:
    //          self.viewModel?.loadCities(success: {
    //            onSuccess?(true)
    //          }, failedBlock: { (error) in
    //            print(error)
    //          })
    //        case .auto:
    //          self.viewModel?.loadManufactures(success: {
    //            onSuccess?(true)
    //          }, failedBlock: { (error) in
    //            print(error)
    //          })
    //        case .model:
    //          self.viewModel?.loadAutoModels(success: {
    //            onSuccess?(true)
    //          }, failedBlock: { (error) in
    //            print(error)
    //          })
    //
    //        case .bodyType:
    //          self.viewModel?.loadBodyTypes(success: {
    //            onSuccess?(true)
    //          }, failedBlock: { (error) in
    //            print(error)
    //          })
    //        case .generations:
    //          self.viewModel?.loadGenerations(success: {
    //            onSuccess?(true)
    //          }, failedBlock: { (error) in
    //            print(error)
    //          })
    //        case .gearBoxType:
    //          self.viewModel?.loadGearTypes(success: {
    //            onSuccess?(true)
    //          }, failedBlock: { (error) in
    //            print(error)
    //          })
    //        case .usersCars:
    //          self.orderViewModel?.loadUsersCars(success: {
    //            onSuccess?(true)
    //          }, failedBlock: { (error) in
    //            print(error)
    //          })
    //        case .servicesList:
    //          self.orderViewModel?.loadServicesList(success: {
    //            onSuccess?(true)
    //          }, failedBlock: { (error) in
    //            print(error)
    //          })
    //        case .capacity:
    //        return
    //      }
    //    } else {
    //      switch orderViewModel!.searchControllerType {
    //        case .city:
    //          self.viewModel?.loadCities(success: {
    //            onSuccess?(true)
    //          }, failedBlock: { (error) in
    //            print(error)
    //          })
    //        case .auto:
    //          self.viewModel?.loadManufactures(success: {
    //            onSuccess?(true)
    //          }, failedBlock: { (error) in
    //            print(error)
    //          })
    //        case .model:
    //          self.viewModel?.loadAutoModels(success: {
    //            onSuccess?(true)
    //          }, failedBlock: { (error) in
    //            print(error)
    //          })
    //
    //        case .bodyType:
    //          self.viewModel?.loadBodyTypes(success: {
    //            onSuccess?(true)
    //          }, failedBlock: { (error) in
    //            print(error)
    //          })
    //        case .gearBoxType:
    //          self.viewModel?.loadGearTypes(success: {
    //            onSuccess?(true)
    //          }, failedBlock: { (error) in
    //            print(error)
    //          })
    //        case .usersCars:
    //          self.orderViewModel?.loadUsersCars(success: {
    //            onSuccess?(true)
    //          }, failedBlock: { (error) in
    //            print(error)
    //          })
    //        case .servicesList:
    //          self.orderViewModel?.loadServicesList(success: {
    //            onSuccess?(true)
    //          }, failedBlock: { (error) in
    //            print(error)
    //          })
    //        case .capacity:
    //        return
    //        case .generations:
    //        return
    //      }
    //    }
    //
  }
  
}
