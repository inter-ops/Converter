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
 - https://superuser.com/questions/1380946/how-do-i-convert-10-bit-h-265-hevc-videos-to-h-264-without-quality-loss
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

func getOutputBitrateForHEVC(inputVideo: Video) -> Int {
  let h264Bitrate = getOutputBitrateForH264(inputVideo: inputVideo)
  
  // Based on testing, quality for HEVC seems equal to H264 at 80% bitrate. So multiply H264 bitrate by 0.8
  return Int(Double(h264Bitrate) * 0.8)
}

func getOutputBitrateForH264(inputVideo: Video) -> Int {
  let inputWidth = inputVideo.videoStreams[0].width
  let inputHeight = inputVideo.videoStreams[0].height
  
  // If the input height is slightly above a target we will round down, otherwise we always round up. The maximums below dictate the number at which we would round down for.
  
  let maxWidth1080p = 2400 // Regular width: 1920, // Regular width for 2016p is 3840
  let maxWidth720p = 1500 // Regular width: 1280
  let maxWidth480p = 900 // Regular width: 720
  let maxWidth360p = 500 // Regular width: 480
  let maxWidth240p = 380 // Regular width: 320
  
  // Resource for values:
  // - Defaults of Handbrake & manual testing
  // - https://slhck.info/video/2017/02/24/crf-guide.html (For CRF 20, which is what we used to use with libx264)
  // - https://netflixtechblog.com/per-title-encode-optimization-7e99442b62a2
  // - https://netflixtechblog.com/optimized-shot-based-encodes-for-4k-now-streaming-47b516b10bbb
  if inputWidth > maxWidth1080p {
    // 2016p
    return 16000000 // 16M
  }
  else if inputWidth > maxWidth720p {
    // 1080p
    return 8000000 // 8M
  }
  else if inputWidth > maxWidth480p {
    // 720p
    return 4000000 // 4M
  }
  else if inputWidth > maxWidth360p {
    // 576p or 480p
    if inputHeight > 540 {
      // We assume this means 576p
      return 3000000 // 3M
    }
    else {
      // 480p
      return 2000000 // 2M
    }
  }
  else if inputWidth > maxWidth240p {
    // 360p
    return 1000000 // 1M
  }
  else {
    // 240p
    return 750000 // 750k
  }
}

func getOutputCrfForVp9(inputVideo: Video) -> Int {
  let inputWidth = inputVideo.videoStreams[0].width
  
  // If the input height is slightly above a target we will round down, otherwise we always round up. The maximums below dictate the number at which we would round down for.
  
  let maxWidth1440p = 2800 // Regular width: 2560, Regular width for 2016p is 3840
  let maxWidth1080p = 2100 // Regular width: 1920
  let maxWidth720p = 1500 // Regular width: 1280
  let maxWidth480p = 900 // Regular width: 720
  let maxWidth360p = 500 // Regular width: 480
  let maxWidth240p = 380 // Regular width: 320
  
  // Resource for values:
  // https://developers.google.com/media/vp9/settings/vod/#quality
  // https://trac.ffmpeg.org/wiki/Encode/VP9
  if inputWidth > maxWidth1440p {
    // 2016p
    return 15
  }
  if inputWidth > maxWidth1080p {
    // 1440p
    return 24
  }
  else if inputWidth > maxWidth720p {
    // 1080p
    return 31
  }
  else if inputWidth > maxWidth480p {
    // 720p
    return 32
  }
  else if inputWidth > maxWidth360p {
    // 480p
    return 33
  }
  else if inputWidth > maxWidth240p {
    // 360p
    return 36
  }
  else {
    // 240p
    return 37
  }
}

// TODO: For apple silicon users we can use constant quality mode, see here https://stackoverflow.com/a/69668183

/// Video Toolbox
/// "allow_sw 1" ensures that VT can be used on machines that don't support hardware encoding
/// vf flag is to ensure the output width and height are divisible by 2, see https://stackoverflow.com/a/29582287/8292279

