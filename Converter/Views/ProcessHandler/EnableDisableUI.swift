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
  func enableUi() {
    enableAllOnScreenElements()   // Set isEnabled state of individual UI elements
    enableDragDropView()          // Custom DragDropView handling for enabled state
    hideProcessLoaderAnimation()  // Hide processLoader and stop animation
    Logger.debug("UI enabled")
  }
  /// Disable all UI elements. Show process loader with animation state.
  /// Call `disableUi(withLoaderAnimation: true)` to also show the process loader animation.
  func disableUi(withLoaderAnimation: Bool = false) {
    disableAllOnScreenElements()  // Set isEnabled state of individual UI elements
    disableDragDropView()         // Custom DragDropView handling for disabled state
    // Show process loader by default, with option to disable without animation
    if withLoaderAnimation { showProcessLoaderAnimation() }
    Logger.debug("UI disabled")
  }
  /// For while conversion is ongoing: Disable all on-screen elements except for the "Stop" action button (including import files via File -> Open in the menu bar)
  func disableUi(forConversion: Bool) {
    disableAllOnScreenElements(excludingActionButton: forConversion)
    disableDragDropView()
    Logger.debug("UI disabled")
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
    appDelegate.enableOpenFileMenuItem()  // Enable File > Open...
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
    appDelegate.disableOpenFileMenuItem() // Disable File > Open...
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
  func disableAllOnScreenElements(excludingActionButton: Bool = false) {
    let isEnabled = false
    formatDropdown.isEnabled = isEnabled
    actionButton.isEnabled = excludingActionButton
    helpInfoButton.isEnabled = isEnabled
    expandCollapsePremiumViewButton.isEnabled = isEnabled
    // PremiumView elements
    codecDropdown.isEnabled = isEnabled
    qualityDropdown.isEnabled = isEnabled
    // Hide Popovers
    hideAllUiPopovers()
  }
  
}
