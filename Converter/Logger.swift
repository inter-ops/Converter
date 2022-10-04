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

// Next up: start testing out the logger to weed out implementation issues

let subsystem = Bundle.main.bundleIdentifier!

// TODO: Make available for older platforms
@available(macOS 11.0, *)
func ini() {
  
  let ffmpepLogger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "ffmpeg-kit")
  
  // TODO: If we want to simply take all print statemnts and send to a file, we should set alwaysPrintLogs and remove the enableLogcallback all together. Otherwise, we can capture all ffmpeg logs here, but silence them from being printed to main console and capture those separately.
  // See here for more info https://tanersener.medium.com/introduction-to-ffmpeg-kit-api-59623911fbfc
  //    FFmpegKitConfig.setLogRedirectionStrategy(.alwaysPrintLogs)
  FFmpegKitConfig.enableLogCallback { log in
    switch log!.getLevel() {
      case Level.avLogWarning:
        ffmpepLogger.warning("\(log!.getSessionId()): \(log!.getMessage()!)")
      case Level.avLogInfo:
        ffmpepLogger.info("\(log!.getSessionId()): \(log!.getMessage()!)")
      case Level.avLogError:
        ffmpepLogger.error("\(log!.getSessionId()): \(log!.getMessage()!)")
      case Level.avLogFatal, Level.avLogPanic:
        ffmpepLogger.critical("\(log!.getSessionId()): \(log!.getMessage()!)")
      default:
        ffmpepLogger.log("\(log!.getSessionId()): \(log!.getMessage()!)")
    }
  }
  
  // TODO: Expose this and replace all print statements with it.
  let applicationLogger = Logger(subsystem: subsystem, category: "application")
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
