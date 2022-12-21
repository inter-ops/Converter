//
//  ViewController+SKObservers.swift
//  Converter
//
//  Created by Justin Bush on 12/19/22.
//

import Foundation

extension IAPStore {
  static let PremiumPurchaseStatusDidChangeNotification = NSNotification.Name("PremiumPurchaseStatusDidChangeNotification")
  
  static let PremiumPurchaseNotification = NSNotification.Name("PremiumPurchaseNotification")
  static let RestorePurchaseNotification = NSNotification.Name("RestorePurchaseNotification")
}

extension ViewController {
  
  func initSKObservers() {
    NotificationCenter.default.addObserver(self, selector: #selector(self.premiumPurchaseStatusDidChangeNotification(notification:)), name: IAPStore.PremiumPurchaseStatusDidChangeNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.premiumPurchaseNotification(notification:)), name: IAPStore.PremiumPurchaseNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.restorePurchaseNotification(notification:)), name: IAPStore.RestorePurchaseNotification, object: nil)
  }
  
  @objc func premiumPurchaseStatusDidChangeNotification(notification: Notification) {
    Logger.debug("StoreKit: Premium purchase status has changed")
    // Prepare for update
  }
  
  @objc func premiumPurchaseNotification(notification: Notification) {
    Logger.debug("User purchase was successfuly; enabling Premium...")
    // enablePremium
  }
  
  @objc func restorePurchaseNotification(notification: Notification) {
    if appDelegate.premiumPurchaseIsValid() {
      Logger.debug("User restore was successful; enabling Premium")
      // enablePremium
      return
    }
  }
  
}
