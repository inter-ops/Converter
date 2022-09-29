//
//  VideoFormat.swift
//  Converter
//
//  Created by Justin Bush on 8/13/22.
//

let supportedInputFormats = ["mp4", "mkv", "m4v", "mov", "webm", "avi", "gif"]

// TODO: Naming is confusing between Format and VideoFormat, should clean this file up.
// We should use a separate list for allowed input formats and allowed output formats

struct Format {
  static func isSupportedAsInput(_ input: String) -> Bool {
    let ext = input.lowercased().pathExtension
    return supportedInputFormats.contains(ext)
  }
}

enum VideoFormat: String, CaseIterable {
  case mp4, mkv, m4v, mov, webm, avi, gif
  
  var dropdownTitle: String {
    switch self {
    case .mp4: return "MP4"
    case .mkv: return "MKV"
    case .m4v: return "M4V"
    case .mov: return "MOV"
    case .avi: return "AVI"
    case .webm: return "WEBM"
    case .gif: return "GIF"
    }
  }
  
}
