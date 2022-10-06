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
  
  var archiveDuplicate: [String] = []
  func sendMessage(name: String, email: String, additionalDetails: String, shouldSendAppLogs: Bool) {
    if archiveDuplicate == [name, email, additionalDetails] {
      // Don't send duplicate emails
    } else {
      archiveDuplicate = [name, email, additionalDetails]
      
      let reportedError = AppLogs.mostRecent
      var appLogs = ""
      
      if shouldSendAppLogs {
        for entry in AppLogs.currentSession {
          appLogs.append(entry)
        }
      }
      
      // TODO: These params should come from the caller of this modal
      // applicationLogs need to be stored manually. See here for implementation https://stackoverflow.com/questions/9097424/logging-data-on-device-and-retrieving-the-log/41741076#41741076

      API.errorReport(name: name, email: email, additionalDetails: additionalDetails, ffmpegCommand: "", ffmpegSessionLogs: "", ffprobeOutput: "", applicationLogs: "") { responseData, errorMessage in
        
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
