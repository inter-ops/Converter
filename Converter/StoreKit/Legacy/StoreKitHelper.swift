//
//  StoreKitHelper.swift
//  Converter
//
//  Created by Justin Bush on 12/6/22.
//

import Foundation
import StoreKit

class StoreKitHelper: NSObject {
  
  static let shared = StoreKitHelper()
  let paymentQueue = SKPaymentQueue.default()
  var products = [SKProduct]()
  var completion: ((SKPaymentTransaction) -> Void)?
  
  private override init() { }
  
  func getProducts(products:Set<String>) {
    let request = SKProductsRequest(productIdentifiers: products)
    request.delegate = self
    request.start()
    paymentQueue.add(self)
  }
  
  func purchase(productIdentifier: String, completion: ((SKPaymentTransaction)-> Void)?) {
    guard let productToPurchase = products.filter({ $0.productIdentifier == productIdentifier }).first else { return }
    let payment = SKPayment(product: productToPurchase)
    paymentQueue.add(payment)
    self.completion = completion
  }
  
  func restorePurchases(completion: ((SKPaymentTransaction)-> Void)?) {
    paymentQueue.restoreCompletedTransactions()
    self.completion = completion
  }
}

extension StoreKitHelper: SKProductsRequestDelegate {
  func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    self.products = response.products
    for product in response.products {
      Logger.info("StoreKit: Successfully loaded product localization [\(product.localizedTitle)]")
    }
  }
}

extension StoreKitHelper: SKPaymentTransactionObserver {
  func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
      logTransaction(status: transaction.transactionState.status(), forProductId: transaction.payment.productIdentifier)
      switch transaction.transactionState {
      case .purchasing: break
      default:
        queue.finishTransaction(transaction)
        self.completion?(transaction)
      }
    }
  }
  
  func logTransaction(status: String, forProductId: String) {
    Logger.debug("StoreKit: \(status) for product [\(forProductId)]")
  }
}

extension SKPaymentTransactionState {
  func status() -> String {
    switch self {
    case .deferred: return "Deferred purchase"
    case .failed: return "Transaction failed"
    case .purchased: return "Transaction successful"
    case .purchasing: return "Attempting transaction"
    case .restored: return "Found restorable purchase"
    default: return "Unknown status"
    }
  }
}
