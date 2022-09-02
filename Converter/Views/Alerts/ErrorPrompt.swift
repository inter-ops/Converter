//
//  ErrorPrompt.swift
//  Converter
//
//  Created by Justin Bush on 9/2/22.
//

import Cocoa

extension ViewController {
  
  /// Alert user of an error that occured, with the option of forwarding to devs
  func alertErrorPrompt(withMessage: String) {
    let a = NSAlert()
    a.messageText = "An error occured"
    a.informativeText = "There was a problem converting your file. Would you like to send this error to the dev team?"
    a.addButton(withTitle: "Send")
    a.addButton(withTitle: "Dismiss")
    a.alertStyle = NSAlert.Style.critical
    
    a.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
      if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
        print("User did choose to send error message")
        
        var errorMessage = withMessage.replacingOccurrences(of: " ", with: "%20")
        errorMessage = errorMessage.replacingOccurrences(of: "\n", with: "%0D%0A")
        
        if let url = URL(string: "mailto:hello@airtv.io?subject=Video%20Converter%20Error&body=Please%20include%20the%20following%20message:%0D%0A%0D%0A\(errorMessage)") {
          NSWorkspace.shared.open(url)
        }
      }
      if modalResponse == NSApplication.ModalResponse.alertSecondButtonReturn {
        print("User did dismiss error message")
        
      }
    })
    }
}
