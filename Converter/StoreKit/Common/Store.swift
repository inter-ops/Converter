//
//  Store.swift
//  Converter
//
//  Created by Justin Bush on 12/6/22.
//

import Foundation

struct Store {
  
  enum Products: String {
    // Video Convert Pro (Production)
    case premium = "io.airtv.iap.VideoConverterPro"
    
    // Consumable Testing (Never Purchased)
    //case premium = "io.airtv.VideoConverterConsumableDebug"
    // Non-Consumable Testing (Always Purchased)
    //case premium = "VC0089E74P"
    
    // For more info on consumable and non-consumable testing, see:
    // https://stackoverflow.com/questions/7747457/clearing-purchases-from-ios-in-app-purchase-sandbox-for-a-test-user
  }
  
}

// MARK: Product Variables

extension Store.Products {
  
  var id: String {
    return self.rawValue
  }

  var setId: Set<String> {
    let productIds: Set = [self.rawValue]
    return productIds
  }
  
  func callAsFunction() -> Set<String> {
    return setId
  }
  
}

extension Store {
  
  static func isLegacy() -> Bool {
    if #available(OSX 12, *) {
      return false  // StoreKit 2
    }
    return true     // StoreKit Legacy
  }
  
}
