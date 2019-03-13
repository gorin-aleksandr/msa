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
    
    let sharedSecret = "f89bf31cc7cf4905900af42fda54c46e"
    
    static let optionsLoadedNotification = Notification.Name("SubscriptionServiceOptionsLoadedNotification")
    static let restoreSuccessfulNotification = Notification.Name("SubscriptionServiceRestoreSuccessfulNotification")
    static let purchaseSuccessfulNotification = Notification.Name("SubscriptionServiceRestoreSuccessfulNotification")

    static let shared = InAppPurchasesService()
    
    var options: [Product]? {
        didSet {
           NotificationCenter.default.post(name: InAppPurchasesService.optionsLoadedNotification, object: options)
        }
    }
    
    var paidSubscriptions: [PaidSubscription] = []
    
    var currentSubscription: PaidSubscription? {
        let activeSubscriptions = paidSubscriptions.filter { $0.isActive }
        let sortedByMostRecentPurchase = activeSubscriptions.sorted { $0.purchaseDate > $1.purchaseDate }
        return sortedByMostRecentPurchase.first
    }
    
    var hasReceiptData: Bool {
        return loadReceipt() != nil
    }
    
    func loadProductOptions() {
        let productIds = Set(["s_one_month", "s_three_month", "s_six_month", "s_twelve_month", "t_one_month", "t_three_month", "t_six_month", "t_twelve_month"])
        let request = SKProductsRequest(productIdentifiers: productIds)
        request.delegate = self
        request.start()
        
    }
    
    func purchase(subscription: Product) {
        let payment = SKPayment(product: subscription.product)
        SKPaymentQueue.default().add(payment)
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    private func loadReceipt() -> Data? {
        guard let url = Bundle.main.appStoreReceiptURL else {
            return nil
        }
        print(url)
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            print("Error loading receipt data: \(error.localizedDescription)")
            return nil
        }
    }
    
    func uploadReceipt(completion: ((_ success: Bool) -> Void)? = nil) {
        if let receiptData = loadReceipt() {
            self.validate(receipt: receiptData) { [weak self] (loaded) in
                completion?(loaded)
//                switch result {
//                case .success(let result):
//                    strongSelf.currentSessionId = result.sessionId
//                    strongSelf.currentSubscription = result.currentSubscription
//                    completion?(true)
//                case .failure(let error):
//                    print("🚫 Receipt Upload Failed: \(error)")
//                    completion?(false)
//                }
            }
        } else {
            completion?(false)
            print("Missing receipt data")
        }
    }
    
    func validate(receipt data: Data, completion: @escaping (_ success: Bool) -> ()) {
        let body = [
            "receipt-data": data.base64EncodedString(),
            "password": sharedSecret
        ]
        let bodyData = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        let url = URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        
        let task = URLSession.shared.dataTask(with: request) { (responseData, response, error) in
            if let error = error {
               print("Error while loading")
                completion(false)
            } else if let responseData = responseData {
                let json = try! JSONSerialization.jsonObject(with: responseData, options: []) as! Dictionary<String, Any>
                print(json["receipt"])
                if let receipt = json["receipt"] as? [String: Any], let purchases = receipt["in_app"] as? Array<[String: Any]> {
                    var subscriptions = [PaidSubscription]()
                    for purchase in purchases {
                        if let paidSubscription = PaidSubscription(json: purchase) {
                            subscriptions.append(paidSubscription)
                        }
                    }
                    
                    self.paidSubscriptions = subscriptions
                } else {
                    self.paidSubscriptions = []
                }
                completion(true)
            }
        }
        
        task.resume()
    }

}

extension InAppPurchasesService: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        options = response.products.map { Product(product: $0) }
            .filter({ product -> Bool in
                if AuthModule.currUser.userType == .trainer {
                    return product.type == .trainer
                } else {
                    return product.type == .sportsman
                }
            })
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        if request is SKProductsRequest {
            print("Subscription Options Failed Loading: \(error.localizedDescription)")
        }
    }
}
