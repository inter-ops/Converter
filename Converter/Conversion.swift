//
//  Conversion.swift
//  Converter
//
//  Created by Francesco Virga on 2022-08-15.
//

import Foundation
import ffmpegkit

/**
 Conversion commands:
 - Supported: mp4, mkv, mov, m4v, webm, avi
 Some resources:
 - Examples from example ffmpeg-kit app
 - https://en.wikipedia.org/wiki/Comparison_of_video_container_formats#Subtitle_formats_support
 - https://trac.ffmpeg.org/wiki/Encode/HighQualityAudio
 - https://brandur.org/fragments/ffmpeg-h265
 - https://trac.ffmpeg.org/wiki/AudioChannelManipulation
 - https://gist.github.com/Vestride/278e13915894821e1d6f
 - https://trac.ffmpeg.org/wiki/Encode/VP8
 - https://gist.github.com/jaydenseric/220c785d6289bcfd7366
 - https://wiki.archlinux.org/title/FFmpeg
 */

// TODO: Need to figure out how to package up ffmpeg kit for release
// Needs: --enable-x264 --enable-gpl --enable-libvpx

func getFileExtension(filePath: String) -> String {
  return URL(fileURLWithPath: filePath).pathExtension
}

func getFileName(filePath: String) -> String {
  return URL(fileURLWithPath: filePath).lastPathComponent
}

// TODO: Write a testing suite for comparing conversion speed and output qualities of different commands. This will help us fine tune the FFMPEG commands to be ideal for common use cases. For testing video quality output, see here: https://www.reddit.com/r/Twitch/comments/c8ec2h/guide_x264_encoding_is_still_the_best_slow_isnt/

func getVideoConversionCommand(inputFilePath: String, outputFilePath: String) -> String {
  let inputVideoCodec = getVideoCodec(inputFilePath: inputFilePath)
  let outputFileType = getFileExtension(filePath: outputFilePath)
  let inputFileType = getFileExtension(filePath: inputFilePath)
  
  switch outputFileType {
  case VideoFormat.webm.rawValue:
    // - VP9, Constant Quality mode from https://trac.ffmpeg.org/wiki/Encode/VP9. "ffmpeg -i input.mp4 -c:v libvpx-vp9 -crf 30 -b:v 0 output.webm" this seems very slow (near 1 min to convert 17mb video). Requires libvpx-vp9
    // - VP8, vartiable bitrate https://trac.ffmpeg.org/wiki/Encode/VP8. This one is very quick, and smaller file size, best found so far: "ffmpeg -i input.mp4 -c:v libvpx -b:v 1M -c:a libvorbis output.webm" requires libvorbis libvpx
    // cpu-used 2 speeds up processing by about 2x, but does impact quality a bit. I haven't seen a noticeable difference, but if it becomes problematic, we should set it to 1.
    // See here for more info: https://superuser.com/questions/1586934/vp9-encoding-with-ffmpeg-relation-between-speed-and-deadline-options
    return "-c:v libvpx -b:v 1M -deadline good -cpu-used 2 -crf 26"
    
  case VideoFormat.mp4.rawValue, VideoFormat.mov.rawValue, VideoFormat.m4v.rawValue, VideoFormat.mkv.rawValue, VideoFormat.avi.rawValue:
    // If input file is WEBM, we re-encode to H264
    if inputFileType == VideoFormat.webm.rawValue {
      return "-c:v libx264 -preset veryfast -crf 26"
    }
    
    // If input file is HEVC, we re-encode to H264 to ensure QuickTime support
    if inputVideoCodec == VideoCodec.hevc {
      return "-c:v libx264 -preset veryfast -crf 26"
    }
    
    // For everything else, we copy video codec since it should be supported.
    // TODO: There could still be some cases where this is not true, need to do more testing.
    return "-c:v copy"
    
  default:
    // For unknown cases, we re-encode to H264
    return "-c:v libx264 -preset veryfast -crf 26"
  }
}

