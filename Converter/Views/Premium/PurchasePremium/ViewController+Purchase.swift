//
//  ViewController+Purchase.swift
//  Converter
//
//  Created by Justin Bush on 11/4/22.
//

import Cocoa

extension ViewController {
  
  /// Present the user with a PurchasePremium sheet if they are not premium
  func checkAndShowPurchasePremium() {
    if !userDidPurchasePremium {
      segue(.sheetPurchasePremium)
    }
  }
  
  // TODO: Purchase Handler state changes in ViewController go here:
  // 1. User did purchase premium, update UI elements to reflect
  // 2. Disable PurchasePremium prompts
  
}
