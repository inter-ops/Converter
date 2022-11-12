//
//  VideoQuality.swift
//  Converter
//
//  Created by Justin Bush on 11/12/22.
//

enum VideoQuality: String, CaseIterable {
  case betterQuality, balanced, smallerSize
  
  case prAuto, prProxy, prLt, prStandard, prHq, pr4444, prXq
  
  var dropdownTitle: String {
    switch self {
    // Generic
    case .betterQuality: return "Better Quality"
    case .balanced: return "Balanced"
    case .smallerSize: return "Smaller Size"
    // ProRes
    case .prAuto: return "Auto"
    case .prProxy: return "ProRes 422 Proxy"
    case .prLt: return "ProRes 422 LT"
    case .prStandard: return "ProRes 422"
    case .prHq: return "ProRes 422 HQ"
    case .pr4444: return "ProRes 4444"
    case .prXq: return "ProRes 4444 XQ"
    }
  }
}

extension VideoCodec {
  
  var qualityTypes: [VideoQuality] {
    switch self {
    case .auto: return [.betterQuality, .balanced, .smallerSize]
    case .h264: return [.betterQuality, .balanced, .smallerSize]
    case .hevc: return [.betterQuality, .balanced, .smallerSize]
    case .vp8: return [.betterQuality, .balanced, .smallerSize]
    case .vp9: return [.betterQuality, .balanced, .smallerSize]
    case .mpeg4: return [.betterQuality, .balanced, .smallerSize]
    case .gif: return [.betterQuality, .balanced, .smallerSize]
    case .prores: return [.prAuto, .prProxy, .prLt, .prStandard, .prHq, .pr4444, .prXq]
    // Will not appear in codec dropdown
    case .mpeg1video: return [.betterQuality, .balanced, .smallerSize]
    case .mpeg2video: return [.betterQuality, .balanced, .smallerSize]
    case .unknown: return [.betterQuality, .balanced, .smallerSize]
    }
  }
  
  var defaultQuality: VideoQuality {
    switch self {
    case .auto: return .balanced
    case .h264: return .balanced
    case .hevc: return .balanced
    case .vp8: return .balanced
    case .vp9: return .balanced
    case .mpeg4: return .balanced
    case .gif: return .balanced
    case .prores: return .prAuto
    // Will not appear in codec dropdown
    case .mpeg1video: return .balanced
    case .mpeg2video: return .balanced
    case .unknown: return .balanced
    }
  }
  
}
