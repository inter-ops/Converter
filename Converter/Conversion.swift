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
 - Filter docs: https://ffmpeg.org/ffmpeg.html#Simple-filtergraphs https://ffmpeg.org/ffmpeg-filters.html#Filtering-Introduction
 */

/// Building FFMPEG

/// Current packages are downloaded directly from https://github.com/arthenica/ffmpeg-kit/releases/tag/v5.1 "ffmpeg-kit-full-5.1-macos-xcframework.zip" since building was failing for an unknown reason.
/// If we want to build manually, use: "--xcframework  --enable-macos-zlib  --enable-macos-audiotoolbox --enable-macos-avfoundation  --enable-macos-bzip2  --enable-macos-videotoolbox --enable-macos-libiconv  --enable-macos-coreimage --enable-macos-opencl  --enable-macos-opengl --enable-chromaprint --enable-fontconfig --enable-freetype --enable-fribidi --enable-gmp   --enable-kvazaar  --enable-lame  --enable-libaom  --enable-libass --enable-libilbc  --enable-libtheora  --enable-libvorbis  --enable-libvpx  --enable-libxml2  --enable-opencore-amr  --enable-openh264  --enable-openssl  --enable-opus  --enable-sdl --enable-shine  --enable-snappy  --enable-soxr --enable-speex  --enable-srt --enable-twolame --enable-vo-amrwbenc --enable-zimg". This is every non-GPL library other than webp (libgif failed building), tesseract (libgif failed building), gnutls (gnutls failed building), dav1d (failed building), and every GPL library other than rubberband & libvidstab (unnecessary).
/// NOTE: Bare minimum package requirements are "--xcframework --enable-libvpx --enable-libvorbis", but we ran into "unknown encoder" errors with certain input videos.
/// NOTE: If we want to go back to use x264, x265 and xvid, we need to add "--enable-gpl  --enable-x264 --enable-xvidcore"



// TODO: Convert this to a VideoFormat type so that we don't need to use .rawValue everywhere
func getFileExtension(filePath: String) -> String {
  return URL(fileURLWithPath: filePath).pathExtension
}

func getFileName(filePath: String) -> String {
  return URL(fileURLWithPath: filePath).lastPathComponent
}

// TODO: Write a testing suite for comparing conversion speed and output qualities of different commands. This will help us fine tune the FFMPEG commands to be ideal for common use cases. For testing video quality output, see here:
// - https://www.reddit.com/r/Twitch/comments/c8ec2h/guide_x264_encoding_is_still_the_best_slow_isnt/
// - https://netflixtechblog.com/vmaf-the-journey-continues-44b51ee9ed12


// TODO: Create a readme for this documentation after refactor is done on this file.

// TODO: See if we can use video stream bitrate instead of entire file bitrate, or what the difference even is.

func getVideoCommandForH264(bitRate: Int) -> String {
  return "-c:v h264_videotoolbox -b:v \(bitRate) -pix_fmt yuv420p -allow_sw 1"
}