// TODO: Handle output quality
func getVideoCommandForH264(inputVideo: Video, outputQuality: VideoQuality) -> String {
  let inputVideoCodec = inputVideo.videoStreams[0].codec
  if inputVideoCodec == .h264 {
    return "-c:v copy"
  }
  
  let outputBitrate = getOutputBitrateForH264(inputVideo: inputVideo)
  return "-c:v h264_videotoolbox -b:v \(outputBitrate) -pix_fmt yuv420p -allow_sw 1 -vf \"scale=trunc(iw/2)*2:trunc(ih/2)*2\""
}

// TODO: Test
// TODO: Handle output quality
func getVideoCommandForHEVC(inputVideo: Video, outputQuality: VideoQuality) -> String {
  let inputVideoCodec = inputVideo.videoStreams[0].codec
  let outputFileType = getFileExtension(filePath: inputVideo.outputFilePath!)
  
  var command: String
  if inputVideoCodec == .hevc {
    // https://brandur.org/fragments/ffmpeg-h265
    // M4V does not support HEVC so we must re-encode this case
    command = "-c:v copy -tag:v hvc1"
  }
  else {
    let outputBitrate = getOutputBitrateForHEVC(inputVideo: inputVideo)
    // 10 bit color is required, see https://trac.ffmpeg.org/ticket/9521
    command = "-c:v hevc_videotoolbox -b:v \(outputBitrate) -tag:v hvc1 -pix_fmt yuv420p10le -allow_sw 1 -vf \"scale=trunc(iw/2)*2:trunc(ih/2)*2\""
  }

  // M4V needs this flag to be able to play HEVC, see https://trac.ffmpeg.org/ticket/7685
  if outputFileType == VideoFormat.m4v.rawValue {
    command += " -f mp4"
  }
  
  return command
}

func getVideoCommandForProres(inputVideo: Video, outputQuality: VideoQuality) -> String {
  // See docs under Prores for pix_fmt details https://trac.ffmpeg.org/wiki/Encode/VFX
  // TODO: We currently get a warning that this pix fmt is unsupported, but ffmpeg choses a supported one automatically so it doesnt cause us any issues.
  let pixFmt = outputQuality == .pr4444 || outputQuality == .pr4444Xq ? "yuva444p10le" : "yuv422p10le"
  
  return "-c:v prores_videotoolbox -profile:v \(outputQuality.profile) -pix_fmt \(pixFmt) -allow_sw 1"
}

/// VP8 and VP9
/// cpu-used 2 speeds up processing by about 2x, but does impact quality a bit. I haven't seen a noticeable difference, but if it becomes problematic, we should set it to 1.
/// See here for more info:
/// - https://superuser.com/questions/1586934/vp9-encoding-with-ffmpeg-relation-between-speed-and-deadline-options
/// - https://superuser.com/questions/556463/converting-video-to-webm-with-ffmpeg-avconv
/// - https://superuser.com/a/1280369

// TODO: Handle output quality
func getVideoCommandForVp8(inputVideo: Video, outputQuality: VideoQuality) -> String {
  let inputVideoCodec = inputVideo.videoStreams[0].codec
  if inputVideoCodec == .vp8 {
    return "-c:v copy"
  }
  
  // https://trac.ffmpeg.org/wiki/Encode/VP8 Vartiable bitrate
  // VP8 output bitrates are very similar to h264, so we can use that value here
  let outputBitrate = getOutputBitrateForH264(inputVideo: inputVideo)
  return "-c:v libvpx -b:v \(outputBitrate) -crf 5 -deadline good -cpu-used 2 -pix_fmt yuv420p"
}

// TODO: Test quality output
// TODO: Handle output quality
func getVideoCommandForVp9(inputVideo: Video, outputQuality: VideoQuality) -> String {
  let inputVideoCodec = inputVideo.videoStreams[0].codec
  if inputVideoCodec == .vp9 {
    return "-c:v copy"
  }
  
  // https://trac.ffmpeg.org/wiki/Encode/VP9 Constant Quality mode
  let outputCrf = getOutputCrfForVp9(inputVideo: inputVideo)
  return "-c:v libvpx-vp9 -crf \(outputCrf) -b:v 0 -deadline good -cpu-used 2 -pix_fmt yuv420p"
}

