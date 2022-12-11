//
//  ViewController+StoreKit.swift
//  Converter
//
//  Created by Justin Bush on 12/6/22.
//

import Cocoa
import StoreKit

extension ViewController {
  
  func initStoreKitHelper() {
    StoreKitHelper.shared.getProducts(products: Products.premium())
  }
  
  func purchasePremium() {
    Logger.debug("StoreKit: User is requesting premium purchase transaction")
    beginPurchasePremiumSession()
  }
  
  func restorePremium() {
    Logger.debug("StoreKit: User is attempting to restore their premium purchase")
    beginPurchasePremiumSession()
  }
  
  func beginPurchasePremiumSession() {
    StoreKitHelper.shared.purchase(productIdentifier: Products.premium.id) { (transaction) in
      switch transaction.transactionState {
      case .purchased:
        // User did purchase premium
        break
      case .restored:
        // User did restore in purchase session
        break
      case .deferred:
        // User did defer transaction; session will end
        break
      case .failed:
        // User did fail transaction; either cancelled or rejected
        break
      default: break
      }
    }
  }
  
  func beginRestorePurchaseSession() {
    StoreKitHelper.shared.restorePurchases { (transaction) in
      switch transaction.transactionState {
      case .purchased:
        // Should never get be called
        break
      case .restored:
        // User did manage to restore successfully
        break
      case .deferred:
        // User did defer restore transaction; session will end
        break
      case .failed:
        // User did fail to restore purchase; user does not own product (possible refund case)
        break
      default: break
      }
    }
  }
  
}
