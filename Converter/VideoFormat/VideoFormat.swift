//
//  VideoFormat.swift
//  Converter
//
//  Created by Justin Bush on 8/13/22.
//

let supportedFormats = ["mp4", "mkv", "m4v", "mov", "webm", "avi"]

struct Format {
  static let supported = supportedFormats
  
  /// Returns true if lowercased filetype is supported
  static func isSupported(_ input: String) -> Bool {
    let ext = input.lowercased().pathExtension
    return supported.contains(ext)
  }
}

enum VideoFormat: String, CaseIterable {
  case mp4, mkv, m4v, mov, webm, avi // gif
  
  var dropdownTitle: String {
    switch self {
    case .mp4: return "MP4"
    case .mkv: return "MKV"
    case .m4v: return "M4V"
    case .mov: return "MOV"
    case .avi: return "AVI"
//    case .gif: return "GIF"
    case .webm: return "WEBM"
    }
  }
  
}
