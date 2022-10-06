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

struct Logger {

  static var applicationLogs: [String] = []
  
  // This func is the same as the commented out one below, but uses the temp array logger
  static func initFfmpegLogs() {
    FFmpegKitConfig.enableLogCallback { log in
      return
      // NOTE: The code below generates a ton of unnecessary logs, for now we won't worry about recording them since
      // we already capture the entire ffmpeg session logs for error reports. If we find this isn't enough, uncomment the code below
      
//      // We dont log anything if we're in debug mode since this crowds the console.
//      if Config.shared.debug {
//        return
//      }
//
//      let message = log!.getMessage()!.trimmingCharacters(in: .newlines)
//      let sessionId = log!.getSessionId()
//
//        // Note: if we find logs from various ffmpeg processes confusing, we can also log session ID with log!.getSessionId()
//      switch log!.getLevel() {
//      case 24: // LevelAVLogWarning
//        warning("[Session \(sessionId)] \(message)")
//      case 32: // LevelAVLogInfo
//        info("[Session \(sessionId)] \(message)")
//      case 16: // LevelAVLogError
//        error("[Session \(sessionId)] \(message)")
//      case 8, 0: // LevelAVLogFatal, LevelAVLogPanic
//        error("[Session \(sessionId)] \(message)")
//      default:
//        info("[Session \(sessionId)] \(message)")
//      }
    }
  }
  
  // Temp func to use until we have a real logger
  private static func log(_ message: String) {
    print(message)
    
    let dateString = Date().iso8601withFractionalSeconds
    applicationLogs.append("\(dateString) \(message)")
    
    // Ensure applicationLogs doesn't grow too large
    if applicationLogs.count > 10000 {
      applicationLogs.removeFirst()
    }
  }
  
  static func debug(_ message: String) {
//    if #available(macOS 11.0, *) {
//      applicationLogger.debug("\(message)")
//    }
//    else {
//      print("[Debug] \(message)")
//    }
    
    log("[Debug] \(message)")
  }
  
  static func info(_ message: String) {
//    if #available(macOS 11.0, *) {
//      applicationLogger.info("\(message)")
//    }
//    else {
//      print("[Info] \(message)")
//    }
    
    log("[Info] \(message)")
  }

  static func warning(_ message: String) {
//    if #available(macOS 11.0, *) {
//      applicationLogger.warning("\(message)")
//    }
//    else {
//      print("[Warning] \(message)")
//    }
    
    log("[Warning] \(message)")
  }
  
  static func error(_ message: String) {
//    if #available(macOS 11.0, *) {
//      applicationLogger.error("\(message)")
//    }
//    else {
//      print("[Error] \(message)")
//    }
    
    log("[Error] \(message)")
  }
  
  static func getLogsAsString() -> String {
    var logString = ""
    
    for log in applicationLogs {
      logString.append("\(log)\n")
    }
    
    return logString
  }
  
  // NOTE: Everything below is for logging with Logger and OSLog. Unfortunately OSLogStore requires MacOS 12, so for now we will use a simple logger.
  // We should instead replace this with a Logging package.
  
  // Resources
  // - https://steipete.com/posts/logging-in-swift/
  // - How to format a logger https://www.avanderlee.com/debugging/oslog-unified-logging/ https://www.lordcodes.com/articles/clear-and-searchable-logging-in-swift-with-oslog
  // - Overview of logging options: https://stackoverflow.com/questions/25951195/swift-print-vs-println-vs-nslog
  // FFMPEG kit overview (discusses logging): https://tanersener.medium.com/introduction-to-ffmpeg-kit-api-59623911fbfc
  
//  private static let subsystem = Bundle.main.bundleIdentifier!
//
//  @available(macOS 11.0, *)
//  private static let applicationLogger = os.Logger(subsystem: subsystem, category: "application")
//
//  @available(macOS 11.0, *)
//  private static let ffmpepLogger = os.Logger(subsystem: subsystem, category: "ffmpeg-kit")
//
//  static func initFfmpegLogs() {
//    FFmpegKitConfig.enableLogCallback { log in
//      // We dont log anything if we're in debug mode since this crowds the console.
//      if Config.shared.debug {
//        return
//      }
//
//      if #available(macOS 11.0, *) {
//        // Note: if we find logs from various ffmpeg processes confusing, we can also log session ID with log!.getSessionId()
//        switch log!.getLevel() {
//        case 24: // LevelAVLogWarning
//          ffmpepLogger.warning("[Session \(log!.getSessionId())] \(log!.getMessage()!)")
//        case 32: // LevelAVLogInfo
//          ffmpepLogger.info("[Session \(log!.getSessionId())] \(log!.getMessage()!)")
//        case 16: // LevelAVLogError
//          ffmpepLogger.error("[Session \(log!.getSessionId())] \(log!.getMessage()!)")
//        case 8, 0: // LevelAVLogFatal, LevelAVLogPanic
//          ffmpepLogger.critical("[Session \(log!.getSessionId())] \(log!.getMessage()!)")
//        default:
//          ffmpepLogger.log("[Session \(log!.getSessionId())] \(log!.getMessage()!)")
//        }
//      }
//    }
//  }
//
//  static func getLogEntries() -> [OSLogEntryLog] {
//    do {
//      // Open the log store.
//      var logStore: OSLogStore
//
//      // TODO: Find a way to use in earlier platforms https://mjtsai.com/blog/2021/12/10/oslogstore-on-monterey/
//      if #available(macOS 12.0, *) {
//        logStore = try OSLogStore(scope: .currentProcessIdentifier)
//      } else {
//        return []
//      }
//
//      // TODO: The one hour timestamp was chosen arbitrarily, think about what makes most sense here
//      let oneHourAgo = logStore.position(date: Date().addingTimeInterval(-3600))
//
//      // Fetch log objects.
//      let allEntries = try logStore.getEntries(at: oneHourAgo)
//
//      // Filter the log to be relevant for our specific subsystem
//      // and remove other elements (signposts, etc).
//      return allEntries
//        .compactMap { $0 as? OSLogEntryLog }
//        .filter { $0.subsystem == subsystem }
//    } catch {
//      // TODO: Report error, should never get here
//      return []
//    }
//  }
//
//  static func getAllEntriesAsString() -> String {
//    let allAppLogs = getLogEntries()
//    var logString = ""
//
//    for entryLog in allAppLogs {
//      logString.append("\(entryLog.composedMessage)\n")
//    }
//
//    return logString
//  }
}
