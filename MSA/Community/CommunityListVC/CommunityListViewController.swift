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
    
    var presenter: CommunityListPresenterProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = CommunityListPresenter(view: self)
    }
}
