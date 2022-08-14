//
//  VideoFormat.swift
//  Converter
//
//  Created by Justin Bush on 8/13/22.
//

enum VideoFormat {
  case mp4, m4v, mkv, gif
  
  var dropdownTitle: String {
    switch self {
    case .mp4: return "MP4"
    case .m4v: return "M4V"
    case .mkv: return "MKV"
    case .gif: return "GIF"
    }
  }
  
  var rawString: String {
    switch self {
    case .mp4: return "mp4"
    case .m4v: return "m4v"
    case .mkv: return "mkv"
    case .gif: return "gif"
    }
  }
  
}
