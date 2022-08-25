//
//  ConversionDidComplete.swift
//  Converter
//
//  Created by Justin Bush on 8/23/22.
//

import Cocoa

extension ViewController {
  
  /// Alert user of successful conversion output and display "Reveal in Finder" option
  func alertConversionDidComplete(withOutputPath: URL) {
    let a = NSAlert()
    a.messageText = "Conversion Complete"
    a.informativeText = "Your video file has been converted successfully!"
    a.addButton(withTitle: "OK")
    a.addButton(withTitle: "Reveal in Finder")
    a.alertStyle = NSAlert.Style.informational
    
    a.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
      if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
        print("User did acknowledge successful file conversion")
      }
      if modalResponse == NSApplication.ModalResponse.alertSecondButtonReturn {
        print("User did select: Reveal in Finder")
        self.showInFinder(url: withOutputPath)
      }
    })
  }
  
  /// Open Finder with selected file at designated `url`
  func showInFinder(url: URL?) {
    guard let url = url else { return }
    
    if url.isDirectory {
      NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
    } else {
      NSWorkspace.shared.activateFileViewerSelecting([url])
    }
  }
  
}

extension URL {
  /// Returns true if URL in question is a valid directory
  var isDirectory: Bool {
    return (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
  }
}
