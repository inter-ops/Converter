//
//  Products.swift
//  Converter
//
//  Created by Justin Bush on 12/3/22.
//

import Foundation

enum Products: String {
  
  case premium = "VC0089E74P"
  
}

// MARK: Product Variables

extension Products {
  
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