func getVideoCommandForMpeg4(inputVideo: Video, outputQuality: VideoQuality) -> String {
  let inputVideoCodec = inputVideo.videoStreams[0].codec
  let inputVideoCodecTag = inputVideo.videoStreams[0].codecTagString
  let outputFileType = getFileExtension(filePath: inputVideo.outputFilePath!)
  
  var qscale: Int
  if outputQuality == .betterQuality {
    qscale = 2
  }
  else if outputQuality == .smallerSize {
    qscale = 10
  }
  else {
    qscale = 4
  }
  
  // MP4, MOV and M4v do not support XVID, so we handle these separately
  if outputFileType == VideoFormat.mov.rawValue || outputFileType == VideoFormat.mp4.rawValue || outputFileType == VideoFormat.m4v.rawValue {
    // If the input is MPEG4 but not XVID, we can remux.
    if inputVideoCodec == .mpeg4 && inputVideoCodecTag != "xvid" {
      return "-c:v copy"
    }
    
    // TODO: We may be able to still copy here, but simply use a different vtag. Need to research if this is possible.
    // Otherwise we need to re-encode the XVID streams using a different FourCC.
    // We simply use the default FourCC: FMP4. See here for more details: https://trac.ffmpeg.org/wiki/Encode/MPEG-4
    return "-c:v mpeg4 -qscale:v \(qscale) -pix_fmt yuv420p"
  }
  
  // For all other input MPEG4 files, we can remux
  if inputVideoCodec == .mpeg4 {
    return "-c:v copy"
  }
  
  // https://trac.ffmpeg.org/wiki/Encode/MPEG-4
  // NOTE: In the past we used "-c:v libxvid -qscale:v 5" but libxvid is a GPL library so we switched to the native encoder.
  // If we want to swtich back to libxvid, we still need to use the native encoder for GIF inputs since libxvid throws unknown errors.
  return "-c:v mpeg4 -vtag xvid -qscale:v 5 -pix_fmt yuv420p"
}

func getVideoCommandForGif(inputVideo: Video, outputQuality: VideoQuality) -> String {
  // We dont need to do any remuxing for input videos which already use gif codec since it can only be used with gif files. The only case where a user would convert from an input gif to an output gif is if there is an issue with their original file which may be resolved from re-encoding.
  
  // Gif conversion resources:
  // https://superuser.com/a/556031
  // http://blog.pkh.me/p/21-high-quality-gif-with-ffmpeg.html
  // https://engineering.giphy.com/how-to-make-gifs-with-ffmpeg/
  // Frame rate: https://trac.ffmpeg.org/wiki/ChangingFrameRate
  
  // TODO: There is still a slight stutter with certain output videos. This seems to improve with higher FPS but not resolve completely.
  // TODO: There is a slight delay with progress as the palette file needs to be created. Look into ways to estimate this, or may want to add an arbitrary delay based on file size or format. This delay is especially long for x265. Didnt find much online, so should ask stackoverflow. At the minimum, we should make it more clear that we are estimating conversion time during this period (since we show no progress bar).
  // NOTE: If color is an issue, use "palettegen=stats_mode=single" and "paletteuse=new=1"
  return "-vf \"fps=15,scale=0:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse\" -loop 0"
}

// TODO: How do we handle output quality if its a remux?

