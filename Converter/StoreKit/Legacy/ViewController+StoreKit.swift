//
//  ViewController+StoreKit.swift
//  Converter
//
//  Created by Justin Bush on 12/6/22.
//

import Cocoa
import StoreKit

extension ViewController {
  
  
  
  func purchasePremium() {
    Logger.debug("StoreKit: User is requesting premium purchase transaction")
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
  
  func restorePremium() {
    Logger.debug("StoreKit: User is attempting to restore their premium purchase")
    beginRestorePurchaseSession()
  }
  
  func beginRestorePurchaseSession() {
    StoreKitHelper.shared.restorePurchases { (transaction) in
      switch transaction.transactionState {
      case .purchased:
        // Should never get be called
        print("restore: purchased")
        break
      case .restored:
        // User did manage to restore successfully
        print("restore: restored")
        break
      case .deferred:
        // User did defer restore transaction; session will end
        print("restore: deferred")
        break
      case .failed:
        // User did fail to restore purchase; user does not own product (possible refund case)
        print("restore: failed")
        break
      default:
        print("restore: default")
        break
      }
    }
  }
  
}
