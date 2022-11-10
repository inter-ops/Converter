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
    initQualityDropdownMenu()
    
    if userDidPurchasePremium {
      enablePremiumView()
      
    } else {
      disablePremiumView()
      
    }
  }
  
  func enablePremiumView() {
    codecDropdown.isEnabled = true
    //gpuCheckbox.isEnabled = true
    //qualitySlider.isEnabled = true
    qualityDropdown.isEnabled = true
    copyAllAudioCheckbox.isEnabled = true
    copyAllSubtitlesCheckbox.isEnabled = true
    burnInSubtitleCheckbox.isEnabled = true
    burnInSubtitleDropdown.isEnabled = false // disable by default, until checkbox.state = .on
  }
  
  func disablePremiumView() {
    codecDropdown.isEnabled = false
    //gpuCheckbox.isEnabled = false
    //qualitySlider.isEnabled = false
    qualityDropdown.isEnabled = false
    copyAllAudioCheckbox.isEnabled = false
    copyAllSubtitlesCheckbox.isEnabled = false
    burnInSubtitleCheckbox.isEnabled = false
    burnInSubtitleDropdown.isEnabled = false
  }
  
  
  
  
  
  
  
}