/// Get the video portion of the ffmpeg command.
/// For x264, we always use 8-bit colour (pixfmt yuv420p) to ensure maximum support. See "Encoding for dumb players" here for more info: https://trac.ffmpeg.org/wiki/Encode/H.264
/// We use a crf of 20. The default is 23, and 17-18 is considered visually lossless. See "Choose a CRF value" here for more info: https://trac.ffmpeg.org/wiki/Encode/H.264
func getVideoConversionCommand(inputVideo: Video, outputCodec: VideoCodec, outputQuality: VideoQuality) -> String {
  if inputVideo.videoStreams.isEmpty {
    return ""
  }
  
  let inputVideoCodec = inputVideo.videoStreams[0].codec
  let inputVideoCodecTag = inputVideo.videoStreams[0].codecTagString
  let outputFileType = getFileExtension(filePath: inputVideo.outputFilePath!)

  if outputCodec != .auto {
    switch outputCodec {
    case .mpeg4:
      return getVideoCommandForMpeg4(inputVideo: inputVideo, outputQuality: outputQuality)
    case .h264:
      return getVideoCommandForH264(inputVideo: inputVideo, outputQuality: outputQuality)
    case .hevc:
      return getVideoCommandForHEVC(inputVideo: inputVideo, outputQuality: outputQuality)
    case .vp8:
      return getVideoCommandForVp8(inputVideo: inputVideo, outputQuality: outputQuality)
    case .vp9:
      return getVideoCommandForVp9(inputVideo: inputVideo, outputQuality: outputQuality)
    case .gif:
      return getVideoCommandForGif(inputVideo: inputVideo, outputQuality: outputQuality)
    case .prores:
      return getVideoCommandForProres(inputVideo: inputVideo, outputQuality: outputQuality)
    default:
      // This should never happen
      Logger.error("Unexpected output video codec selected by user \(outputCodec)")
    }
  }

  
  // No output video codec selected, so we can chose the best codec. We remux when possible, and re-encode in all other cases.
  
  switch outputFileType {
    
  case VideoFormat.webm.rawValue:
    if inputVideoCodec == .vp9 {
      // If input is already VP9, we call getVideoCommandForVp9, which will remux the input
      return getVideoCommandForVp9(inputVideo: inputVideo, outputQuality: outputQuality)
    }
    // All other cases, we convert to VP8 (this also handles remuxing if input is already VP8)
    return getVideoCommandForVp8(inputVideo: inputVideo, outputQuality: outputQuality)
  
  case VideoFormat.mp4.rawValue, VideoFormat.mov.rawValue, VideoFormat.m4v.rawValue, VideoFormat.mkv.rawValue:
    
    // MOV does not support xvid, so we re-encode to H264
    if inputVideoCodecTag == "xvid" && outputFileType == VideoFormat.mov.rawValue {
      return getVideoCommandForH264(inputVideo: inputVideo, outputQuality: outputQuality)
    }
    else if inputVideoCodec == .hevc {
      // For input HEVC we can copy the codec (handled in getVideoCommandForHEVC)
      return getVideoCommandForHEVC(inputVideo: inputVideo, outputQuality: outputQuality)
    }
    else if inputVideoCodec == .h264 || inputVideoCodec == .mpeg4 || inputVideoCodec == .mpeg1video || inputVideoCodec == .mpeg2video {
      return "-c:v copy"
    }
    
    // For gif inputs, there are odd cases (such as really low FPS & frame number gifs, eg https://github.com/cyburgee/ffmpeg-guide/blob/master/321.gif) which will trip up VLC and stop playback too early.
    // If we are having issues with this, review the method outlined here: https://github.com/cyburgee/ffmpeg-guide I already tried integrating this but found that using fps=source_fps wouldn't fix the issue, the FPS had to be increased. I don't want to screw with FPS too much for now unless we see this become a problem in the wild.
    // GIF Resource: https://unix.stackexchange.com/a/294892
    
    // For everything else, re-encode to H264.
    return getVideoCommandForH264(inputVideo: inputVideo, outputQuality: outputQuality)
    
  case VideoFormat.avi.rawValue:
    // If this command ever causes problems for GIF inputs, try https://stackoverflow.com/questions/3212821/animated-gif-to-avi-on-linux https://www.linuxquestions.org/questions/linux-software-2/converting-animated-gif-to-avi-ffmpeg-549839/#edit2729743
    return getVideoCommandForMpeg4(inputVideo: inputVideo, outputQuality: outputQuality)
    
  case VideoFormat.gif.rawValue:
    return getVideoCommandForGif(inputVideo: inputVideo, outputQuality: outputQuality)
    
  default:
    // For unknown cases, we re-encode to H264
    Logger.error("Unknown output file type when selecting video codec")
    return getVideoCommandForH264(inputVideo: inputVideo, outputQuality: outputQuality)
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
func getAudioConversionCommand(inputVideo: Video, outputVideoCodec: VideoCodec) -> String {
  let outputFileType = getFileExtension(filePath: inputVideo.outputFilePath!)
  
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
    // If input audio is not one of the generally supported codecs, we can check for some additional cases which ProRes supports
    else if outputVideoCodec == .prores {
      if inputAudioCodec == .pcm_s16le || inputAudioCodec == .pcm_s24le || inputAudioCodec == .pcm_s32le || inputAudioCodec == .pcm_f32le || inputAudioCodec == .flac {
        return "-c:a copy"
      }
      else {
        // For ProRes outputs, pcm_s16le and pcm_s24le are most common.
        return "-c:a pcm_s24le"
      }
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
    // TODO: We don't need to re-encode DTS, only DTS-HD. Should be able to determine this with all the metadata we are capturing.
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
func getSubtitleConversionCommand(inputVideo: Video) -> String {
  let outputFileType = getFileExtension(filePath: inputVideo.outputFilePath!)
  
  // If we don't have any audio streams, or we are converting to GIF, we don't need a subtitle conversion command
  if inputVideo.subtitleStreams.isEmpty || outputFileType == VideoFormat.gif.rawValue {
    return ""
  }
  
  guard let textBasedStreamIndex = inputVideo.subtitleStreams.firstIndex(where: { $0.isTextBased == true }) else {
    return ""
  }

  switch outputFileType {
  case VideoFormat.mp4.rawValue, VideoFormat.m4v.rawValue, VideoFormat.mov.rawValue:
    // NOTE: "-map_metadata:c" is to prevent creating a new subtitle stream with only chapters being shown, see below:
    // https://www.reddit.com/r/ffmpeg/comments/jtzue6/comment/gc9wz0v/?utm_source=share&utm_medium=web2x&context=3
    // https://trac.ffmpeg.org/ticket/9436
    return "-map_metadata:c -1 -map 0:s:\(textBasedStreamIndex) -c:s:0 mov_text"
  case VideoFormat.mkv.rawValue:
    return "-map 0:s:\(textBasedStreamIndex) -c:s:0 ass" // We could also use srt, which is a less advanced format but may be better supported
  case VideoFormat.webm.rawValue:
    return "-map 0:s:\(textBasedStreamIndex) -c:s:0 webvtt"
  case VideoFormat.avi.rawValue:
    return "" // AVI does not support soft-subs.
  default:
    Logger.error("Unknown output file type when selecting subtitle codec")
    return ""
  }
  
}

// TODO: FFMPEG command could be built using a builder class (eg withVideoCodec("x264").withCrf(20)), would cleanup the getVideoConversionCommand, getAudioConversionCommand and getSubtitleConversionCommand functions
func getFfmpegCommand(inputVideo: Video, outputVideoCodec: VideoCodec, outputVideoQuality: VideoQuality) -> String {
  let videoCommand = getVideoConversionCommand(inputVideo: inputVideo, outputCodec: outputVideoCodec, outputQuality: outputVideoQuality)
  let audioCommand = getAudioConversionCommand(inputVideo: inputVideo, outputVideoCodec: outputVideoCodec)
  let subtitleCommand = getSubtitleConversionCommand(inputVideo: inputVideo)
  
  // We currently map all audio and video streams, but subtitle stream mapping is handled by getSubtitleConversionCommand. Once we support
  // converting more than one audio and video stream, the mapping should be moved to getVideoConversionCommand and getAudioConversionCommand
  let command = "-hide_banner -y -i \"\(inputVideo.filePath)\" -map 0:v? -map 0:a? \(audioCommand) \(videoCommand) \(subtitleCommand) \"\(inputVideo.outputFilePath!)\""
  
  return command
}

func runFfmpegCommand(command: String, onDone: @escaping (_: FFmpegSession?) -> Void) -> FFmpegSession {
  Logger.info("Running FFMPEG command: \(command)")
  
  let session = FFmpegKit.executeAsync(command, withCompleteCallback: onDone)
  
  return session!
}

func getAllVideoProperties(inputFileUrl: URL) -> Video {
  let session = FFprobeKit.execute("-loglevel error -show_entries stream:format \"\(inputFileUrl.path)\"")
  let logs = session?.getAllLogsAsString()!.trimmingCharacters(in: .whitespacesAndNewlines)

  return buildVideo(withFfprobeOutput: logs!, inputFileUrl: inputFileUrl)
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
