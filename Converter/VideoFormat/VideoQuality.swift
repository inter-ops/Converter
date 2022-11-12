//
//  VideoQuality.swift
//  Converter
//
//  Created by Justin Bush on 11/12/22.
//

enum VideoQuality: String, CaseIterable {
  case betterQuality, balanced, smallerSize
  
  var dropdownTitle: String {
    switch self {
    case .betterQuality: return "Better Quality"
    case .balanced: return "Balanced"
    case .smallerSize: return "Smaller Size"
    }
  }
  
  enum ProRes: String, CaseIterable {
    case auto, proxy, lt, standard, hq, res4444, xq
    
    var dropdownTitle: String {
      switch self {
      case .auto: return "Auto"
      case .proxy: return "ProRes 422 Proxy"
      case .lt: return "ProRes 422 LT"
      case .standard: return "ProRes 422"
      case .hq: return "ProRes 422 HQ"
      case .res4444: return "ProRes 4444"
      case .xq: return "ProRes 4444 XQ"
      }
    }
    
  }
  
}
