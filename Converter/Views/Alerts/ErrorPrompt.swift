//
//  ErrorPrompt.swift
//  Converter
//
//  Created by Justin Bush on 9/2/22.
//

import Cocoa

extension ViewController {
  
  /// Alert user of an error that occured, with the option of forwarding to devs
  func unexpectedErrorAlert(inputVideos: [Video], outputQuality: VideoQuality, outputCodec: VideoCodec) {
    let errorVideos = inputVideos.filter({ $0.didError == true })
    
    let a = NSAlert()
    a.messageText = "An error occured"
    a.informativeText = "There was a problem converting \(inputVideos.count > 1 ? "\(errorVideos.count)/\(inputVideos.count) of your files" : "your file"). Would you like to send this error to the dev team?"
    a.addButton(withTitle: "Send")
    a.addButton(withTitle: "Dismiss")
    a.alertStyle = NSAlert.Style.critical
    
    a.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
      
      if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
        Logger.debug("User did choose to send error message")
        self.segueToErrorReport(inputVideos: inputVideos, outputQuality: outputQuality, outputCodec: outputCodec)
      }
      
      if modalResponse == NSApplication.ModalResponse.alertSecondButtonReturn {
        Logger.debug("User did dismiss error message")
      }
    })
  }
  
  func errorAlert(withMessage: String) {
    Logger.debug("Error alert shown with message \(withMessage)")
    
    let a = NSAlert()
    a.messageText = "An error occured"
    a.informativeText = withMessage
    a.addButton(withTitle: "Ok")
    a.alertStyle = NSAlert.Style.critical
    
    a.beginSheetModal(for: self.view.window!)
  }
}

/// Input console log String; return `.txt` file with temporary address to be used as an attachment
/// - Parameters:
///   - contents: Console log contents as a String
/// - Returns: URL reference of temporary `.txt` file
func writeTempTxtFile(_ contents: String) -> URL {
  let url = FileManager.default.temporaryDirectory
    .appendingPathComponent("error-log-\(UUID().uuidString)")
    .appendingPathExtension("txt")
  let string = contents
  try? string.write(to: url, atomically: true, encoding: .utf8)
  return url
}

// MARK: Error Log Headers
struct ErrorLogHeaders {
  static let messageHeader = """
  [Enter any additional details here]
  \n\n
  Please do not touch anything below this line.
  ----------
  \n\n
  """
  
  static let error = """
  \n\n
  ######################
  ### ERROR CONTENTS ###
  ######################
  \n\n
  """
  static let ffprobe = """
  \n\n
  ######################
  ### FFPROBE OUTPUT ###
  ######################
  \n\n
  """
}

// MARK: Error Test Data
// Sample Error for testing prompt reporting
extension ViewController {
  /// Calls sample alertErrorPrompt() with error output for: unavailable input channels
  @IBAction func triggerAlertErrorTestAction(_ sender: NSMenuItem) {
    let a = AlertErrorTest.self
    a.inputVideo.outputFileUrl = a.outputFileUrl
    
    unexpectedErrorAlert(inputVideos: [a.inputVideo], outputQuality: a.outputQuality, outputCodec: a.outputCodec)
  }
}

