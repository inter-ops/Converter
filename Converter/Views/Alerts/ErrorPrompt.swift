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
        
        let service = NSSharingService(named: NSSharingService.Name.composeEmail)
        service?.recipients = ["hello@airtv.io"]
        service?.subject = "Help: Video Converter Error"
        service?.perform(withItems: ["[Enter your message here]\n\n", "----------------------------------------------------\nDO NOT EDIT THE SECTION BELOW\n----------------------------------------------------\n\n", "Error message:\n\n\(withMessage)\n\n",
                                     "FFProbe output:\n\n\(withFfprobeOutput)"])
      }
      if modalResponse == NSApplication.ModalResponse.alertSecondButtonReturn {
        print("User did dismiss error message")
        
      }
    })
  }
}