/// Get the video portion of the ffmpeg command.
/// For x264, we always use 8-bit colour (pixfmt yuv420p) to ensure maximum support. See "Encoding for dumb players" here for more info: https://trac.ffmpeg.org/wiki/Encode/H.264
/// We use a crf of 20. The default is 23, and 17-18 is considered visually lossless. See "Choose a CRF value" here for more info: https://trac.ffmpeg.org/wiki/Encode/H.264
func getVideoConversionCommand(inputVideo: Video, outputFilePath: String) -> String {
  let inputVideoCodec = inputVideo.videoStreams[0].codec
  let inputVideoCodecTag = inputVideo.videoStreams[0].codecTagString
  let inputBitRate = inputVideo.bitRate
  let outputFileType = getFileExtension(filePath: outputFilePath)
  let inputFileType = getFileExtension(filePath: inputVideo.filePath)
  
  switch outputFileType {
  case VideoFormat.webm.rawValue:
    // - VP9, Constant Quality mode from https://trac.ffmpeg.org/wiki/Encode/VP9. "ffmpeg -i input.mp4 -c:v libvpx-vp9 -crf 30 -b:v 0 output.webm" this seems very slow (near 1 min to convert 17mb video). Requires libvpx-vp9
    // - VP8, vartiable bitrate https://trac.ffmpeg.org/wiki/Encode/VP8. This one is very quick, and smaller file size, best found so far: "ffmpeg -i input.mp4 -c:v libvpx -b:v 1M -c:a libvorbis output.webm" requires libvorbis libvpx
    // cpu-used 2 speeds up processing by about 2x, but does impact quality a bit. I haven't seen a noticeable difference, but if it becomes problematic, we should set it to 1.
    // See here for more info:
    // - https://superuser.com/questions/1586934/vp9-encoding-with-ffmpeg-relation-between-speed-and-deadline-options
    // - https://superuser.com/questions/556463/converting-video-to-webm-with-ffmpeg-avconv
    // - https://superuser.com/a/1280369
    
    let outputBitrate = inputVideoCodec == VideoCodec.hevc ? inputBitRate * 2 : inputBitRate
    if inputFileType == VideoFormat.gif.rawValue || inputVideoCodec == VideoCodec.gif {
      // This command is identical to the one below, but uses 8-bit color, which is required for gif inputs
      return "-c:v libvpx -b:v \(outputBitrate) -deadline good -cpu-used 2 -crf 5 -pix_fmt yuv420p"
    }
    else {
      return "-c:v libvpx -b:v \(outputBitrate) -deadline good -cpu-used 2 -crf 5"
    }
  
  case VideoFormat.mp4.rawValue, VideoFormat.mov.rawValue, VideoFormat.m4v.rawValue, VideoFormat.mkv.rawValue:
    // If input file is WEBM, we re-encode to H264
    if inputFileType == VideoFormat.webm.rawValue {
      return getVideoCommandForH264(bitRate: inputVideo.bitRate)
    }
    
    // If input file is GIF, we re-encode to H264 and ensure the dimensions are divisible by 2. See https://unix.stackexchange.com/a/294892
    if inputFileType == VideoFormat.gif.rawValue || inputVideoCodec == VideoCodec.gif {
      // Note that this command works for most use cases, but odd cases (such as really low FPS & frame number gifs, eg https://github.com/cyburgee/ffmpeg-guide/blob/master/321.gif) will trip up VLC and stop too early.
      // If we are having issues with this, review the method outlined here: https://github.com/cyburgee/ffmpeg-guide I already tried integrating this but found that using fps=source_fps wouldn't fix the issue, the FPS had to be increased. I don't want to screw with FPS too much for now unless we see this become a problem in the wild.
      return "\(getVideoCommandForH264(bitRate: inputVideo.bitRate)) -vf \"scale=trunc(iw/2)*2:trunc(ih/2)*2\""
    }
    
    // If input codec is ProRes or unknown, we re-encode to H264
    if inputVideoCodec == VideoCodec.prores || inputVideoCodec == VideoCodec.unknown {
      return getVideoCommandForH264(bitRate: inputVideo.bitRate)
    }
    
    // If input codec is HEVC, we re-encode to H264 and 8-bit colour to ensure QuickTime support, and need to double bitrate
    // https://superuser.com/questions/1380946/how-do-i-convert-10-bit-h-265-hevc-videos-to-h-264-without-quality-loss
    if inputVideoCodec == VideoCodec.hevc {
      // We need to multiply bitrate by 2 to maintain similar quality when going from HEVC -> H264
      return getVideoCommandForH264(bitRate: inputVideo.bitRate * 2)
    }
    
    // MOV does not support xvid, so we need to re-encode to H264
    if inputVideoCodecTag == "xvid" && outputFileType == VideoFormat.mov.rawValue {
      return getVideoCommandForH264(bitRate: inputVideo.bitRate)
    }
    
    // For everything else, we copy video codec since it should be supported.
    // TODO: There could still be some cases where this is not true, need to do more testing, or selectively chose when we can support copying based on input codecs.
    
    // TODO: Uncomment line below BEFORE MERGING!!!!!!!! This allows us to test conversions which would otherwise remux
//    return "-c:v copy"
    return getVideoCommandForH264(bitRate: inputVideo.bitRate)
    
  case VideoFormat.avi.rawValue:
    if inputVideoCodec == VideoCodec.mpeg4 {
      return "-c:v copy"
    }
    
    // AVI conversion docs: https://trac.ffmpeg.org/wiki/Encode/MPEG-4
    
    // NOTE: In the past we used "-c:v libxvid -qscale:v 5" but libxvid is a GPL library so we switched to the native encoder.
    // If we want to swtich back to libxvid, we still need to use the native encoder for GIF inputs since libxvid throws unknown errors.
    
    // If this command ever causes problems for GIF, try https://stackoverflow.com/questions/3212821/animated-gif-to-avi-on-linux https://www.linuxquestions.org/questions/linux-software-2/converting-animated-gif-to-avi-ffmpeg-549839/#edit2729743
    
    return "-c:v mpeg4 -vtag xvid -qscale:v 5 -pix_fmt yuv420p"
  case VideoFormat.gif.rawValue:
    // Gif conversion resources:
    // https://superuser.com/a/556031
    // http://blog.pkh.me/p/21-high-quality-gif-with-ffmpeg.html
    // https://engineering.giphy.com/how-to-make-gifs-with-ffmpeg/
    // Frame rate: https://trac.ffmpeg.org/wiki/ChangingFrameRate
    
    // TODO: There is still a slight stutter with certain output videos. This seems to improve with higher FPS but not resolve completely.
    // TODO: There is a slight delay with progress as the palette file needs to be created. Look into ways to estimate this, or may want to add an arbitrary delay based on file size or format. This delay is especially long for x265. Didnt find much online, so should ask stackoverflow. At the minimum, we should make it more clear that we are estimating conversion time during this period (since we show no progress bar).
    // NOTE: If color is an issue, use "palettegen=stats_mode=single" and "paletteuse=new=1"
    return "-vf \"fps=15,scale=0:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse\" -loop 0"
  default:
    // For unknown cases, we re-encode to H264
    Logger.error("Unknown output file type when selecting video codec")
    return getVideoCommandForH264(bitRate: inputVideo.bitRate)
  }
}

