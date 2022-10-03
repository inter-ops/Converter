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
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    self.window?.delegate = self
  }
  
  func passErrorData(errorMessage: String, ffprobeOutput: String, ffmegCommand: String, inExtension: String, outExtension: String) {
    let viewController = window?.contentViewController as? ReportErrorViewController
    viewController?.passErrorData(errorMessage: errorMessage, ffprobeOutput: ffprobeOutput, ffmegCommand: ffmegCommand, inExtension: inExtension, outExtension: outExtension)
  }
  
}