struct AlertErrorTest {
  static let inputFileUrl = URL(fileURLWithPath: "/Users/justinbush/Desktop/AV Test Files/YouTube 4K Trailer (2160p_25fps_VP9 LQ-160kbit_Opus).webm")
  static let outputFileUrl = URL(fileURLWithPath: "/Users/justinbush/Downloads/YouTube 4K Trailer (2160p_25fps_VP9 LQ-160kbit_Opus).mp4")
  static let outputQuality = VideoQuality.betterQuality
  static let outputCodec = VideoCodec.h264
  static let ffmpegCommand = """
  -hide_banner -loglevel error -y -i "/Users/justinbush/Desktop/AV Test Files/YouTube 4K Trailer (2160p_25fps_VP9 LQ-160kbit_Opus).webm" -filter_complex "channelmap=channel_layout=5.1" -c:a aac -c:v libx264 -preset veryfast -crf 26 -c:s mov_text "/Users/justinbush/Downloads/YouTube 4K Trailer (2160p_25fps_VP9 LQ-160kbit_Opus).mp4"
  """
  static let ffmpegSessionLogs = """
  [Parsed_channelmap_0 @ 0x7fb71b812410] input channel #2 not available from input layout 'stereo'
  [Parsed_channelmap_0 @ 0x7fb71b812410] input channel #3 not available from input layout 'stereo'
  [Parsed_channelmap_0 @ 0x7fb71b812410] input channel #4 not available from input layout 'stereo'
  [Parsed_channelmap_0 @ 0x7fb71b812410] input channel #5 not available from input layout 'stereo'
  [Parsed_channelmap_0 @ 0x7fb71b812410] Failed to configure input pad on Parsed_channelmap_0
  Error reinitializing filters!
  Failed to inject frame into filter network: Invalid argument
  Error while processing the decoded data for stream #0:1
  """
  static let ffprobeOutput = """
  ffprobe version v4.5-dev-3393-g30322ebe3c Copyright (c) 2007-2021 the FFmpeg developers
  built with Apple clang version 13.0.0 (clang-1300.0.29.30)
  configuration: --cross-prefix=x86_64-apple-darwin- --sysroot=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX12.1.sdk --prefix=/Users/taner/Projects/ffmpeg-kit/prebuilt/apple-macos-x86_64/ffmpeg --pkg-config=/opt/homebrew/bin/pkg-config --enable-version3 --arch=x86_64 --cpu=x86_64 --target-os=darwin --disable-neon --disable-asm --ar=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/ar --cc=clang --cxx=clang++ --as='clang -arch x86_64 -target x86_64-apple-darwin10.15 -march=x86-64 -msse4.2 -mpopcnt -m64 -DFFMPEG_KIT_X86_64 -Wno-unused-function -Wno-deprecated-declarations -fstrict-aliasing -DMACOSX -DFFMPEG_KIT_BUILD_DATE=20220114 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX12.1.sdk -O2 -mmacosx-version-min=10.15 -I/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX12.1.sdk/usr/include' --ranlib=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/ranlib --strip=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/strip --nm=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/nm --extra-ldflags='-mmacosx-version-min=10.15' --disable-autodetect --enable-cross-compile --enable-pic --enable-inline-asm --enable-optimizations --enable-swscale --enable-shared --disable-static --install-name-dir='@rpath' --enable-pthreads --disable-v4l2-m2m --disable-outdev=v4l2 --disable-outdev=fbdev --disable-indev=v4l2 --disable-indev=fbdev --enable-small --disable-xmm-clobber-test --disable-debug --disable-neon-clobber-test --disable-programs --disable-postproc --disable-doc --disable-htmlpages --disable-manpages --disable-podpages --disable-txtpages --disable-sndio --disable-schannel --disable-securetransport --disable-xlib --disable-cuda --disable-cuvid --disable-nvenc --disable-vaapi --disable-vdpau --disable-alsa --disable-cuda --disable-cuvid --disable-nvenc --disable-vaapi --disable-vdpau --enable-libfontconfig --enable-libfreetype --enable-libfribidi --enable-gmp --enable-gnutls --enable-libmp3lame --enable-libass --enable-libtheora --enable-libvorbis --enable-libvpx --enable-libwebp --enable-libxml2 --enable-libopencore-amrnb --enable-libshine --enable-libspeex --enable-libdav1d --enable-libkvazaar --enable-libx264 --enable-libxvid --enable-libx265 --enable-libvidstab --enable-libilbc --enable-libopus --enable-libsnappy --enable-libsoxr --enable-libtwolame --disable-sdl2 --enable-libvo-amrwbenc --enable-libzimg --disable-openssl --enable-zlib --enable-audiotoolbox --enable-bzlib --enable-videotoolbox --enable-avfoundation --enable-iconv --enable-coreimage --enable-appkit --enable-opencl --enable-opengl --enable-gpl
  libavutil      57. 13.100 / 57. 13.100
  libavcodec     59. 15.102 / 59. 15.102
  libavformat    59. 10.100 / 59. 10.100
  libavdevice    59.  1.100 / 59.  1.100
  libavfilter     8. 21.100 /  8. 21.100
  libswscale      6.  1.102 /  6.  1.102
  libswresample   4.  0.100 /  4.  0.100
  Input #0, matroska,webm, from '/Users/justinbush/Desktop/AV Test Files/YouTube 4K Trailer (2160p_25fps_VP9 LQ-160kbit_Opus).webm':
  Metadata:
    ENCODER         : Lavf58.39.101
  Duration: 00:03:49.50, start: -0.007000, bitrate: 7285 kb/s
  Stream #0:0(eng): Video: vp9, yuv420p(tv, bt709), 3840x2160, SAR 1:1 DAR 16:9, 25 fps, 25 tbr, 1k tbn (default)
    Metadata:
      DURATION        : 00:03:49.480000000
  Stream #0:1(eng): Audio: opus, 48000 Hz, stereo, fltp (default)
    Metadata:
      DURATION        : 00:03:49.501000000
  """
  
  static var inputVideo = buildVideo(withFfprobeOutput: ffprobeOutput, inputFileUrl: inputFileUrl)
}
