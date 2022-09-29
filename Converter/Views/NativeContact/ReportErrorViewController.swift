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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    updateNotice(.hide)
    messageField.font = .monospacedSystemFont(ofSize: 13, weight: .medium)
  }
  
  
  @IBAction func sendButtonAction(_ sender: NSButton) {
    let name = nameField.stringValue
    let email = emailField.stringValue
    let message = messageField.string
    let shouldSendAppLogs = appLogsCheckbox.state == .on
    
    let emailPattern = #"/^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/"#
    let emailResult = email.range(of: emailPattern, options: .regularExpression)
    let isValidEmail = emailResult != nil
    
    // TODO: Email Regex
    if !isValidEmail {    //if !email.contains("@") || !email.contains(".") {
      updateNotice(.validEmail)
    } else {
      sendMessage(name: name, email: email, message: message, shouldSendAppLogs: shouldSendAppLogs)
    }
  }
  
  var archiveDuplicate: [String] = []
  func sendMessage(name: String, email: String, message: String, shouldSendAppLogs: Bool) {
    if archiveDuplicate == [name, email, message] {
      // Don't send duplicate emails
    } else {
      archiveDuplicate = [name, email, message]
      // TODO: Send email
      let subject = "Video Converter: Error Report"
      let recipient = "\(name) (\(email))"
      let messageBody = "\(message)"
      
      let reportedError = AppLogs.mostRecent
      var appLogs = ""
      
      if shouldSendAppLogs {
        for entry in AppLogs.currentSession {
          appLogs.append(entry)
          appLogs.append("\n\n=====\n\n")
        }
      }
      
      // TODO: Send email
      
      print("SEND EMAIL\n---\nRecipient: \(recipient)\nSubject: \(subject)\nMessage: \(messageBody)\n---")
      print("ERROR:\n\(reportedError)\n---")
      if shouldSendAppLogs { print("ALL LOGS: \(appLogs)\n---") }
      
      // Uppdate notice text
      updateNotice(.sent)
    }
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