/// This function checks the number of audio channels available in the input audio and determines how many output channels should be used to ensure a successful conversion and QuickTime support.
/// Reference: https://trac.ffmpeg.org/wiki/AudioChannelManipulation, https://brandur.org/fragments/ffmpeg-h265
func getAacConversionCommand(inputVideo: Video) -> String {
  let numberOfAudioChannels = inputVideo.audioStreams[0].channels

  if numberOfAudioChannels >= 6 {
    // If we have 6 or more channels, we can force a 5.1 channel layout
    return "-filter_complex \"channelmap=channel_layout=5.1\" -c:a aac"
  }
  else {
    // For any other number of channels, FFMPEG can handle converting to stereo. If we have a mono audio input, FFMPEG will simply copy the mono audio to both channels.
    return "-c:a aac -ac 2"
  }
}

// References:
// - https://en.wikipedia.org/wiki/Comparison_of_video_container_formats#Audio_coding_formats_support
// - https://en.wikipedia.org/wiki/QuickTime
func getAudioConversionCommand(inputVideo: Video, outputFilePath: String) -> String {
  let outputFileType = getFileExtension(filePath: outputFilePath)
  
  // If we don't have any audio streams, or we are converting to GIF, we don't need an audio conversion command
  if inputVideo.audioStreams.isEmpty || outputFileType == VideoFormat.gif.rawValue {
    return ""
  }
  
  let inputAudioCodec = inputVideo.audioStreams[0].codec

  switch outputFileType {
  case VideoFormat.m4v.rawValue:
    // Codecs supported by M4V and Quicktime. This should be identical to the logic for MP4 and MOV, with the exception of avoiding copying EAC3 codec.
    // Technically M4V should support EAC3, but FFMPEG throws an error when this is attempted.
    // See this ticket for more info https://trac.ffmpeg.org/ticket/4844
    if inputAudioCodec == AudioCodec.aac || inputAudioCodec == AudioCodec.ac3 {
      return "-c:a copy"
    }
    else {
      // See https://brandur.org/fragments/ffmpeg-h265 for details
      return getAacConversionCommand(inputVideo: inputVideo)
    }
  case VideoFormat.mp4.rawValue, VideoFormat.mov.rawValue:
    // Codecs supported by MP4 and Quicktime
    if inputAudioCodec == AudioCodec.aac || inputAudioCodec == AudioCodec.eac3 || inputAudioCodec == AudioCodec.ac3 {
      return "-c:a copy"
    }
    else {
      // See https://brandur.org/fragments/ffmpeg-h265 for details
      return getAacConversionCommand(inputVideo: inputVideo)
    }
  case VideoFormat.mkv.rawValue:
    if inputAudioCodec == AudioCodec.unknown {
      return getAacConversionCommand(inputVideo: inputVideo)
    }
    else {
      // MKV supports all audio codecs we support
      return "-c:a copy"
    }
  case VideoFormat.avi.rawValue:
    // Codecs supported by AVI
    // TODO: We currently can't differentiate between DTS and DTS-HD, so we re-encode for either. In the future, we only need to re-encode for DTS-HD here.
    if inputAudioCodec == AudioCodec.aac || inputAudioCodec == AudioCodec.mp3 || inputAudioCodec == AudioCodec.ac3 {
      return "-c:a copy"
    }
    else {
      return getAacConversionCommand(inputVideo: inputVideo)
    }
  case VideoFormat.webm.rawValue:
    return "-c:a libvorbis"
  default:
    Logger.error("Unknown output file type when selecting audio codec")
    return getAacConversionCommand(inputVideo: inputVideo)
  }
}

