//
//  HelpInfoViewController.swift
//  Converter
//
//  Created by Justin Bush on 8/30/22.
//

import Cocoa

class HelpInfoViewController: NSViewController {

  let appDelegate = NSApplication.shared.delegate as! AppDelegate
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
  }
  
  @IBAction func contactButtonAction(sender: NSButton) {
    print("Contact button was clicked")
//    if let url = URL(string: "mailto:hello@airtv.io") {
//      NSWorkspace.shared.open(url)
//    }
    appDelegate.showContactWindow()
  }
  
}
