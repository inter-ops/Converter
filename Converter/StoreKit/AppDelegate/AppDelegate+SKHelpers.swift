//
//  AppDelegate+SKHelpers.swift
//  Converter
//
//  Created by Justin Bush on 12/5/22.
//

import Foundation

extension AppDelegate {
  
  func purchasePremium() {
    StoreKitHelper.shared.purchase(productIdentifier: Store.Products.premium.id) { (transaction) in
      switch transaction.transactionState {
      case .purchased:
        // User did purchase premium
        NotificationCenter.default.post(name: IAPStore.IAPStorePurchaseNotification, object: nil)
        break
      case .restored:
        // User did restore in purchase session
        break
      case .deferred:
        // User did defer transaction; session will end
        break
      case .failed:
        // User did fail transaction; either cancelled or rejected
        NotificationCenter.default.post(name: IAPStore.IAPStoreFailedNotification, object: nil)
        break
      default: break
      }
    }
    //    IAPStore.shared.requestProducts(completionHandler: { (_, products) in
    //      if let premiumProduct = products?.first {
    //        IAPStore.shared.purchaseProduct(premiumProduct)
    //      }
    //    })
  }
  
  func restorePurchases() {
    IAPStore.shared.restorePurchases()
  }
  
  func checkReceiptForPremiumPurchaseHistory() {
    let receiptHasPremiumPurchase = IAPStore.shared.isProductPurchased(Store.Products.premium.id)
    if receiptHasPremiumPurchase {
      Logger.debug("StoreKit: Receipt does contain purchase history for Video Converter Pro")
      checkUserRefundStatus()
      return
    }
    Logger.debug("StoreKit: Receipt contains no purchase history")
  }
  
  
  
  
  
  
 
}



