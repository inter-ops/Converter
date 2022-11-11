//
//  EnableDisableUI.swift
//  Converter
//
//  Created by Justin Bush on 11/11/22.
//

import Cocoa

extension ViewController {
  
  func enableUI() {
    let isEnabled = true
    formatDropdown.isEnabled = isEnabled
    actionButton.isEnabled = isEnabled
    helpInfoButton.isEnabled = isEnabled
    expandCollapsePremiumViewButton.isEnabled = isEnabled
    // PremiumView elements
    let isPremiumEnabled = userDidPurchasePremium
    codecDropdown.isEnabled = isPremiumEnabled
    qualityDropdown.isEnabled = isPremiumEnabled
    copyAllAudioCheckbox.isEnabled = isPremiumEnabled
    copyAllSubtitlesCheckbox.isEnabled = isPremiumEnabled
    burnInSubtitleCheckbox.isEnabled = isPremiumEnabled
    // Only enable subtitle dropdown if burn-in is selected
    _ = burnInSubtitles // var burnInSubtitles handles dropdown based on current state
    // Custom DragDropView handling
    enableDragDropView()
  }
  
  func disableUI() {
    let isEnabled = false
    formatDropdown.isEnabled = isEnabled
    actionButton.isEnabled = isEnabled
    helpInfoButton.isEnabled = isEnabled
    expandCollapsePremiumViewButton.isEnabled = isEnabled
    // PremiumView elements
    codecDropdown.isEnabled = isEnabled
    qualityDropdown.isEnabled = isEnabled
    copyAllAudioCheckbox.isEnabled = isEnabled
    copyAllSubtitlesCheckbox.isEnabled = isEnabled
    burnInSubtitleCheckbox.isEnabled = isEnabled
    // Custom DragDropView handling
    disableDragDropView()
  }
  
  func enableDragDropView() {
    let isEnabled = true
    clearInputFileButton.isEnabled = isEnabled
    showInputFilesButton.isEnabled = isEnabled
    
    // TODO: Hide dark overlay, enable input files
  }
  
  func disableDragDropView() {
    let isEnabled = false
    clearInputFileButton.isEnabled = isEnabled
    showInputFilesButton.isEnabled = isEnabled
    
    // TODO: Show dark overlay, disable input files
  }
  
}
