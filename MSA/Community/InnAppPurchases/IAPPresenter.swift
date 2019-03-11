//
//  IAPPresenter.swift
//  MSA
//
//  Created by Andrey Krit on 2/27/19.
//  Copyright © 2019 Pavlo Kharambura. All rights reserved.
//

import Foundation

protocol IAPPresenterProtocol {
    func getProductsDataSource() -> [Product]
    func userSelectedProductAt(index: Int)
    func fetchSubscriptions()
}

class IAPPresenter: IAPPresenterProtocol {
    
    
    var productsDataSource: [Product] {
        return InAppPurchasesService.shared.options?.sorted(by: { lhs, rhs -> Bool in
            lhs.product.price.doubleValue < rhs.product.price.doubleValue }) ?? []
    }
    
    private unowned var view: IAPViewProtocol
    
    init(view: IAPViewProtocol) {
        self.view = view
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleOptionsLoaded(notification:)),
                                               name: InAppPurchasesService.optionsLoadedNotification,
                                               object: nil)
    }
    
    func fetchSubscriptions() {
        InAppPurchasesService.shared.loadProductOptions()
    }
    
    func getProductsDataSource() -> [Product] {
        return productsDataSource
    }
    
    func userSelectedProductAt(index: Int) {
        InAppPurchasesService.shared.purchase(subscription: productsDataSource[index])
    }
    
    @objc func handleOptionsLoaded(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.view.reloadView()
            self?.view.setLoaderVisible(false)
        }
    }
    
    deinit {
         NotificationCenter.default.removeObserver(self)
    }
    
}

