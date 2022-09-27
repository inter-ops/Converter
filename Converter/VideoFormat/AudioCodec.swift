//
//  AudioCodec.swift
//  Converter
//
//  Created by Francesco Virga on 2022-08-31.
//

enum AudioCodec: String, CaseIterable {
  case aac, ac3, eac3, dts, truehd, mp3, flac, alac, pcm_alaw, pcm_mulaw, vorbis, opus, unknown
}

func convertToAudioCodec(inputCodec: String) -> AudioCodec {
  for codec in AudioCodec.allCases {
    if codec.rawValue == inputCodec {
      return codec
    }
  }
  
  // TODO: Report this to us so that we can add a case for it
  print("Unknown input audio codec \(inputCodec)")
  return .unknown
}
