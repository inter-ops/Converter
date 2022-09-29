//
//  ContactViewController.swift
//  Converter
//
//  Created by Justin Bush on 9/28/22.
//

import Cocoa

class ContactViewController: NSViewController, NSTextFieldDelegate {
  
  @IBOutlet weak var nameField: NSTextField!
  @IBOutlet weak var emailField: NSTextField!
  @IBOutlet weak var topicDropdown: NSPopUpButton!
  @IBOutlet weak var messageField: NSTextField!
  @IBOutlet weak var noticeText: NSTextField!
  
  let topics = ["Feedback", "Bug Report", "Feature Request", "Other"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initTopicDropdownMenu()
    updateNotice(.hide)
  }
  
  /// Initialize dropdown menu with titles (see `VideoFormat.dropdownTitle` for values)
  func initTopicDropdownMenu() {
    topicDropdown.removeAllItems()
    topicDropdown.addItems(withTitles: topics)
  }
  
  @IBAction func sendButtonAction(_ sender: NSButton) {
    let name = nameField.stringValue
    let email = emailField.stringValue
    let topic = topicDropdown.selectedItem!.title
    let message = messageField.stringValue
    
    if name.isEmpty || email.isEmpty || message.isEmpty {
      updateNotice(.allRequired)
    } else if !email.contains("@") || !email.contains(".") {
      updateNotice(.validEmail)
    } else {
      sendMessage(name: name, email: email, topic: topic, message: message)
    }
  }
  
  var archiveDuplicate: [String] = []
  func sendMessage(name: String, email: String, topic: String, message: String) {
    if archiveDuplicate == [name, email, topic, message] {
      // Don't send duplicate emails
    } else {
      archiveDuplicate = [name, email, topic, message]
      // Send email
      let subject = "Video Converter: \(topic)"
      let recipient = "\(name) (\(email))"
      let messageBody = "\(message)"
      
      print("SEND EMAIL\n---\nName: \(nameField.stringValue)\nEmail: \(emailField.stringValue)\nTopic: \(String(describing: topicDropdown.selectedItem!.title))\nMessage: \(messageField.stringValue)\n---")
      // Uppdate notice text
      updateNotice(.sent)
    }
  }
  
  @IBAction func resetButtonAction(_ sender: NSButton) {
    nameField.stringValue = ""
    emailField.stringValue = ""
    messageField.stringValue = ""
  }
  
  func updateNotice(_ status: NoticeToggle) {
    noticeText.isHidden = status.hidden
    noticeText.textColor = status.textColor
    noticeText.stringValue = status.textValue
  }
  
  enum NoticeToggle {
    case hide, sent, allRequired, validEmail
    
    var hidden: Bool {
      switch self {
      case .hide: return true
      case .sent: return false
      case .allRequired: return false
      case .validEmail: return false
      }
    }
    
    var textColor: NSColor {
      switch self {
      case .hide: return .textColor
      case .sent: return .textColor
      case .allRequired: return .systemRed
      case .validEmail: return .systemRed
      }
    }
    
    var textValue: String {
      switch self {
      case .hide: return ""
      case .sent: return "Message sent!"
      case .allRequired: return "All fields are required"
      case .validEmail: return "Please enter a valid email"
      }
    }
  }
  
  // MARK: Delegates
  // TextField delegate
  
  func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
    let event = NSApplication.shared.currentEvent
    if event?.type == .keyDown && event?.keyCode == 36 {
      self.stringValue = self.stringValue.stringByAppendingString("\n")
      return false
    } else {
      return true
    }
  }
  
  func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
    if commandSelector == #selector(NSStandardKeyBindingResponding.insertNewline(_:)) {
      // new line action:
      // always insert a line-break character and don’t cause the receiver to end editing
      textView.insertNewlineIgnoringFieldEditor(self)
      return true
    }
    return false
  }
  
//  override func textShouldEndEditing(textObject: NSText) -> Bool {
//    let event = NSApplication.sharedApplication().currentEvent
//    if event?.type == NSEventType.KeyDown && event?.keyCode == 36 {
//      self.stringValue = self.stringValue.stringByAppendingString("\n")
//      return false
//    } else {
//      return super.textShouldEndEditing(textObject)
//    }
//  }
  
}
