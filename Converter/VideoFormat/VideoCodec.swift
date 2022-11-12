//
//  VideoCodec.swift
//  Converter
//
//  Created by Francesco Virga on 2022-08-22.
//

enum VideoCodec: String, CaseIterable {
  case hevc, h264, vp8, vp9, mpeg1video, mpeg2video, mpeg4, prores, gif, unknown
  
  var dropdownTitle: String {
    switch self {
    case .h264: return "H.264"
    case .hevc: return "H.265 (HEVC)"
    case .vp8: return "VP8"
    case .vp9: return "VP9"
    case .mpeg4: return "MPEG-4"
    case .gif: return "GIF"
    // Will not appear in codec dropdown
    case .mpeg1video: return "MPEG-1"
    case .mpeg2video: return "MPEG-2"
    case .prores: return "Apple ProRes"
    case .unknown: return "Unknown"
    }
  }
}

func convertToVideoCodec(inputCodec: String) -> VideoCodec {
  for codec in VideoCodec.allCases {
    if codec.rawValue == inputCodec {
      return codec
    }
  }
  
  Logger.warning("Unknown input video codec \(inputCodec)")
  return .unknown
}


