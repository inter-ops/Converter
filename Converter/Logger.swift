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

struct Logger {
  private static let subsystem = Bundle.main.bundleIdentifier!
  
  @available(macOS 11.0, *)
  private static let applicationLogger = os.Logger(subsystem: subsystem, category: "application")
  
  @available(macOS 11.0, *)
  private static let ffmpepLogger = os.Logger(subsystem: subsystem, category: "ffmpeg-kit")
  
  static func initFfmpegLogs() {
    FFmpegKitConfig.enableLogCallback { log in
      // We dont log anything if we're in debug mode since this crowds the console.
      if Config.shared.debug {
        return
      }
      
      if #available(macOS 11.0, *) {
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
  
  static func debug(_ message: String) {
    if #available(macOS 11.0, *) {
      applicationLogger.debug("\(message)")
    }
    else {
      print("[Info] \(message)")
    }
  }
  
  static func info(_ message: String) {
    if #available(macOS 11.0, *) {
      applicationLogger.info("\(message)")
    }
    else {
      print("[Info] \(message)")
    }
  }

  static func warning(_ message: String) {
    if #available(macOS 11.0, *) {
      applicationLogger.warning("\(message)")
    }
    else {
      print("[Warning] \(message)")
    }
  }
  
  static func error(_ message: String) {
    if #available(macOS 11.0, *) {
      applicationLogger.error("\(message)")
    }
    else {
      print("[Error] \(message)")
    }
  }
  
  static func getLogEntries() -> [OSLogEntryLog] {
    do {
    // Open the log store.
//    let logStore = OSLogStore.init()
      var logStore: OSLogStore
      
      // TODO: Find a way to use in earlier platforms
    if #available(macOS 12.0, *) {
      logStore = try OSLogStore(scope: .currentProcessIdentifier)
    } else {
      return []
    }
    
    // TODO: Fine tune
    
    // Get all the logs from the last hour.
    let oneHourAgo = logStore.position(date: Date().addingTimeInterval(-3600))
    
    // Fetch log objects.
   
      let allEntries = try logStore.getEntries(at: oneHourAgo)
      
//      print("ENTRIES \(applicationLogs[0].components)") // TODO: Join by string
      
      // Filter the log to be relevant for our specific subsystem
      // and remove other elements (signposts, etc).
      return allEntries
        .compactMap { $0 as? OSLogEntryLog }
        .filter { $0.subsystem == subsystem }
    } catch {
      // TODO: Report error, should never get here
      return []
    }
  }

}
