//
//  ReportErrorWindowController.swift
//  Converter
//
//  Created by Justin Bush on 10/2/22.
//

import Cocoa

class ReportErrorWindowController: NSWindowController, NSWindowDelegate {
  
  override func windowDidLoad() {
    super.windowDidLoad()
    
    self.window?.delegate = self
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
//    print("Window sanitizedErrorMessage: \(String(describing: sanitizedErrorMessage))")
//    let viewController = window?.contentViewController as? ReportErrorViewController
//    viewController?.sanitizedErrorMessage = sanitizedErrorMessage
  }
  
  func passErrorData(errorMessage: String, ffprobeOutput: String, ffmegCommand: String, inExtension: String, outExtension: String) {
    let viewController = window?.contentViewController as? ReportErrorViewController
    viewController?.passErrorData(errorMessage: errorMessage, ffprobeOutput: ffprobeOutput, ffmegCommand: ffmegCommand, inExtension: inExtension, outExtension: outExtension)
  }
  
}
