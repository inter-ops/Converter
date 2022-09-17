//
//  Video.swift
//  Converter
//
//  Created by Francesco Virga on 2022-09-17.
//

struct VideoStream {
  let codec: VideoCodec
  let rawCodecName: String  // in case we have an unknown VideoCodec, we can see it here
  let codecLongName: String
  let profile: String
  let codecType: String // TODO: enum of "video" "audio" "subtitle"
  let codecTagString: String
  let codecTag: String // TODO: hex or something, example was 0x0000
  let width: Int
  let height: Int
  
  let sampleAspectRatio: String
  let displayAspectRatio: String
  let pixFmt: String // TODO enum, example was "yuv420p"
  
  let numberOfFrames: Int // This comes from nb_read_packets
  
  // TODO: enum or int for both below, examples were both 24/1, look into difference between these two
  let rFrameRate: String
  let avgFrameRate: String
  
  init(ffprobeDict: [String: String]) {
    self.rawCodecName = ffprobeDict["codec_name"] ?? ""
    self.codec = convertToVideoCodec(inputCodec: ffprobeDict["codec_name"] ?? "")
    self.codecLongName = ffprobeDict["codec_long_name"] ?? ""
    self.profile = ffprobeDict["profile"] ?? ""
    self.codecType = ffprobeDict["codec_type"] ?? ""
    self.codecTagString = ffprobeDict["codec_tag_string"] ?? ""
    self.codecTag = ffprobeDict["codec_tag"] ?? ""
    self.width = Int(ffprobeDict["width"] ?? "0")!
    self.height = Int(ffprobeDict["height"] ?? "0")!
    self.sampleAspectRatio = ffprobeDict["sample_aspect_ratio"] ?? ""
    self.displayAspectRatio = ffprobeDict["display_aspect_ratio"] ?? ""
    self.pixFmt = ffprobeDict["pix_fmt"] ?? ""
    self.numberOfFrames = Int(ffprobeDict["nb_read_packets"] ?? "0")!
    self.rFrameRate = ffprobeDict["r_frame_rate"] ?? ""
    self.avgFrameRate = ffprobeDict["avg_frame_rate"] ?? ""
  }
}

struct AudioStream {
  let codec: AudioCodec
  let rawCodecName: String  // in case we have an unknown AudioCodec, we can see it here
  let codecLongName: String
  
  // TODO: This will be used to differentiate types of DTS (DTS, DTS-HD), types of AAC (HE-AAC, AAC-LC, etc.). Us an enum.
  // Some resource:
  // - https://stackoverflow.com/questions/61365587/what-does-profile-means-in-an-aac-encoded-audio
  // - https://trac.ffmpeg.org/wiki/Encode/HighQualityAudio
  // - https://trac.ffmpeg.org/wiki/Encode/AAC
  let profile: String
  
  let codecType: String // TODO: enum of "video" "audio" "subtitle"
  let codecTagString: String
  let codecTag: String // TODO: hex or something, example was 0x0000
  
  let sampleRate: Int
  let channels: Int
  let channelLayout: ChannelLayout
  let rawChannelLayout: String // in case we have an unknown ChannelLayout, we can see it here
  
  let bitRate: Int // TODO: this is bits or bytes / s, double check
  
  let language: String? // From TAG:language if exists
  let title: String? // From TAG:title if exists
  
  init(ffprobeDict: [String: String]) {
    self.rawCodecName = ffprobeDict["codec_name"] ?? ""
    self.codec = convertToAudioCodec(inputCodec: ffprobeDict["codec_name"] ?? "")
    self.codecLongName = ffprobeDict["codec_long_name"] ?? ""
    self.profile = ffprobeDict["profile"] ?? ""
    self.codecType = ffprobeDict["codec_type"] ?? ""
    self.codecTagString = ffprobeDict["codec_tag_string"] ?? ""
    self.codecTag = ffprobeDict["codec_tag"] ?? ""
    self.sampleRate = Int(ffprobeDict["sample_rate"] ?? "0")!
    self.channels = Int(ffprobeDict["channels"] ?? "0")!
    self.rawChannelLayout = ffprobeDict["channel_layout"] ?? ""
    self.channelLayout = convertToChannelLayout(inputChannelLayout: ffprobeDict["channel_layout"] ?? "")
    self.bitRate = Int(ffprobeDict["bit_rate"] ?? "0") ?? 0 // This can sometimes be N/A
    self.language = ffprobeDict["TAG:language"]
    self.title = ffprobeDict["TAG:title"]
  }
}

