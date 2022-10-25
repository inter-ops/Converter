//
//  ResizeViewHandler.swift
//  Converter
//
//  Created by Justin Bush on 10/24/22.
//

import Cocoa

extension ViewController {
  
  @IBAction func expandCollapsePremiumViewButtonAction(_ sender: NSButton) {
    toggleExpandCollapsePremiumView(self)
  }
  
  @IBAction func toggleExpandCollapsePremiumView(_ sender: Any?) {
    if premiumViewIsExpanded {
      collapsePremiumView()
      premiumViewIsExpanded = false
    } else {
      expandPremiumView()
      premiumViewIsExpanded = true
    }
  }
  
  func expandPremiumView() {
    // expandPremiumView(withAnimation:)
  }
  
  func collapsePremiumView() {
    // collapsePremiumView(withAnimation:)
  }
  
  
  
}
