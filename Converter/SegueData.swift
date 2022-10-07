//
//  SegueData.swift
//  Converter
//
//  Created by Justin Bush on 10/3/22.
//

import Cocoa

enum WindowSegues: String, CaseIterable {
  case showReportError
  case showContact
}

extension ViewController {
  
  func segueToErrorReport(ffmpegCommand: String, ffmpegSessionLogs: String, ffprobeOutput: String, inputFilePath: String, outputFilePath: String) {
    DraftError.ffmpegCommand = ffmpegCommand
    DraftError.ffprobeOutput = ffprobeOutput
    DraftError.ffmpegSessionLogs = ffmpegSessionLogs
    DraftError.inputFilePath = inputFilePath
    DraftError.outputFilePath = outputFilePath
    segue(.showReportError)
  }
  
  func segue(_ segue: WindowSegues) {
    performSegue(withIdentifier: segue.rawValue, sender: self)
  }
  
  // Called when NSStoryboard Segue occurs from ViewController
  override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
    
    // Called upon window segue showReportError
    if (segue.identifier == WindowSegues.showReportError.rawValue) {
      if let reportErrorWC = segue.destinationController as? ReportErrorWindowController {
        reportErrorWC.passErrorData(ffmpegCommand: DraftError.ffmpegCommand, ffmpegSessionLogs: DraftError.ffmpegSessionLogs, ffprobeOutput: DraftError.ffprobeOutput, inputFilePath: DraftError.inputFilePath, outputFilePath: DraftError.outputFilePath)
      }
    }
    
  }
  
  struct DraftError {
    static var ffmpegCommand = ""
    static var ffmpegSessionLogs = ""
    static var ffprobeOutput = ""
    static var inputFilePath = ""
    static var outputFilePath = ""
  }
  
}
