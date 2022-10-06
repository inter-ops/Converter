//
//  MessageDidSend.swift
//  Converter
//
//  Created by Justin Bush on 10/4/22.
//

import Cocoa

extension ViewController {
  
  func messageDidSendAlert() {
    let a = NSAlert()
    a.messageText = "Message Sent"
    a.informativeText = "Your message was sent successfully!"
    a.addButton(withTitle: "OK")
    a.alertStyle = NSAlert.Style.informational
    
    a.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
      
      if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
        print("User did dismiss message")
        
      }
      
    })
  }
  
}