struct SubtitleStream {
  let codec: SubtitleCodec
  let rawCodecName: String  // in case we have an unknown SubtitleCodec, we can see it here
  let codecLongName: String
  let profile: String
  let codecType: String // TODO: enum of "video" "audio" "subtitle"
  let codecTagString: String
  let codecTag: String // TODO: hex or something, example was 0x0000
  
  let language: String? // From TAG:language if exists
  
  init(codecName: String, codecLongName: String, profile: String, codecType: String, codecTagString: String, codecTag: String, language: String) {
    self.rawCodecName = codecName
    self.codec = convertToSubtitleCodec(inputCodec: codecName)
    self.codecLongName = codecLongName
    self.profile = profile
    self.codecType = codecType
    self.codecTagString = codecTagString
    self.codecTag = codecTag
    
    self.language = language
  }
  
  init(ffprobeDict: [String: String]) {
    self.rawCodecName = ffprobeDict["codec_name"] ?? ""
    self.codec = convertToSubtitleCodec(inputCodec: ffprobeDict["codec_name"] ?? "")
    self.codecLongName = ffprobeDict["codec_long_name"] ?? ""
    self.profile = ffprobeDict["profile"] ?? ""
    self.codecType = ffprobeDict["codec_type"] ?? ""
    self.codecTagString = ffprobeDict["codec_tag_string"] ?? ""
    self.codecTag = ffprobeDict["codec_tag"] ?? ""
    self.language = ffprobeDict["TAG:language"]
  }
}

struct Video {
  let title: String? // This comes from TAG:title if exists
  let filePath: String
  let duration: Double // Seconds
  let bitRate: Int // TODO: this is bits or bytes / s, double check
  let size: Int // TODO: this is bits or bytes, double check
  
  let formatName: String // TODO: enum
  let formatLongName: String // TODO: enum if possible
  let encoder: String? // This comes from TAG:ENCODER if exists
  let videoStreams: [VideoStream]
  let audioStreams: [AudioStream]
  let subtitleStreams: [SubtitleStream]
  
  init(ffprobeDict: [String: String], filePath: String, videoStreams: [VideoStream], audioStreams: [AudioStream], subtitleStreams: [SubtitleStream]) {
    self.title = ffprobeDict["TAG:title"]
    self.encoder = ffprobeDict["TAG:ENCODER"]
    self.filePath = filePath
    
    self.duration = Double(ffprobeDict["duration"] ?? "0")!
    self.bitRate = Int(ffprobeDict["bit_rate"] ?? "0")!
    self.size = Int(ffprobeDict["size"] ?? "0")!
    self.formatName = ffprobeDict["format_name"] ?? ""
    self.formatLongName = ffprobeDict["format_long_name"] ?? ""
    self.videoStreams = videoStreams
    self.audioStreams = audioStreams
    self.subtitleStreams = subtitleStreams
  }
}

func buildVideo(withFfprobeOutput: String, inputFilePath: String) -> Video {
  let components = withFfprobeOutput.components(separatedBy: "[/STREAM]\n");
  
  var videoStreams: [VideoStream] = []
  var audioStreams: [AudioStream] = []
  var subtitleStreams: [SubtitleStream] = []
  
  var video: Video?
  
  for component in components {
    let isStream = component.hasPrefix("[STREAM]")
    let pureComponent = component.replacingOccurrences(of: "[STREAM]\n", with: "").replacingOccurrences(of: "[FORMAT]\n", with: "").replacingOccurrences(of: "\n[/FORMAT]", with: "")
    
    var dict: [String: String] = [:]
    for keyValuePairString in pureComponent.components(separatedBy: "\n") {
      if keyValuePairString.isEmpty {
        continue
      }
      
      let keyValuePair = keyValuePairString.components(separatedBy: "=")
      let key = keyValuePair[0]
      let value = keyValuePair[1]
      dict[key] = value
    }
    
    if isStream {
      let streamType = dict["codec_type"] ?? ""
      
      switch streamType {
      case "video":
        let videoStream = VideoStream(ffprobeDict: dict)
        videoStreams.append(videoStream)
      case "audio":
        let audioStream = AudioStream(ffprobeDict: dict)
        audioStreams.append(audioStream)
      case "subtitle":
        let subtitleStream = SubtitleStream(ffprobeDict: dict)
        subtitleStreams.append(subtitleStream)
      default:
        print("Unknown stream type \(streamType)")
      }
    }
    else {
      // Create video properties
      video = Video(ffprobeDict: dict, filePath: inputFilePath, videoStreams: videoStreams, audioStreams: audioStreams, subtitleStreams: subtitleStreams)
    }
  }
  
  return video!
}
