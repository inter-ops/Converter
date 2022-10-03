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
  @IBOutlet weak var sendButton: NSButton!
  @IBOutlet weak var indeterminateProgressBar: NSProgressIndicator!
  
  let topics = ["Feedback", "Bug Report", "Feature Request", "Other"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initTopicDropdownMenu()
    updateNotice(.hide)
    updateProgressBar(.hide)
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
  
  func sendMessage(name: String, email: String, topic: String, message: String) {
    // TODO: Do we need a spinner / loader?
    
    self.updateProgressBar(.show)
    
    API.contactForm(name: name, email: email, topic: topic, message: message) { responseData, errorMessage in
      
      if errorMessage != nil {
        self.updateNotice(withMessage: errorMessage!)
        return
      }
      
      self.updateProgressBar(.hide) // Hide progressBar
      self.updateNotice(.sent)      // Update noticeText
      
      // TODO: Figure out post-async delay
      // Perhaps call closeWindow upon certain message?
      // if responceData == "success" { self.closeWindow() }
      //self.closeWindow()
    }
  }
  
  func updateProgressBar(_ display: ObjectDisplay) {
    switch display {
    case .hide:
      self.indeterminateProgressBar.isHidden = true
      self.indeterminateProgressBar.stopAnimation(self)
      disableAllFields(false)
    case .show:
      indeterminateProgressBar.isHidden = false
      indeterminateProgressBar.startAnimation(self)
      disableAllFields(true)
    }
  }
  
  func disableAllFields(_ state: Bool) {
    nameField.isEnabled = !state
    emailField.isEnabled = !state
    topicDropdown.isEnabled = !state
    messageField.isSelectable = !state
    if state { messageField.alphaValue = 0.3 }
    else { messageField.alphaValue = 1 }
    sendButton.isEnabled = !state
  }
  
  func closeWindow() {
    print("closeWindow() called")
    // Issues with calling both from async thread
    
    //    let _ = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { timer in
    //      self.view.window?.windowController?.close()
    //    }
    
    //    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    //      self.view.window?.windowController?.close()
    //    }
  }
  
  @IBAction func resetButtonAction(_ sender: NSButton) {
    nameField.stringValue = ""
    emailField.stringValue = ""
    messageField.string = ""
  }
  
  func updateNotice(withMessage: String) {
    noticeText.isHidden = false
    noticeText.textColor = .systemRed
    noticeText.stringValue = withMessage
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