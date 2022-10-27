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
    
    mainViewWidthConstraint.animator().constant = Constants.Frame.expandedViewWidth
    mainViewHeightConstraint.animator().constant = Constants.Frame.expandedViewHeight
    
    // TODO: NSContextAnimator w/ CGFloat and CompletionHandler
    
    // expandDragDropView()
    
    expandablePremiumView.isHidden = false
  }
  
  func collapsePremiumView() {
    // expandCollapsePremiumViewButton.image = "ArrowDownIcon"
    
    mainViewWidthConstraint.animator().constant = Constants.Frame.mainViewWidth
    mainViewHeightConstraint.animator().constant = Constants.Frame.mainViewHeight
    
    // TODO: NSContextAnimator w/ CGFloat and CompletionHandler
    
    //collapseDragDropView()
    
    expandablePremiumView.isHidden = true
  }
  
  
  
}
