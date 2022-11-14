//
//  AudioCodec.swift
//  Converter
//
//  Created by Francesco Virga on 2022-08-31.
//

enum AudioCodec: String, CaseIterable {
  case aac, ac3, eac3, dts, truehd, mp3, flac, alac, pcm_alaw, pcm_mulaw, pcm_s16le, pcm_s24le, vorbis, opus, unknown
}

func convertToAudioCodec(inputCodec: String) -> AudioCodec {
  for codec in AudioCodec.allCases {
    if codec.rawValue == inputCodec {
      return codec
    }
  }
  
  Logger.warning("Unknown input audio codec \(inputCodec)")
  return .unknown
}
