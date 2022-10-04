//
//  ReportErrorViewController.swift
//  Converter
//
//  Created by Justin Bush on 9/28/22.
//

import Cocoa

struct AppLogs {
  static var currentSession = ["START SESSION"]
  static var mostRecent = ""
  
  static func add(_ entry: String) {
    currentSession.append(entry)
  }
}

class ReportErrorViewController: NSViewController, NSTextViewDelegate, NSTextFieldDelegate {
  
  @IBOutlet weak var nameField: NSTextField!
  @IBOutlet weak var emailField: NSTextField!
  @IBOutlet weak var messageField: NSTextView!
  @IBOutlet weak var appLogsCheckbox: NSButton!
  @IBOutlet weak var noticeText: NSTextField!
  @IBOutlet weak var sendButton: NSButton!
  @IBOutlet weak var indeterminateProgressBar: NSProgressIndicator!
  
  var sanitizedErrorMessage: String = ""
  var sanitizedFfprobeOutput: String = ""
  var sanitizedFfmpegCommand: String = ""
  var inputExtension: String = ""
  var outputExtension: String = ""
  
  let appDelegate = NSApplication.shared.delegate as! AppDelegate
  
  override func viewDidLoad() {
    super.viewDidLoad()
    updateNotice(.hide)
    updateProgressBar(.hide)
    messageField.font = .monospacedSystemFont(ofSize: 13, weight: .medium)
    
    nameField.delegate = self
    emailField.delegate = self
    messageField.delegate = self
  }
  
  func passErrorData(errorMessage: String, ffprobeOutput: String, ffmegCommand: String, inExtension: String, outExtension: String) {
    sanitizedErrorMessage = errorMessage
    sanitizedFfprobeOutput = ffprobeOutput
    sanitizedFfmpegCommand = ffmegCommand
    inputExtension = inExtension
    outputExtension = outExtension
  }
  
  @IBAction func sendButtonAction(_ sender: NSButton) {
    let name = nameField.stringValue
    let email = emailField.stringValue
    let additionalDetails = messageField.string
    let shouldSendAppLogs = appLogsCheckbox.state == .on
    
    let emailPattern = #"^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$"#
    let emailResult = email.range(of: emailPattern, options: .regularExpression)
    let isValidEmail = emailResult != nil
    
    if !isValidEmail {
      updateNotice(.validEmail)
    } else {
      sendMessage(name: name, email: email, additionalDetails: additionalDetails, shouldSendAppLogs: shouldSendAppLogs)
    }
    
    updateNotice(.hide)
  }
  
  func sendMessage(name: String, email: String, additionalDetails: String, shouldSendAppLogs: Bool) {
    // TODO: Application Logs:
    // applicationLogs need to be stored manually. See here for implementation https://stackoverflow.com/questions/9097424/logging-data-on-device-and-retrieving-the-log/41741076#41741076
    
    updateProgressBar(.show)
    
    API.errorReport(name: name, email: email, errorMessage: sanitizedErrorMessage, additionalDetails: additionalDetails, ffprobeOutput: sanitizedFfprobeOutput, applicationLogs: "") { responseData, errorMessage in
      
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
  }
  
  func toggleFieldsAreEnabled(_ state: Bool) {
    nameField.isEnabled = state
    emailField.isEnabled = state
    appLogsCheckbox.isEnabled = state
    if state { messageField.alphaValue = 1 }
    else { messageField.alphaValue = 0.3 }
    messageField.isSelectable = state
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
      case .sent: return "Error report sent!"
      case .allRequired: return "All fields are required"
      case .validEmail: return "Please provide a valid email that we can reach you at"
      }
    }
  }
  
}
