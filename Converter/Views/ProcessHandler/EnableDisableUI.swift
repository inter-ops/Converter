//
//  EnableDisableUI.swift
//  Converter
//
//  Created by Justin Bush on 11/11/22.
//

import Cocoa

extension ViewController {
  /// Enable all free UI elements, with Premium elements dependent on `userDidPurchasePremium`.
  /// Additionally, hide any process loaders and stop ongoing animations.
  func enableUI() {
    enableAllOnScreenElements()   // Set isEnabled state of individual UI elements
    enableDragDropView()          // Custom DragDropView handling for enabled state
    hideProcessLoaderAnimation()  // Hide processLoader and stop animation
  }
  /// Disable all UI elements. Show process loader with animation state.
  /// Call `disableUI(withLoaderAnimation: true)` to also show the process loader animation.
  func disableUI(withLoaderAnimation: Bool = false) {
    disableAllOnScreenElements()  // Set isEnabled state of individual UI elements
    disableDragDropView()         // Custom DragDropView handling for disabled state
    // Show process loader by default, with option to disable without animation
    if withLoaderAnimation { showProcessLoaderAnimation() }
  }
  /// Enable associated `DragDropView` elements, with title textColors to match enabled state.
  func enableDragDropView() {
    let isEnabled = true
    clearInputFileButton.isEnabled = isEnabled
    showInputFilesButton.isEnabled = isEnabled
    dragDropIconImageView.isEnabled = isEnabled
    dragDropBackgroundImageView.isEnabled = isEnabled
    dragDropTopTitle.textColor = .textColor
    dragDropBottomTitle.textColor = .textColor
    
    // TODO: Enable global input files
  }
  /// Disable associated `DragDropView` elements, with title textColors to match disabled state.
  func disableDragDropView() {
    let isEnabled = false
    clearInputFileButton.isEnabled = isEnabled
    showInputFilesButton.isEnabled = isEnabled
    dragDropIconImageView.isEnabled = isEnabled
    dragDropBackgroundImageView.isEnabled = isEnabled
    dragDropTopTitle.textColor = .disabledControlTextColor
    dragDropBottomTitle.textColor = .disabledControlTextColor
    
    // TODO: Disable global input files
  }
  /// Set the `isEnabled = true` state of all applicable UI elements.
  func enableAllOnScreenElements() {
    let isEnabled = true
    formatDropdown.isEnabled = isEnabled
    actionButton.isEnabled = isEnabled
    helpInfoButton.isEnabled = isEnabled
    expandCollapsePremiumViewButton.isEnabled = isEnabled
    // PremiumView elements
    let isPremiumEnabled = userDidPurchasePremium
    codecDropdown.isEnabled = isPremiumEnabled
    qualityDropdown.isEnabled = isPremiumEnabled
  }
  /// Set the `isEnabled = false` state of all UI elements.
  func disableAllOnScreenElements() {
    let isEnabled = false
    formatDropdown.isEnabled = isEnabled
    actionButton.isEnabled = isEnabled
    helpInfoButton.isEnabled = isEnabled
    expandCollapsePremiumViewButton.isEnabled = isEnabled
    // PremiumView elements
    codecDropdown.isEnabled = isEnabled
    qualityDropdown.isEnabled = isEnabled
    // Hide Popovers
    hideAllUiPopovers()
  }
  
}
