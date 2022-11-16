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
  
  struct API {
    static let contactFormUrl = "https://contact-form-u7kjuwr4da-uc.a.run.app"
    static let errorReportUrl = "https://error-report-u7kjuwr4da-uc.a.run.app"
  }
  
  struct Frame {
    static let mainViewWidth = CGFloat(350)
    static let mainViewHeight = CGFloat(370)
    static let expandedViewWidth = CGFloat(350) // 550
    static let expandedViewHeight = CGFloat(580)
  }
  
}

