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
    case .webm: return "WEBM"
    case .avi: return "AVI"
    case .gif: return "GIF"
    }
  }
  
  // Order listed here will determine dropdown order. Thus, keep default options at 0 index.
  var compatibleCodecs: [VideoCodec] {
    switch self {
    case .mp4: return [.h264, .hevc, .mpeg4]
    case .mkv: return [.h264, .hevc, .mpeg4, .vp8, .vp9]
    case .m4v: return [.h264, .hevc, .mpeg4]
    case .mov: return [.h264, .hevc, .mpeg4]
    case .webm: return [.vp8, .vp9]
    case .avi: return [.mpeg4]
    case .gif: return [.gif]
    }
  }
  
}
