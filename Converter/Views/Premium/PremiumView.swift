//
//  PremiumView.swift
//  Converter
//
//  Created by Justin Bush on 10/21/22.
//

import Cocoa

extension ViewController {
  
  func initPremiumView() {
    
    // TODO: Always start in collapsed
    collapsePremiumView()
    
    if isPremiumEnabled {
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
    burnInSubtitleDropdown.isEnabled = true
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
  
  /// Updates PremiumView with updated options per output format if premium
  func didSelectNewOutput(format: VideoFormat) {
    if isPremiumEnabled {
      initCodecDropdownMenu(forFormat: format)
    }
  }
  
  /// Initialize dropdown menu with titles (see `VideoFormat.dropdownTitle` for values)
  func initCodecDropdownMenu(forFormat: VideoFormat) {
    codecDropdown.removeAllItems()
    codecDropdown.addItems(withTitles: getCodecDropdownTitles(forFormat: forFormat))
  }
  
  
  /// Return VideoFormat title strings as an array for dropdown presentation
  func getCodecDropdownTitles(forFormat: VideoFormat) -> [String] {
    for codec in forFormat.compatibleCodecs {
      codecTitles.append(codec.dropdownTitle)
    }
    return codecTitles
  }
  
}
