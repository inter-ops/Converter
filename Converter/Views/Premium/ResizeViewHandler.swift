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
    // expandCollapsePremiumViewButton.image = "ArrowUpIcon"
    
    mainViewWidthConstraint.animator().constant = 600
    mainViewHeightConstraint.animator().constant = 600
    
    // TODO: NSContextAnimator w/ CGFloat and CompletionHandler
    
    // expandDragDropView()
  }
  
  func collapsePremiumView() {
    // expandCollapsePremiumViewButton.image = "ArrowDownIcon"
    
    mainViewWidthConstraint.animator().constant = 350
    mainViewHeightConstraint.animator().constant = 334
    
    // TODO: NSContextAnimator w/ CGFloat and CompletionHandler
    
    //collapseDragDropView()
  }
  
  
  
}
