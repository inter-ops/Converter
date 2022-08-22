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
 - TODO
 - gif
 Some resources:
 - Examples from example ffmpeg-kit app
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

// TODO: Write a testing suite for comparing conversion speed and output qualities of different commands. This will help us fine tune the FFMPEG commands to be ideal for common use cases.

func getConversionCommand(inputFilePath: String, outputFilePath: String) -> String {
  // If the input is HEVC codec and the output format is MP4, lets convert to H264 so that the video is supported by Quicktime
  // Requires libx264
  if getVideoCodec(inputFilePath: inputFilePath) == VideoCodec.hevc && getFileExtension(filePath: outputFilePath) == "mp4" {
    print("CONVERTING TO H264")
    return "-i \"\(inputFilePath)\" -acodec copy -vcodec libx264 \"\(outputFilePath)\""
  }
  
  // Simple copy codec for any conversion between mp4, mkv, mov, m4v
  if isWrapperConversionFormat(filePath: inputFilePath) && isWrapperConversionFormat(filePath: outputFilePath) {
    return "-i \"\(inputFilePath)\" -codec copy \"\(outputFilePath)\""
  }
  
  // mp4, mkv, mov, m4v, avi -> webm
  // - VP9, Constant Quality mode from https://trac.ffmpeg.org/wiki/Encode/VP9. "ffmpeg -i input.mp4 -c:v libvpx-vp9 -crf 30 -b:v 0 output.webm" this seems very slow (near 1 min to convert 17mb video). Requires libvpx-vp9
  // - VP8, vartiable bitrate https://trac.ffmpeg.org/wiki/Encode/VP8. This one is very quick, and smaller file size, best found so far: "ffmpeg -i input.mp4 -c:v libvpx -b:v 1M -c:a libvorbis output.webm" requires libvorbis libvpx
  if isWrapperConversionFormat(filePath: inputFilePath) && getFileExtension(filePath: outputFilePath) == "webm" {
    // cpu-used 2 speeds up processing by about 2x, but does impact quality a bit. I haven't seen a noticeable difference, but if it becomes problematic, we should set it to 1.
    // See here for more info: https://superuser.com/questions/1586934/vp9-encoding-with-ffmpeg-relation-between-speed-and-deadline-options
    return "-i \"\(inputFilePath)\" -c:v libvpx -b:v 1M -c:a libvorbis -deadline good -cpu-used 2 -crf 26 \"\(outputFilePath)\""
  }
  
  if getFileExtension(filePath: inputFilePath) == "webm" && isWrapperConversionFormat(filePath: outputFilePath) {
    return "-i \"\(inputFilePath)\" -crf 26 \"\(outputFilePath)\""
  }
  
  // TODO: Show the user an error if we get here.
  return ""
}

func runFfmpegConversion(inputFilePath: String, outputFilePath: String, onDone: @escaping (_: FFmpegSession?) -> Void) -> FFmpegSession {
  let command = getConversionCommand(inputFilePath: inputFilePath, outputFilePath: outputFilePath)
  
  // TODO: this breaks if the file already exists, need to first delete output file
  let session = FFmpegKit.executeAsync(command, withCompleteCallback: onDone)
  
  return session!
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
