//
//  IAPViewController.swift
//  MSA
//
//  Created by Andrey Krit on 2/27/19.
//  Copyright © 2019 Pavlo Kharambura. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol IAPViewProtocol: class {
    func reloadView()
    func setLoaderVisible(_ visible: Bool)
    func showAlert(error: String)
}

class IAPViewController: UIViewController, IAPViewProtocol {
    
    @IBOutlet weak var promotionTextLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var termsButton: UIButton!
    
    var presenter: IAPPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPromotionText()
        presenter.fetchSubscriptions()
        configureTableView()
        configureNavigationBar()
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func configureNavigationBar() {
        let dismissButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ok_blue"), style: .plain, target: self, action: #selector(self.goBack))
        navigationItem.rightBarButtonItem = dismissButton
        self.navigationItem.title = "Покупки"
        let attrs = [NSAttributedString.Key.foregroundColor: UIColor.white,
                     NSAttributedString.Key.font: UIFont(name: "Rubik-Medium", size: 17)!]
        self.navigationController?.navigationBar.titleTextAttributes = attrs
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }
    
    func showAlert(error: String) {
        let alertController = UIAlertController(title: "Ошибка при загрузке встроеных покупок", message: error, preferredStyle: .alert)
        let repeatAction = UIAlertAction(title: "Повторить", style: .default) { (action) in
            self.presenter.fetchSubscriptions()
        }
        let cancelAction = UIAlertAction(title: "Отменить", style: .default) { (action) in }
        alertController.addAction(repeatAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    private func setPromotionText() {
        promotionTextLabel.text = presenter.setPromotionText()
    }
    
    @objc func goBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func reloadView() {
        tableView.reloadData()
    }
    
    func setLoaderVisible(_ visible: Bool) {
        visible ? SVProgressHUD.show() : SVProgressHUD.dismiss()
    }

    @IBAction func temsButtonDidTapped(_ sender: Any) {
        presenter.presentTermsAndConditions()
    }
}

extension IAPViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getProductsDataSource().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IAPTableViewCell") as! IAPTableViewCell
        cell.configureWith(product: presenter.getProductsDataSource()[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.userSelectedProductAt(index: indexPath.row)
    }
    
    
}