/// This function checks the number of audio channels available in the input audio and determines how many output channels should be used to ensure a successful conversion and QuickTime support.
/// Reference: https://trac.ffmpeg.org/wiki/AudioChannelManipulation, https://brandur.org/fragments/ffmpeg-h265
func getAacConversionCommand(inputFilePath: String) -> String {
  let numberOfAudioChannels = getNumberOfAudioChannels(inputFilePath: inputFilePath)

  if numberOfAudioChannels >= 6 {
    // If we have 6 or more channels, we can force a 5.1 channel layout
    return "-filter_complex \"channelmap=channel_layout=5.1\" -c:a aac"
  }
  else {
    // For any other number of channels, FFMPEG can handle converting to stereo. If we have a mono audio input, FFMPEG will simply copy the mono audio to both channels.
    return "-c:a aac -ac 2"
  }
}

// TODO: If channel_layout is stereo (or anything else with not enough audio channels for 5.1) use "-c:a aac -ac 2" instead of channelmap. Will need to look at possible values for channel_layout and whether its enough or we need number of channels too
// References:
// - https://en.wikipedia.org/wiki/Comparison_of_video_container_formats#Audio_coding_formats_support
// - https://en.wikipedia.org/wiki/QuickTime
func getAudioConversionCommand(inputFilePath: String, outputFilePath: String) -> String {
  let inputAudioCodec = getAudioCodec(inputFilePath: inputFilePath)
  let outputFileType = getFileExtension(filePath: outputFilePath)
  
  switch outputFileType {
  case VideoFormat.mp4.rawValue, VideoFormat.mov.rawValue, VideoFormat.m4v.rawValue:
    // Codecs supported by MP4 and Quicktime
    if inputAudioCodec == AudioCodec.aac || inputAudioCodec == AudioCodec.eac3 || inputAudioCodec == AudioCodec.ac3 {
      return "-c:a copy"
    }
    else {
      // See https://brandur.org/fragments/ffmpeg-h265 for details
      return getAacConversionCommand(inputFilePath: inputFilePath)
    }
  case VideoFormat.mkv.rawValue:
    // MKV supports all audio codecs we support
    return "-c:a copy"
  case VideoFormat.avi.rawValue:
    // Codecs supported by AVI
    // TODO: We currently can't differentiate between DTS and DTS-HD, so we re-encode for either. In the future, we only need to re-encode for DTS-HD here.
    if inputAudioCodec == AudioCodec.aac || inputAudioCodec == AudioCodec.mp3 || inputAudioCodec == AudioCodec.ac3 {
      return "-c:a copy"
    }
    else {
      return getAacConversionCommand(inputFilePath: inputFilePath)
    }
  case VideoFormat.webm.rawValue:
    return "-c:a libvorbis"
  default:
    print("Unknown output file type when selecting audio codec")
    return getAacConversionCommand(inputFilePath: inputFilePath)
  }
}

/// Get the subtitle conversion portion of the FFMPEG command.
/// https://en.wikibooks.org/wiki/FFMPEG_An_Intermediate_Guide/subtitle_options
func getSubtitleConversionCommand(inputFilePath: String, outputFilePath: String) -> String {
  let outputFileType = getFileExtension(filePath: outputFilePath)
  
  switch outputFileType {
    // TODO: This is resulting in two output subtitle streams, the first one is the correct one, the second one shows "Chapter 1" and nothing else
  case VideoFormat.mp4.rawValue, VideoFormat.m4v.rawValue, VideoFormat.mov.rawValue:
    return "-c:s mov_text"
  case VideoFormat.mkv.rawValue:
    return "-c:s ass" // We could also use srt, which is a less advanced format but may be better supported
  case VideoFormat.webm.rawValue:
    return "-c:s webvtt"
  case VideoFormat.avi.rawValue:
    return "" // AVI does not support soft-subs.
  default:
    print("Unknown output file type when selecting subtitle codec")
    return ""
  }
  
}

func runFfmpegConversion(inputFilePath: String, outputFilePath: String, onDone: @escaping (_: FFmpegSession?) -> Void) -> FFmpegSession {
  let videoCommand = getVideoConversionCommand(inputFilePath: inputFilePath, outputFilePath: outputFilePath)
  let audioCommand = getAudioConversionCommand(inputFilePath: inputFilePath, outputFilePath: outputFilePath)

  let subtitleCommand = getSubtitleConversionCommand(inputFilePath: inputFilePath, outputFilePath: outputFilePath)
  let command = "-hide_banner -loglevel error -y -i \"\(inputFilePath)\" \(audioCommand) \(videoCommand) \(subtitleCommand) \"\(outputFilePath)\""
  
  if debug {
    print("Running FFMPEG command: \(command)")
  }
  
  let session = FFmpegKit.executeAsync(command, withCompleteCallback: onDone)
  
  return session!
}

