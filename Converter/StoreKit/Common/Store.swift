//
//  Store.swift
//  Converter
//
//  Created by Justin Bush on 12/6/22.
//

import Foundation

struct Store {
  
  static func isLegacy() -> Bool {
    if #available(OSX 12, *) {
      return false  // StoreKit 2
    }
    return true     // StoreKit Legacy
  }
  
}
