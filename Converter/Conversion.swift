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
 - https://gist.github.com/Vestride/278e13915894821e1d6f
 - https://trac.ffmpeg.org/wiki/Encode/VP8
 - https://gist.github.com/jaydenseric/220c785d6289bcfd7366
 - https://wiki.archlinux.org/title/FFmpeg
 */

// TODO: Need to figure out how to package up ffmpeg kit for release
// Needs: --enable-x264 --enable-gpl --enable-libvpx

func isWrapperConversionFormat(filePath: String) -> Bool {
  let ext = getFileExtension(filePath: filePath)
  return ["mp4", "mkv", "mov", "m4v", "avi"].contains(ext)
}

func getFileExtension(filePath: String) -> String {
  return URL(fileURLWithPath: filePath).pathExtension
}

func getFileName(filePath: String) -> String {
  return URL(fileURLWithPath: filePath).lastPathComponent
}

// TODO: Write a testing suite for comparing conversion speed and output qualities of different commands. This will help us fine tune the FFMPEG commands to be ideal for common use cases. For testing video quality output, see here: https://www.reddit.com/r/Twitch/comments/c8ec2h/guide_x264_encoding_is_still_the_best_slow_isnt/

// TODO: This function should build the command in pieces (video codecs, audio codecs, other params)
func getVideoAndAudioConversionCommand(inputFilePath: String, outputFilePath: String) -> String {
  // If the input is HEVC codec and the output format is MP4, lets convert to H264 so that the video is supported by Quicktime
  // Requires libx264
  if getVideoCodec(inputFilePath: inputFilePath) == VideoCodec.hevc && getFileExtension(filePath: outputFilePath) == VideoFormat.mp4.rawValue {
    return "-c:a aac -c:v libx264 -preset veryfast -crf 26"
  }
  
  // Simple copy codec for any conversion between mp4, mkv, mov, m4v
  // TODO: There are likely still cases where this will break a video
  if isWrapperConversionFormat(filePath: inputFilePath) && isWrapperConversionFormat(filePath: outputFilePath) {
    return "-i \"\(inputFilePath)\" -c:v copy -c:a copy"
  }
  
  // mp4, mkv, mov, m4v, avi -> webm
  // - VP9, Constant Quality mode from https://trac.ffmpeg.org/wiki/Encode/VP9. "ffmpeg -i input.mp4 -c:v libvpx-vp9 -crf 30 -b:v 0 output.webm" this seems very slow (near 1 min to convert 17mb video). Requires libvpx-vp9
  // - VP8, vartiable bitrate https://trac.ffmpeg.org/wiki/Encode/VP8. This one is very quick, and smaller file size, best found so far: "ffmpeg -i input.mp4 -c:v libvpx -b:v 1M -c:a libvorbis output.webm" requires libvorbis libvpx
  if isWrapperConversionFormat(filePath: inputFilePath) && getFileExtension(filePath: outputFilePath) == VideoFormat.webm.rawValue {
    // cpu-used 2 speeds up processing by about 2x, but does impact quality a bit. I haven't seen a noticeable difference, but if it becomes problematic, we should set it to 1.
    // See here for more info: https://superuser.com/questions/1586934/vp9-encoding-with-ffmpeg-relation-between-speed-and-deadline-options
    return "-c:v libvpx -b:v 1M -c:a libvorbis -deadline good -cpu-used 2 -crf 26"
  }
  
  if getFileExtension(filePath: inputFilePath) == VideoFormat.webm.rawValue && isWrapperConversionFormat(filePath: outputFilePath) {
    return "-c:a aac -c:v libx264 -preset veryfast -crf 26"
  }
  
  // TODO: Show the user an error if we get here.
  print("Unknown file pair to convert")
  return ""
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
  let videoAndAudioCommand = getVideoAndAudioConversionCommand(inputFilePath: inputFilePath, outputFilePath: outputFilePath)
  let subtitleCommand = getSubtitleConversionCommand(inputFilePath: inputFilePath, outputFilePath: outputFilePath)
  let command = "-i \"\(inputFilePath)\" \(videoAndAudioCommand) \(subtitleCommand) \"\(outputFilePath)\""
  
  // TODO: this breaks if the file already exists, need to first delete output file
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

func getVideoCodec(inputFilePath: String) -> VideoCodec {
  let session = FFprobeKit.execute("-loglevel error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 \"\(inputFilePath)\"")
  let logs = session?.getAllLogsAsString()
  
  let codec = logs!.trimmingCharacters(in: .whitespacesAndNewlines)
  return convertToVideoCodec(inputCodec: codec)
}
