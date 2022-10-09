//
//  ChannelLayout.swift
//  Converter
//
//  Created by Francesco Virga on 2022-09-02.
//

// There are many more possible channel layouts, but these are the ones we expect.
// See here for more details https://github.com/FFmpeg/FFmpeg/blob/master/libavutil/channel_layout.h#L393
enum ChannelLayout: String, CaseIterable {
  case mono, stereo, unknown
  case fivePointZero = "5.0"
  case fivePointZeroSide = "5.0(side)"
  case fivePointOneSide = "5.1(side)"
  case fivePointOne = "5.1"
  case sevenPointOne = "7.1"
  case sevenPointOneSide = "7.1(side)"
}

func convertToChannelLayout(inputChannelLayout: String) -> ChannelLayout {
  for channelLayout in ChannelLayout.allCases {
    if channelLayout.rawValue == inputChannelLayout {
      return channelLayout
    }
  }
  
  Logger.warning("Unknown input channel layout")
  return .unknown
}
