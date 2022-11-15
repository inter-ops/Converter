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
    case .mp4: return [.auto, .h264, .hevc, .mpeg4]
    case .mkv: return [.auto, .h264, .hevc, .mpeg4, .vp8, .vp9, .prores]
    case .m4v: return [.auto, .h264, .hevc, .mpeg4]
    case .mov: return [.auto, .h264, .hevc, .mpeg4, .prores]
    case .webm: return [.auto, .vp8, .vp9]
    case .avi: return [.auto, .mpeg4]
    case .gif: return [.auto, .gif]
    }
  }
  /// The default output codec to fallback on (old behaviour of `defaultCodec`)
  var fallbackCodec: VideoCodec {
    return self.compatibleCodecs[1]
  }
  
  static func isSupportedAsInput(_ input: String) -> Bool {
    let ext = input.lowercased().pathExtension
    return supportedInputFormats.contains(ext)
  }
  
}
