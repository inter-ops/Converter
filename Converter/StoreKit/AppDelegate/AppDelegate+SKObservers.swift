//
//  AppDelegate+SKObservers.swift
//  Converter
//
//  Created by Justin Bush on 12/18/22.
//

import Foundation

extension AppDelegate {
  
  func initSKObservers() {
    NotificationCenter.default.addObserver(self, selector: #selector(self.purchaseNotification(notification:)), name: IAPStore.IAPStorePurchaseNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.purchaseFailedNotification(notification:)), name: IAPStore.IAPStoreFailedNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.restoreNotification(notification:)), name: IAPStore.IAPStoreRestoreNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.emptyRestoreNotification(notification:)), name: IAPStore.IAPStoreEmptyRestoreNotification, object: nil)
  }
  
  @objc func purchaseNotification(notification: Notification) {
    Logger.debug("StoreKit: User successfully purchased Premium")
  }
  
  @objc func purchaseFailedNotification(notification: Notification) {
    Logger.debug("StoreKit: User's attempt to purchase Premium has failed")
  }
  
  @objc func restoreNotification(notification: Notification) {
    Logger.debug("StoreKit: User successfully restored purchases")
    // Note: This will still call successfully if the user has refunded
    //if Server.hasValidPurchase { [can enable premium now] }
  }
  
  @objc func emptyRestoreNotification(notification: Notification) {
    Logger.debug("StoreKit: User has no valid restorable purchases")
  }
  
}
