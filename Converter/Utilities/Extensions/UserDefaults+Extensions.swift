//
//  UserDefaults+Extensions.swift
//  Converter
//
//  Created by Justin Bush on 1/3/23.
//

import Foundation

extension Constants.UDKeys {
  
  func callAsFunction() -> String {
    return self.rawValue
  }
  
}

extension UserDefaults {
  
  func flagAppVersionAsLowerThanRequired(_ value: Bool) {
    set(value, forKey: Constants.UDKeys.appVersionWasFlaggedAsLowerThanRequired())
  }
  
  func appVersionHasBeenFlagged() -> Bool {
    return bool(forKey: Constants.UDKeys.appVersionWasFlaggedAsLowerThanRequired())
  }
  
}
