//
//  IAPStore.swift
//  Converter
//
//  Created by Justin Bush on 12/12/22.
//  https://github.com/tikhop/TPInAppReceipt.git
//

import Foundation
import StoreKit
import TPInAppReceipt


open class IAPStore: NSObject {
  public struct Products {
    public static let premium = Store.Products.premium.id
    
    fileprivate static let identifiers : Set<String> = [Products.premium]
  }
  
  fileprivate let productIdentifiers: Set<String>
  
  fileprivate var productsRequest: SKProductsRequest?
  fileprivate var productsRequestCompletionHandler: ((_ success: Bool, _ products: [SKProduct]?) -> ())?
  
  // a shared instance with preset product identifiers, we will be using this mostly
  static let shared = IAPStore(productIds: Products.identifiers)
  
  // name of the notification that will be sent after purchase success
  static let IAPStorePurchaseNotification = NSNotification.Name("IAPStorePurchaseNotification")
  
  // name of the notification that will be sent if the purchase failed
  static let IAPStoreFailedNotification = NSNotification.Name("IAPStoreFailedNotification")
  
  // name of the notification that will be sent after restore success
  static let IAPStoreRestoreNotification = NSNotification.Name("IAPStoreRestoreNotification")
  
  // name of the notification that will be sent when there is nothing to restore
  // user tap 'restore purchase' without having any prior purchase
  static let IAPStoreEmptyRestoreNotification = NSNotification.Name("IAPStoreEmptyRestoreNotification")
  
  public init(productIds: Set<String>) {
    productIdentifiers = productIds
    super.init()
    SKPaymentQueue.default().add(self)
  }
}

// MARK: - Utility functions
extension IAPStore {
  
  /// Request IAP products from App Store server
  /// - Parameter completionHandler: function that will be executed after retrieving the products
  public func requestProducts(completionHandler: @escaping (_ success: Bool, _ products: [SKProduct]?) -> ()) {
    
    productsRequest?.cancel()
    productsRequestCompletionHandler = completionHandler
    
    productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
    productsRequest!.delegate = self
    productsRequest!.start()
  }
  
  /// Buy the specific IAP Product
  /// - Parameter product: the IAP Product to purchase
  public func purchaseProduct(_ product: SKProduct) {
    print("Purchasing \(product.productIdentifier)...")
    let payment = SKPayment(product: product)
    SKPaymentQueue.default().add(payment)
  }
  
  
  /// Check if user has already purchased the specific IAP product
  /// - Parameter productIdentifier: the IAP Product Identifier
  /// - Returns: boolean
  public func isProductPurchased(_ productIdentifier: String) -> Bool {
    if let receipt = try? InAppReceipt.localReceipt(){
      if receipt.containsPurchase(ofProductIdentifier: productIdentifier) {
        return true
      }
    }
    
    return false
  }
  
  
  /// Check if user has active subscription. If product identifier is nil, then it will check
  /// if user has any active subscriptions regardless of product identifier
  /// - Parameter productIdentifier: the product identifier of the subscription
  /// - Returns: boolean
  public func isSubscriptionActive(_ productIdentifier: String?) -> Bool {
    if let receipt = try? InAppReceipt.localReceipt(){
      if let productIdentifier = productIdentifier {
        return receipt.hasActiveAutoRenewableSubscription(ofProductIdentifier: productIdentifier, forDate: Date())
      }
      
      return receipt.hasActiveAutoRenewablePurchases
    }
    
    return false
  }
  
  /// Restore previous purchases, the receipt will be refreshed after restoration
  public func restorePurchases() {
    SKPaymentQueue.default().restoreCompletedTransactions()
  }
  
  /// In case parental control disable kids to buy app, this will return false
  public class func canMakePayments() -> Bool {
    // in case parental control disable kids to buy app, this will return false
    return SKPaymentQueue.canMakePayments()
  }
}

// MARK: - SKProductsRequestDelegate
extension IAPStore: SKProductsRequestDelegate {
  public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
    
    let products = response.products
    productsRequestCompletionHandler?(true, products)
    
    // reset the request and completion handler
    productsRequest = nil
    productsRequestCompletionHandler = nil
  }
  
  public func request(_ request: SKRequest, didFailWithError error: Error) {
    productsRequestCompletionHandler?(false, nil)
    
    // reset the request and completion handler
    productsRequest = nil
    productsRequestCompletionHandler = nil
  }
}

// MARK: - SKPaymentTransactionObserver
extension IAPStore: SKPaymentTransactionObserver {
  public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    
    for transaction in transactions {
      switch (transaction.transactionState) {
      case .purchased:
        complete(transaction: transaction)
        break
      case .failed:
        fail(transaction: transaction)
        break
      case .restored:
        restore(transaction: transaction)
        break
      case .deferred:
        break
      case .purchasing:
        break
      @unknown default:
        break
      }
    }
  }
  
  public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
    if(queue.transactions.isEmpty){
      // post notification that there is nothing to restore
      NotificationCenter.default.post(name: IAPStore.IAPStoreEmptyRestoreNotification, object: nil)
      
      return
    }
    
    for transaction in queue.transactions {
      switch (transaction.transactionState) {
      case .purchased:
        complete(transaction: transaction)
        break
      case .failed:
        fail(transaction: transaction)
        break
      case .restored:
        restore(transaction: transaction)
        break
      case .deferred:
        break
      case .purchasing:
        break
      @unknown default:
        break
      }
    }
  }
  
  private func complete(transaction: SKPaymentTransaction) {
    NotificationCenter.default.post(name: IAPStore.IAPStorePurchaseNotification, object: transaction.payment.productIdentifier)
    
    SKPaymentQueue.default().finishTransaction(transaction)
  }
  
  private func restore(transaction: SKPaymentTransaction) {
    NotificationCenter.default.post(name: IAPStore.IAPStoreRestoreNotification, object: transaction.original?.payment.productIdentifier)
    
    SKPaymentQueue.default().finishTransaction(transaction)
  }
  
  private func fail(transaction: SKPaymentTransaction) {
    if let transactionError = transaction.error as NSError?,
       let localizedDescription = transaction.error?.localizedDescription,
       transactionError.code != SKError.paymentCancelled.rawValue {
      
      // only post the fail notification if the error isn't user cancel (ie. user tap 'Cancel' on the payment prompt dialog)
      NotificationCenter.default.post(name: IAPStore.IAPStoreFailedNotification, object: localizedDescription)
    }
    
    SKPaymentQueue.default().finishTransaction(transaction)
  }
}
