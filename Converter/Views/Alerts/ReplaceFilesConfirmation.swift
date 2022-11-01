//
//  ReplaceFilesConfirmation.swift
//  Converter
//
//  Created by Justin Bush on 11/1/22.
//

import Cocoa

extension ViewController {
  
  /// Prompt user for confirmation if they are replacing multi-file input
  func alertReplaceFilesConfirmation(filePaths: [String]) {
    let a = NSAlert()
    a.messageText = "Replace Files"
    a.informativeText = "You are about to replace all of your selected video files. Are you sure you wish to continue?"
    a.addButton(withTitle: "Replace")
    a.addButton(withTitle: "Cancel")
    a.alertStyle = NSAlert.Style.informational
    
    a.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
      if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
        Logger.debug("User did select: Replace selected files")
        self.dragDropViewDidReceive(filePaths: filePaths)
      }
      if modalResponse == NSApplication.ModalResponse.alertSecondButtonReturn {
        Logger.debug("User did select: Cancel replace files")
        // Do nothing
      }
    })
  }
  
}
