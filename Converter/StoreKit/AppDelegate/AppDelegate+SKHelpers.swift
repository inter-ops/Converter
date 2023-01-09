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
  }
  
  func restorePurchases() {
    IAPStore.shared.restorePurchases()
  }
  
 
}

