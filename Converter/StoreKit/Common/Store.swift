//
//  Store.swift
//  Converter
//
//  Created by Justin Bush on 12/6/22.
//

import Foundation

struct Store {
  
  enum Products: String {
    case premium = "VC0089E74P"
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
