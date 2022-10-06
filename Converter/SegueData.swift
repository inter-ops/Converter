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
  
  func segueToErrorReport(errorMessage: String, ffprobeOutput: String, ffmpegCommand: String, inputExtension: String, outputExtension: String) {
    DraftError.sanitizedErrorMessage = errorMessage
    DraftError.sanitizedFfprobeOutput = ffprobeOutput
    DraftError.sanitizedFfmpegCommand = ffmpegCommand
    DraftError.inputExtension = inputExtension
    DraftError.outputExtension = outputExtension
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
        reportErrorWC.passErrorData(errorMessage: DraftError.sanitizedErrorMessage, ffprobeOutput: DraftError.sanitizedFfprobeOutput, ffmegCommand: DraftError.sanitizedFfmpegCommand, inExtension: DraftError.inputExtension, outExtension: DraftError.outputExtension)
      }
    }
    
  }
  
  struct DraftError {
    static var sanitizedErrorMessage = ""
    static var sanitizedFfprobeOutput = ""
    static var sanitizedFfmpegCommand = ""
    static var inputExtension = ""
    static var outputExtension = ""
  }
  
}
