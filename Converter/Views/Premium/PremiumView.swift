//
//  PremiumView.swift
//  Converter
//
//  Created by Justin Bush on 10/21/22.
//

import Cocoa

extension ViewController {
  
  func initPremiumView() {
    
    collapsePremiumView()
    didSelectNewOutput(format: outputFormat)  // Set default codec on launch based on default output format
    
    if userDidPurchasePremium {
      enablePremiumView()
      
    } else {
      disablePremiumView()
      
    }
  }
  
  func enablePremiumView() {
    codecDropdown.isEnabled = true
    qualityDropdown.isEnabled = true
  }
  
  func disablePremiumView() {
    codecDropdown.isEnabled = false
    qualityDropdown.isEnabled = false
  }
  
  
  
  
  
  
  
}
