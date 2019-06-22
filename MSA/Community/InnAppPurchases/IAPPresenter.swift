//
//  IAPPresenter.swift
//  MSA
//
//  Created by Andrey Krit on 2/27/19.
//  Copyright © 2019 Pavlo Kharambura. All rights reserved.
//

import Foundation
import UIKit

protocol IAPPresenterProtocol {
    func getProductsDataSource() -> [Product]
    func userSelectedProductAt(index: Int)
    func fetchSubscriptions()
    func setPromotionText() -> String
    func presentTermsAndConditions()
}

class IAPPresenter: IAPPresenterProtocol, InAppPurchasesServiceDelegate {
    
    var productsDataSource: [Product] {
        return InAppPurchasesService.shared.options?.sorted(by: { lhs, rhs -> Bool in
            lhs.product.price.doubleValue < rhs.product.price.doubleValue }) ?? []
    }
    
    private unowned var view: IAPViewProtocol
    
    init(view: IAPViewProtocol) {
        self.view = view
        InAppPurchasesService.shared.delegate = self
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
    
    func setPromotionText() -> String {
        if AuthModule.currUser.userType == .trainer {
            return "Получите доступ к Сообщесту и возможности составления программ тренировок для своих спортсменов, оформив подписку. Выберите один из вариантов."
        } else {
            return "Получите доступ к Сообществу и возможности выбора Тренера, оформив подписку. Выберите один из вариантов."
        }
    }
    
    func subsctiptionOptionsLoadingFailed(with error: Error) {
        view.showAlert(error: error.localizedDescription)
    }
    
    func presentTermsAndConditions() {
            let termsStringUrl = "https://telegra.ph/Privacy-Police-and-Terms-Of-Use-03-12"
            if let url = URL(string: termsStringUrl) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
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

