//
//  VideoCodec.swift
//  Converter
//
//  Created by Francesco Virga on 2022-08-22.
//

enum VideoCodec: String, CaseIterable {
  case hevc, h264, vp8, vp9, mpeg1video, mpeg2video, mpeg4, prores, unknown
}

func convertToVideoCodec(inputCodec: String) -> VideoCodec {
  for codec in VideoCodec.allCases {
    if codec.rawValue == inputCodec {
      return codec
    }
  }
  
  // TODO: Report this to us so that we can add a case for it
  print("Unknown input video codec \(inputCodec)")
  return .unknown
}
