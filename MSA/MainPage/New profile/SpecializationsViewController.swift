//
//  searchSignInViewController.swift
//  
//
//  Created by Nik on 17.03.2020.
//

import UIKit
import SVProgressHUD

class SpecializationsViewController: UIViewController {
  
  var viewModel: ProfileViewModel?
  
  @IBOutlet weak var tableView: UITableView!
  
  var itemSelected: ((Int,String) -> ())?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    let backButton = UIBarButtonItem(image: UIImage(named: "backIcon"), style: .plain, target: self, action: #selector(self.backAction))
    self.navigationItem.leftBarButtonItem = backButton
    self.navigationController?.navigationBar.tintColor = .newBlack
    
    viewModel?.fetchSpecialization(completion: { (value) in
      self.tableView.reloadData()
    })
  }
  
  @objc func backAction() {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func nextAction(_ sender: Any) {
    print("action!")
  }
  
  func setupUI() {
    title = "Выбери специализации"
    tableView.contentInsetAdjustmentBehavior = .never
    tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 0)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    
    let saveButton = UIButton(type: .custom) as UIButton
    self.view.addSubview(saveButton)
    saveButton.titleLabel?.font = NewFonts.SFProDisplayBold16
    saveButton.setTitleColor(UIColor.white, for: .normal)
    saveButton.setTitle("Сохранить", for: .normal)
    saveButton.setBackgroundColor(color: UIColor.newBlue, forState: .normal)
    saveButton.layer.cornerRadius = screenSize.height * (16/iPhoneXHeight)
    saveButton.layer.masksToBounds = true
    saveButton.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
    saveButton.snp.makeConstraints { (make) in
      make.bottom.equalTo(self.view.snp.bottom).offset(screenSize.height * (-30/iPhoneXHeight))
      make.left.equalTo(self.view.snp.left).offset(screenSize.width * (16/iPhoneXWidth))
      make.right.equalTo(self.view.snp.right).offset(screenSize.width * (-16/iPhoneXWidth))
      make.height.equalTo(screenSize.height * (54/iPhoneXHeight))
    }
  }
  
  @objc func saveAction(_ sender: UIButton) {
    SVProgressHUD.show()
    self.viewModel!.saveSpecialization { (value) in
      SVProgressHUD.dismiss()
      if value {
        self.dismiss(animated: true, completion: nil)
      }
    }
  }
  
  func fetchData() {
    
  }
}

// MARK: - TableViewDataSource
extension SpecializationsViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel!.numberOfRowSpecializationDataController(section: section)
  }


func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
  return UITableView.automaticDimension
}


func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  return viewModel!.specializationCell(indexPath: indexPath, tableView: tableView)
}

func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      let cell = tableView.cellForRow(at: indexPath) as! SpecializationCell
  if cell.accessoryType == .checkmark {
    cell.accessoryType = .none
  } else {
    cell.accessoryType = .checkmark
  }
  viewModel!.selectDeselectSpecialization(index: indexPath.row)
  //    if viewModel != nil {
  //      viewModel!.selectCell(index: indexPath.row)
  //      switch self.viewModel?.searchControllerType {
  //        case .auto:
  //          itemSelected?(indexPath.row, (self.viewModel?.manufactures[indexPath.row].title)!)
  //        case .model:
  //          itemSelected?(indexPath.row, (self.viewModel?.autoModels[indexPath.row].title)!)
  //        case .generations:
  //          itemSelected?(indexPath.row,(self.viewModel?.autoGenerations[indexPath.row].title)!)
  //        case .bodyType:
  //          itemSelected?(indexPath.row,(self.viewModel?.autoBodyTypes[indexPath.row].title)!)
  //        case .modifications:
  //          itemSelected?(indexPath.row,(self.viewModel?.autoModifications[indexPath.row].title)!)
  //        default:
  //          return
  //      }
  //      self.dismiss(animated: true, completion: nil)
  //    } else {
  //      orderViewModel!.selectCell(index: indexPath.row)
  //    }
  //    cell?.accessoryType = .checkmark
}

}
