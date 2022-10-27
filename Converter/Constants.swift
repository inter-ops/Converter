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
  
  struct API {
    static let contactFormUrl = "https://contact-form-u7kjuwr4da-uc.a.run.app"
    static let errorReportUrl = "https://error-report-u7kjuwr4da-uc.a.run.app"
  }
  
  struct Frame {
    static let mainViewWidth = CGFloat(350)
    static let mainViewHeight = CGFloat(370) //380 //320 //334
    static let expandedViewWidth = CGFloat(600)
    static let expandedViewHeight = CGFloat(600)
  }
  
}

