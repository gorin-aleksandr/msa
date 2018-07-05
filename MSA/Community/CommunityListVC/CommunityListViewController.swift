//
//  CummunityListViewController.swift
//  MSA
//
//  Created by Andrey Krit on 7/4/18.
//  Copyright © 2018 Pavlo Kharambura. All rights reserved.
//

import UIKit

protocol CommunityListViewProtocol: class {
    
}

class CommunityListViewController: UIViewController, CommunityListViewProtocol {
    
    @IBOutlet weak var communityTableView: UITableView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterScrollView: UIScrollView!
    
    var presenter: CommunityListPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = CommunityListPresenter(view: self)
        communityTableView.delegate = self
        communityTableView.dataSource = self
        presenter.start()
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
