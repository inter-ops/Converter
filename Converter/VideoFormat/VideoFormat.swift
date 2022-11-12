//
//  VideoFormat.swift
//  Converter
//
//  Created by Justin Bush on 8/13/22.
//

let supportedInputFormats = ["mp4", "mkv", "m4v", "mov", "webm", "avi", "gif"]

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
  
  /// Returns a list of compatible `[VideoCodec]` based on the VideoFormat
  var compatibleCodecs: [VideoCodec] {
    switch self {
    case .mp4: return [.h264, .hevc, .mpeg4]
    case .mkv: return [.h264, .hevc, .mpeg4, .vp8, .vp9, .prores]
    case .m4v: return [.h264, .hevc, .mpeg4]
    case .mov: return [.h264, .hevc, .mpeg4, .prores]
    case .webm: return [.vp8, .vp9]
    case .avi: return [.mpeg4]
    case .gif: return [.gif]
    }
  }
  /// Returns the default `VideoCodec` for the given `VideoFormat`
  var defaultCodec: VideoCodec {
    return self.compatibleCodecs[0]
  }
  
  static func isSupportedAsInput(_ input: String) -> Bool {
    let ext = input.lowercased().pathExtension
    return supportedInputFormats.contains(ext)
  }
  
}
