//
//  ContactViewController.swift
//  Converter
//
//  Created by Justin Bush on 9/28/22.
//

import Cocoa

class ContactViewController: NSViewController, NSTextViewDelegate {
  
  @IBOutlet weak var nameField: NSTextField!
  @IBOutlet weak var emailField: NSTextField!
  @IBOutlet weak var topicDropdown: NSPopUpButton!
  @IBOutlet weak var messageField: NSTextView!
  @IBOutlet weak var noticeText: NSTextField!
  
  let topics = ["Feedback", "Bug Report", "Feature Request", "Other"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initTopicDropdownMenu()
    updateNotice(.hide)
    messageField.font = .systemFont(ofSize: NSFont.systemFontSize)
  }
  
  func initTopicDropdownMenu() {
    topicDropdown.removeAllItems()
    topicDropdown.addItems(withTitles: topics)
  }
  
  @IBAction func sendButtonAction(_ sender: NSButton) {
    let name = nameField.stringValue
    let email = emailField.stringValue
    let topic = topicDropdown.selectedItem!.title
    let message = messageField.string
    
    let emailPattern = #"^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$"#
    let emailResult = email.range(of: emailPattern, options: .regularExpression)
    let isValidEmail = emailResult != nil
    
    if name.isEmpty || email.isEmpty || message.isEmpty {
      updateNotice(.allRequired)
    } else if !isValidEmail {
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
      
      // TODO: Do we need a spinner / loader?
      
      API.contactForm(name: name, email: email, topic: topic, message: message) { responseData, errorMessage in
        
        if errorMessage != nil {
            // TODO: Show error message
          return
        }
        
        // Uppdate notice text
        self.updateNotice(.sent)
        // TODO: Clear contact form. That should also allow us to remove the archiveDuplicate logic
      }
    }
  }
  
  @IBAction func resetButtonAction(_ sender: NSButton) {
    nameField.stringValue = ""
    emailField.stringValue = ""
    messageField.string = ""
  }
  
  func updateNotice(_ status: NoticeToggle) {
    noticeText.isHidden = status.hidden
    noticeText.textColor = status.textColor
    noticeText.stringValue = status.textValue
  }
  
  
  // MARK: Notice Config
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
  
}
