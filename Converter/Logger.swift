//
//  Logger.swift
//  Converter
//
//  Created by Francesco Virga on 2022-10-04.
//

import Foundation
import ffmpegkit
import os
import OSLog

// Resources
// - https://steipete.com/posts/logging-in-swift/
// - How to format a logger https://www.avanderlee.com/debugging/oslog-unified-logging/ https://www.lordcodes.com/articles/clear-and-searchable-logging-in-swift-with-oslog
// - Overview of logging options: https://stackoverflow.com/questions/25951195/swift-print-vs-println-vs-nslog
// FFMPEG kit overview (discusses logging): https://tanersener.medium.com/introduction-to-ffmpeg-kit-api-59623911fbfc

let subsystem = Bundle.main.bundleIdentifier!

// TODO: Make available for older platforms

// TODO: Create wrapper func for logging so that we can pass generic strings

@available(macOS 11.0, *)
struct ApplicationLogger {
  static let applicationLogger = Logger(subsystem: subsystem, category: "application")
  
  static let ffmpepLogger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ffmpeg-kit")
  
  static func initFfmpegLogs() {
    
    FFmpegKitConfig.enableLogCallback { log in
      // Note: if we find logs from various ffmpeg processes confusing, we can also log session ID with log!.getSessionId()
      
      switch log!.getLevel() {
      case 24: // LevelAVLogWarning
        ffmpepLogger.warning("\(log!.getMessage()!)")
      case 32: // LevelAVLogInfo
        ffmpepLogger.info("\(log!.getMessage()!)")
      case 16: // LevelAVLogError
        ffmpepLogger.error("\(log!.getMessage()!)")
      case 8, 0: // LevelAVLogFatal, LevelAVLogPanic
        ffmpepLogger.critical("\(log!.getMessage()!)")
      default:
        ffmpepLogger.log("\(log!.getMessage()!)")
      }
    }
  }
}

@available(macOS 12.0, *)
func getLogEntries() throws -> [OSLogEntryLog] {
  // Open the log store.
  let logStore = try OSLogStore(scope: .currentProcessIdentifier)
  
  // Get all the logs from the last hour.
  let oneHourAgo = logStore.position(date: Date().addingTimeInterval(-3600))
  
  // Fetch log objects.
  let allEntries = try logStore.getEntries(at: oneHourAgo)
  
  // Filter the log to be relevant for our specific subsystem
  // and remove other elements (signposts, etc).
  return allEntries
    .compactMap { $0 as? OSLogEntryLog }
    .filter { $0.subsystem == subsystem }
}
