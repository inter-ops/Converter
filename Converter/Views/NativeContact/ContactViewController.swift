//
//  ContactViewController.swift
//  Converter
//
//  Created by Justin Bush on 9/28/22.
//

import Cocoa

class ContactViewController: NSViewController, NSTextViewDelegate, NSTextFieldDelegate {
  
  @IBOutlet weak var nameField: NSTextField!
  @IBOutlet weak var emailField: NSTextField!
  @IBOutlet weak var topicDropdown: NSPopUpButton!
  @IBOutlet weak var messageField: NSTextView!
  @IBOutlet weak var noticeText: NSTextField!
  @IBOutlet weak var sendButton: NSButton!
  @IBOutlet weak var indeterminateProgressBar: NSProgressIndicator!
  
  let topics = ["Feedback", "Bug Report", "Feature Request", "Other"]
  
  let appDelegate = NSApplication.shared.delegate as! AppDelegate
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initTopicDropdownMenu()
    updateNotice(.hide)
    updateProgressBar(.hide)
    messageField.font = .systemFont(ofSize: NSFont.systemFontSize)
    
    nameField.delegate = self
    emailField.delegate = self
    messageField.delegate = self
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
    
    updateNotice(.hide)
  }
  
  func sendMessage(name: String, email: String, topic: String, message: String) {
    
    updateProgressBar(.show)
    
    API.contactForm(name: name, email: email, topic: topic, message: message) { responseData, errorMessage in
      
      if errorMessage != nil {
        self.updateNotice(withMessage: errorMessage!)
        self.updateProgressBar(.hide)   // Stop progressBar animation and enable all fields
        return
      }
      
      self.updateProgressBar(.hide) // Hide progressBar
      self.updateNotice(.sent)      // Update noticeText
      self.closeWindowWithSuccess() // Close window with success alert
    }
  }
  
  func updateProgressBar(_ display: ObjectDisplay) {
    switch display {
    case .hide:
      self.indeterminateProgressBar.isHidden = true
      self.indeterminateProgressBar.stopAnimation(self)
      enableAllFields()
    case .show:
      indeterminateProgressBar.isHidden = false
      indeterminateProgressBar.startAnimation(self)
      disableAllFields()
    }
  }
  
  func enableAllFields() {
    toggleFieldsAreEnabled(true)
  }
  
  func disableAllFields() {
    toggleFieldsAreEnabled(false)
    // Resign all fields on disable
    DispatchQueue.main.async {
      self.view.window?.makeFirstResponder(nil)
    }
  }
  
  func toggleFieldsAreEnabled(_ state: Bool) {
    nameField.isEnabled = state
    emailField.isEnabled = state
    topicDropdown.isEnabled = state
    if state { messageField.alphaValue = 1 }
    else { messageField.alphaValue = 0.3 }
    //messageField.isSelectable = state
    sendButton.isEnabled = state
  }
  
  var closeWindowWasCalled = false  // Ensure this function is only called once
  func closeWindowWithSuccess() {
    if !closeWindowWasCalled {
      closeWindowWasCalled = true
      DispatchQueue.main.async {
        self.view.window?.windowController?.close()
        self.appDelegate.bringMainWindowToFrontWithMessageDidSendAlert()
      }
    }
  }
  
  func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
    updateNotice(.hide)
    return true
  }
  
  func textDidBeginEditing(_ notification: Notification) {
    updateNotice(.hide)
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
