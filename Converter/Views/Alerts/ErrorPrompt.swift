//
//  ErrorPrompt.swift
//  Converter
//
//  Created by Justin Bush on 9/2/22.
//

import Cocoa

extension ViewController {
  
  /// Alert user of an error that occured, with the option of forwarding to devs
  func alertErrorPrompt(withMessage: String, withFfprobeOutput: String) {
    let a = NSAlert()
    a.messageText = "An error occured"
    a.informativeText = "There was a problem converting your file. Would you like to send this error to the dev team?"
    a.addButton(withTitle: "Send")
    a.addButton(withTitle: "Dismiss")
    a.alertStyle = NSAlert.Style.critical
    
    a.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
      if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
        print("User did choose to send error message")
        
        let messageContents = "Please make sure to include the text file as an attachment, as well as any additional details that could help us to better understand what happened. We'll get back to you as soon as we can!\n\n\n\n"
        let txtFileContents = "\(ErrorLogHeaders.error)\(withMessage)\(ErrorLogHeaders.ffprobe)\(withFfprobeOutput)"
        
        let txtFile = self.writeTempTxtFile(txtFileContents)
        
        let service = NSSharingService(named: NSSharingService.Name.composeEmail)
        service?.recipients = ["hello@airtv.io"]
        service?.subject = "Help: Video Converter Error"
        service?.perform(withItems: [messageContents, txtFile])
      }
      if modalResponse == NSApplication.ModalResponse.alertSecondButtonReturn {
        print("User did dismiss error message")
        
      }
    })
  }
  
  func writeTempTxtFile(_ contents: String) -> URL {
    let url = FileManager.default.temporaryDirectory
      .appendingPathComponent("Error-log-\(UUID().uuidString)")
      .appendingPathExtension("txt")
    let string = contents
    try? string.write(to: url, atomically: true, encoding: .utf8)
    return url
  }
}

struct ErrorLogHeaders {
  
  static let error = """
######################
### ERROR CONTENTS ###
######################
\n\n
"""
  
  static let ffprobe = """
\n\n\n\n
######################
### FFPROBE OUTPUT ###
######################
\n\n
"""
  
}
