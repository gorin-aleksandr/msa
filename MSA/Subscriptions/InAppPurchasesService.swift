//
//  InAppPurchasesService.swift
//  MSA
//
//  Created by Andrey Krit on 2/10/19.
//  Copyright © 2019 Pavlo Kharambura. All rights reserved.
//

import Foundation
import StoreKit

class InAppPurchasesService: NSObject {
    
    static let shared = InAppPurchasesService()
    
    var options: [Product]? {
        didSet {
            print(options)
            print("Options nedd to be set")
        }
    }
    
    func loadProductOptions() {
        
        let productIDs = Set(["s_one_month", "s_three_month", "freeSub"])
        let request = SKProductsRequest(productIdentifiers: productIDs)
        request.delegate = self
        request.start()
        
    }

}

extension InAppPurchasesService: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print(response.products)
        print(response.invalidProductIdentifiers)
        options = response.products.map { Product(product: $0) }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        if request is SKProductsRequest {
            print("Subscription Options Failed Loading: \(error.localizedDescription)")
        }
    }
}
