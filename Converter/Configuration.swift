//
//  Configuration.swift
//  Converter
//
//  Created by Francesco Virga on 2022-09-12.
//

import Foundation

enum Environment: String {
  case debugDevelopment = "Development Debug"
  case releaseDevelopment = "Development Release"
  
  case debugProduction = "Production Debug"
  case releaseProduction = "Production Release"
}

class Config {
  static let shared = Config()
  
  var environment: Environment
  
  var debug: Bool {
    switch environment {
    case .debugDevelopment, .debugProduction:
      return true
    case .releaseDevelopment, .releaseProduction:
      return false
    }
  }
  
  init() {
    let currentConfiguration = Bundle.main.object(forInfoDictionaryKey: "Configuration") as! String
    
    environment = Environment(rawValue: currentConfiguration)!
  }
}
