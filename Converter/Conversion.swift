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
- Supported: mp4, mkv, mov, m4v, webm
- TODO
     - gif, avi, hevc
 Some resources:
 - Examples from example ffmpeg-kit app
 - https://gist.github.com/Vestride/278e13915894821e1d6f
 - https://trac.ffmpeg.org/wiki/Encode/VP8
 - https://gist.github.com/jaydenseric/220c785d6289bcfd7366
 - https://wiki.archlinux.org/title/FFmpeg
 */

// TODO: Need to figure out how to package up ffmpeg kit for release

func isMFormat(filePath: String) -> Bool {
    let ext = getFileExtension(filePath: filePath)
    return ["mp4", "mkv", "mov", "m4v"].contains(ext)
}

func getFileExtension(filePath: String) -> String {
    return URL(fileURLWithPath: filePath).pathExtension
}

func getFileName(filePath: String) -> String {
    return URL(fileURLWithPath: filePath).lastPathComponent
}

func getConversionCommand(inputFilePath: String, outputFilePath: String) -> String {
    // Simple copy codec for any conversion between mp4, mkv, mov, m4v
    if isMFormat(filePath: inputFilePath) && isMFormat(filePath: outputFilePath) {
        return "-i \"\(inputFilePath)\" -codec copy \"\(outputFilePath)\""
    }
    
    // mp4, mkv, mov, m4v -> webm
    // - VP9, Constant Quality mode from https://trac.ffmpeg.org/wiki/Encode/VP9. "ffmpeg -i input.mp4 -c:v libvpx-vp9 -crf 30 -b:v 0 output.webm" this seems very slow (near 1 min to convert 17mb video). Requires libvpx-vp9
    // - VP8, vartiable bitrate https://trac.ffmpeg.org/wiki/Encode/VP8. This one is very quick, and smaller file size, best found so far: "ffmpeg -i input.mp4 -c:v libvpx -b:v 1M -c:a libvorbis output.webm" requires libvorbis libvpx
    if isMFormat(filePath: inputFilePath) && getFileExtension(filePath: outputFilePath) == "webm" {
        return "-i \"\(inputFilePath)\" -c:v libvpx -b:v 1M -c:a libvorbis \"\(outputFilePath)\""
    }
    
    if getFileExtension(filePath: inputFilePath) == "webm" && isMFormat(filePath: outputFilePath) {
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
    let session = FFprobeKit.execute("-v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 \"\(inputFilePath)\"")
    let logs = session?.getAllLogsAsString()
    
    let duration = Double(logs!.trimmingCharacters(in: .whitespacesAndNewlines))!
    return duration
}
