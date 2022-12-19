//
//  AppDelegate+Premium.swift
//  Converter
//
//  Created by Justin Bush on 12/17/22.
//

import Foundation

extension AppDelegate {
  
  func initPremium() {
    // Status check
  }
  
  func premiumPurchaseIsValid() -> Bool {
    if noRefundHistory() {
      return true
    }
    return false
  }
  
}