/// Get the subtitle conversion portion of the FFMPEG command.
/// https://en.wikibooks.org/wiki/FFMPEG_An_Intermediate_Guide/subtitle_options
func getSubtitleConversionCommand(inputVideo: Video, outputFilePath: String) -> String {
  let outputFileType = getFileExtension(filePath: outputFilePath)
  
  // If we don't have any audio streams, or we are converting to GIF, we don't need a subtitle conversion command
  if inputVideo.subtitleStreams.isEmpty || outputFileType == VideoFormat.gif.rawValue {
    return ""
  }
  
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
    Logger.error("Unknown output file type when selecting subtitle codec")
    return ""
  }
  
}

// TODO: FFMPEG command could be built using a builder class (eg withVideoCodec("x264").withCrf(20)), would cleanup the getVideoConversionCommand, getAudioConversionCommand and getSubtitleConversionCommand functions
func getFfmpegCommand(inputVideo: Video, outputFilePath: String) -> String {
  let videoCommand = getVideoConversionCommand(inputVideo: inputVideo, outputFilePath: outputFilePath)
  let audioCommand = getAudioConversionCommand(inputVideo: inputVideo, outputFilePath: outputFilePath)
  
  let subtitleCommand = getSubtitleConversionCommand(inputVideo: inputVideo, outputFilePath: outputFilePath)
  let command = "-hide_banner -y -i \"\(inputVideo.filePath)\" \(audioCommand) \(videoCommand) \(subtitleCommand) \"\(outputFilePath)\""
  
  return command
}

func runFfmpegCommand(command: String, onDone: @escaping (_: FFmpegSession?) -> Void) -> FFmpegSession {
  Logger.info("Running FFMPEG command: \(command)")
  
  let session = FFmpegKit.executeAsync(command, withCompleteCallback: onDone)
  
  return session!
}

func getAllVideoProperties(inputFilePath: String) -> Video {
  let session = FFprobeKit.execute("-loglevel error -show_entries stream:format \"\(inputFilePath)\"")
  let logs = session?.getAllLogsAsString()!.trimmingCharacters(in: .whitespacesAndNewlines)

  return buildVideo(withFfprobeOutput: logs!, inputFilePath: inputFilePath)
}

// This uses the same command as getAllVideoProperties but we leave out the loglevel field to include additional metadata
func getFfprobeOutput(inputFilePath: String) -> String {
  let session = FFprobeKit.execute("-show_entries stream:format \"\(inputFilePath)\"")
  let logs = session?.getAllLogsAsString()
  
  let output = logs!.trimmingCharacters(in: .whitespacesAndNewlines)
  return output
}

func isFileValid(inputFilePath: String) -> Bool {
  let session = FFprobeKit.execute("-loglevel error \"\(inputFilePath)\"")
  let logs = session?.getAllLogsAsString()
  
  let error = logs!.trimmingCharacters(in: .whitespacesAndNewlines)
  
  return error.count == 0
}
