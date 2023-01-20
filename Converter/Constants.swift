//
//  Constants.swift
//  Converter
//
//  Created by Francesco Virga on 2022-08-27.
//

import Foundation

struct Constants {
  static let progressUpdateInterval = 0.5
  
  static let estimatedTimeLabelText = "Estimated time remaining"
  static let estimatingTimeLabelText = "Estimating time remaining..."
  
  static let fileCountLimit = 100
  /// Input file buffer delay for NSApplication's `open urls` method (in seconds)
  static let inputFileFromSystemBufferDelay = 0.4
  
  struct API {
    static let contactFormUrl = "https://contact-form-u7kjuwr4da-uc.a.run.app"
    static let errorReportUrl = "https://error-report-u7kjuwr4da-uc.a.run.app"
    static let minimimAppVersionUrl = "https://get-minimum-app-version-string-u7kjuwr4da-uc.a.run.app"
  }
  
  struct Frame {
    static let mainViewWidth = CGFloat(350)
    static let mainViewHeight = CGFloat(370)
    static let expandedViewWidth = CGFloat(350) // 550
    static let expandedViewHeight = CGFloat(438) // 580
  }
  
  enum UDKeys: String {
    case appVersionWasFlaggedAsLowerThanRequired
  }
  
  // MARK: App Data
  static let appVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
  static let buildNumberString = Bundle.main.infoDictionary?["CFBundleVersion"]
  
  // MARK: URLs
  /// Deep link to open Video Converter on the Mac App Store
  static let appStoreUrl = "macappstore://apps.apple.com/us/app/video-converter/id1518836004"
  /// About Apple ProRes support page
  static let appleProResSupportUrl = "https://support.apple.com/en-us/HT202410"
  
}