func getNumberOfFrames(inputFilePath: String) -> Double {
  let session = FFprobeKit.execute("-loglevel error -select_streams v:0 -count_packets -show_entries stream=nb_read_packets -of default=nokey=1:noprint_wrappers=1 \"\(inputFilePath)\"")
  let logs = session?.getAllLogsAsString()
  let numberOfFrames = Double(logs!.trimmingCharacters(in: .whitespacesAndNewlines))!
  return numberOfFrames
}

func getVideoDuration(inputFilePath: String) -> Double {
  let session = FFprobeKit.execute("-loglevel error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 \"\(inputFilePath)\"")
  let logs = session?.getAllLogsAsString()
  
  let duration = Double(logs!.trimmingCharacters(in: .whitespacesAndNewlines))!
  return duration
}

// TODO: This operation is synchronous. If we notice this slows down the app, we can do is async immediately after a user selects an input file
func getVideoCodec(inputFilePath: String) -> VideoCodec {
  let session = FFprobeKit.execute("-loglevel error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 \"\(inputFilePath)\"")
  let logs = session?.getAllLogsAsString()
  
  let codec = logs!.trimmingCharacters(in: .whitespacesAndNewlines)
  return convertToVideoCodec(inputCodec: codec)
}

// TODO: This operation is synchronous. If we notice this slows down the app, we can do is async immediately after a user selects an input file
// Could also get all these through a single ffprobe call that gets all stream info, then parse it all on the swift side. This would already be a big improvement.
func getAudioCodec(inputFilePath: String) -> AudioCodec {
  let session = FFprobeKit.execute("-loglevel error -select_streams a:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 \"\(inputFilePath)\"")
  let logs = session?.getAllLogsAsString()
  
  let codec = logs!.trimmingCharacters(in: .whitespacesAndNewlines)
  return convertToAudioCodec(inputCodec: codec)
}

func getChannelLayout(inputFilePath: String) -> ChannelLayout {
  let session = FFprobeKit.execute("-loglevel error -select_streams a:0 -show_entries stream=channel_layout -of default=noprint_wrappers=1:nokey=1 \"\(inputFilePath)\"")
  let logs = session?.getAllLogsAsString()
  
  let channelLayout = logs!.trimmingCharacters(in: .whitespacesAndNewlines)
  return convertToChannelLayout(inputChannelLayout: channelLayout)
}

func getNumberOfAudioChannels(inputFilePath: String) -> Int {
  let session = FFprobeKit.execute("-loglevel error -select_streams a:0 -show_entries stream=channels -of default=noprint_wrappers=1:nokey=1 \"\(inputFilePath)\"")
  let logs = session?.getAllLogsAsString()
  
  let channels = Int(logs!.trimmingCharacters(in: .whitespacesAndNewlines))!
  return channels
}

// TODO: This will be used to differentiate types of DTS (DTS, DTS-HD), types of AAC (HE-AAC, AAC-LC, etc.)
// Some resource:
// - https://stackoverflow.com/questions/61365587/what-does-profile-means-in-an-aac-encoded-audio
// - https://trac.ffmpeg.org/wiki/Encode/HighQualityAudio
// - https://trac.ffmpeg.org/wiki/Encode/AAC
//func getAudioCodecProfile(inputFilePath: String) -> Void {
//  let session = FFprobeKit.execute("-loglevel error -select_streams a:0 -show_entries stream=profile  -of default=noprint_wrappers=1:nokey=1 \"\(inputFilePath)\"")
//  let logs = session?.getAllLogsAsString()
//
//
//  let profile = logs!.trimmingCharacters(in: .whitespacesAndNewlines)
//  print("PROFILE \(profile)")
//}


func isFileValid(inputFilePath: String) -> Bool {
  let session = FFprobeKit.execute("-loglevel error \"\(inputFilePath)\"")
  let logs = session?.getAllLogsAsString()
  
  let error = logs!.trimmingCharacters(in: .whitespacesAndNewlines)
  
  return error.count == 0
}
