//
//  ViewController+SKObservers.swift
//  Converter
//
//  Created by Justin Bush on 12/19/22.
//

import Foundation

extension IAPStore {
  static let PremiumPurchaseStatusDidChangeNotification = NSNotification.Name("PremiumPurchaseStatusDidChangeNotification")
}

extension ViewController {
  
  func initSKObservers() {
    NotificationCenter.default.addObserver(self, selector: #selector(self.premiumPurchaseStatusDidChangeNotification(notification:)), name: IAPStore.PremiumPurchaseStatusDidChangeNotification, object: nil)
  }
  
  @objc func premiumPurchaseStatusDidChangeNotification(notification: Notification) {
    Logger.debug("StoreKit: Premium purchase status has changed")
    
    
  }
  
}
