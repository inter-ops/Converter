//
//  VideoFormat.swift
//  Converter
//
//  Created by Justin Bush on 8/13/22.
//

enum VideoFormat {
  case mp4, m4v, mkv, mov, webm // gif
  
  var dropdownTitle: String {
    switch self {
    case .mp4: return "MP4"
    case .m4v: return "M4V"
    case .mkv: return "MKV"
    case .mov: return "MOV"
//    case .gif: return "GIF"
    case .webm: return "WEBM"
    }
  }
  
  var rawString: String {
    switch self {
    case .mp4: return "mp4"
    case .m4v: return "m4v"
    case .mkv: return "mkv"
    case .mov: return "mov"
//    case .gif: return "gif"
    case .webm: return "webm"
    }
  }
  
}
