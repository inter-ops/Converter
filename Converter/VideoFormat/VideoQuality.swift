//
//  VideoQuality.swift
//  Converter
//
//  Created by Justin Bush on 11/12/22.
//

enum VideoQuality: String, CaseIterable {
  case betterQuality, balanced, smallerSize
  
  case prAuto, prProxy, prLt, prStandard, prHq, pr4444, pr4444Xq
  
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
    case .pr4444Xq: return "ProRes 4444 XQ"
    }
  }
  
  // Profile used in FFMPEG commands
  var profile: String {
    switch self {
      // ProRes
    case .prAuto: return "auto"
    case .prProxy: return "proxy"
    case .prLt: return "lt"
    case .prStandard: return "standard"
    case .prHq: return "hq"
    case .pr4444: return "4444"
    case .pr4444Xq: return "xq"
      // Unused
    case .betterQuality, .balanced, .smallerSize:
      Logger.error("Profile fetched for invalid quality")
      return "N/A"
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
    case .prores: return [.prAuto, .prProxy, .prLt, .prStandard, .prHq, .pr4444, .pr4444Xq]
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
