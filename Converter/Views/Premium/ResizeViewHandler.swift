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
    } else {
      expandPremiumView()
    }
    updateDragDropView(dragDropBoxStyleState)
  }
  
  func expandPremiumView() {
    premiumViewIsExpanded = true
    
    expandCollapsePremiumViewButton.image = NSImage(named: "Chevron-Up")
    
    mainViewWidthConstraint.animator().constant = Constants.Frame.expandedViewWidth
    mainViewHeightConstraint.animator().constant = Constants.Frame.expandedViewHeight
    
    expandablePremiumView.animator().isHidden = false
    
    checkAndShowPurchasePremium()
  }
  
  func collapsePremiumView() {
    premiumViewIsExpanded = false
    
    expandCollapsePremiumViewButton.image = NSImage(named: "Chevron-Down")
    
    mainViewWidthConstraint.animator().constant = Constants.Frame.mainViewWidth
    mainViewHeightConstraint.animator().constant = Constants.Frame.mainViewHeight
    
    expandablePremiumView.animator().isHidden = true
  }
  
  /// Collapse PremiumView if currently expanded
  func collapsePremiumIfExpanded() {
    if premiumViewIsExpanded {
      collapsePremiumView()
    }
  }
  
  
  
}
