//
//  SubtitleCodec.swift
//  Converter
//
//  Created by Francesco Virga on 2022-09-17.
//

enum SubtitleCodec: String, CaseIterable {
  case ass, srt, ssa, mov_text, stl, subrip, webvtt, text, xsub, unknown
}

func convertToSubtitleCodec(inputCodec: String) -> SubtitleCodec {
  for codec in SubtitleCodec.allCases {
    if codec.rawValue == inputCodec {
      return codec
    }
  }
  
  // TODO: Report this to us so that we can add a case for it
  print("Unknown input subtitle codec \(inputCodec)")
  return .unknown
}
