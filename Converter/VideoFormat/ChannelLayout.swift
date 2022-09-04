//
//  ChannelLayout.swift
//  Converter
//
//  Created by Francesco Virga on 2022-09-02.
//

enum ChannelLayout: String, CaseIterable {
  case stereo, 5.1(side), unknown
}

func convertToChannelLayout(inputChannelLayout: String) -> ChannelLayout {
  for channelLayout in ChannelLayout.allCases {
    if channelLayout.rawValue == inputChannelLayout {
      return channelLayout
    }
  }
  
  print("Unknown input channel layout")
  return .unknown
}
