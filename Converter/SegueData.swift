//
//  SegueData.swift
//  Converter
//
//  Created by Justin Bush on 10/3/22.
//

import Cocoa

enum WindowSegues: String, CaseIterable {
  case showReportError
  case showContact
  case sheetPurchasePremium
}

extension ViewController {
  
  func segueToErrorReport(inputVideos: [Video]) {
    DraftError.inputVideos = inputVideos
    segue(.showReportError)
  }
  
  func segue(_ segue: WindowSegues) {
    performSegue(withIdentifier: segue.rawValue, sender: self)
  }
  
  // Called when NSStoryboard Segue occurs from ViewController
  override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
    
    // Called upon window segue showReportError
    if (segue.identifier == WindowSegues.showReportError.rawValue) {
      if let reportErrorWC = segue.destinationController as? ReportErrorWindowController {
        reportErrorWC.passErrorData(inputVideos: DraftError.inputVideos)
      }
    }
    
  }
  
  struct DraftError {
    static var inputVideos: [Video] = []
  }
  
}
