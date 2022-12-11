//
//  StoreKitValidation.swift
//  Converter
//
//  Created by Justin Bush on 12/10/22.
//

import Foundation

extension ViewController {
  
  // The following are optional methods for receipt validation intervals
  // Should only be applied if userDidPurchasePremium == true
  
  // Method 1
  // set date = now
  // if date > 5 days ago: remove pro, perform restore purchase check
  // check server flag
  
  // Method 2
  // app launches = 0; ++1
  // if app launches > 5: remove pro, perform restore purchase check
  // check server flag
  
  // Method 3
  
  
}
