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

class ReportErrorViewController: NSViewController {
  
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    updateNotice(.hide)
    updateProgressBar(.hide)
    messageField.font = .monospacedSystemFont(ofSize: 13, weight: .medium)
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
  }
  
  func sendMessage(name: String, email: String, additionalDetails: String, shouldSendAppLogs: Bool) {
    // TODO: Application Logs:
    // applicationLogs need to be stored manually. See here for implementation https://stackoverflow.com/questions/9097424/logging-data-on-device-and-retrieving-the-log/41741076#41741076
    
    updateProgressBar(.show)
    
    API.errorReport(name: name, email: email, errorMessage: sanitizedErrorMessage, additionalDetails: additionalDetails, ffprobeOutput: sanitizedFfprobeOutput, applicationLogs: "") { responseData, errorMessage in
      
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
