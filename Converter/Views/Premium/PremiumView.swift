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
  
  // MARK: Update UI
  
  
  // MARK: Codecs
  /// Updates PremiumView with updated options per output format (ie. update codec dropdown list with available codecs)
  func didSelectNewOutput(format: VideoFormat) {
    //if isPremiumEnabled {
      initCodecDropdownMenu(forFormat: format)
    //}
  }
  /// Initialize dropdown menu with titles (see `VideoCodec.dropdownTitle` for values)
  func initCodecDropdownMenu(forFormat: VideoFormat) {
    codecDropdown.removeAllItems()
    codecDropdown.addItems(withTitles: getCodecDropdownTitles(forFormat: forFormat))
    
    // Set new default output codec based on format
    outputCodec = forFormat.compatibleCodecs[0]
    userSelectedCodecType = outputCodec
    
    Logger.info("New default codec selected: \(outputCodec.rawValue)")
  }
  /// Return VideoCodec title strings as an array for dropdown presentation
  func getCodecDropdownTitles(forFormat: VideoFormat) -> [String] {
    codecTitles = []  // clear all codec types
    for codec in forFormat.compatibleCodecs {
      codecTitles.append(codec.dropdownTitle)
    }
    return codecTitles
  }
  
  /// Return VideoCodec type from dropdown item selection
  func getUserSelectedCodec(_ item: String) -> VideoCodec {
    for codec in VideoCodec.allCases {
      if item == codec.dropdownTitle {
        return codec
      }
    }
    Logger.error("Unable to read selected format type\nReturning default type: VideoCodec.h264")
    return .h264
  }
  
  /// Returns VideoCodec type upon user dropdown selection (ie. `.h264`)
  func userDidSelectCodec(_ codec: VideoCodec) {
    // Update outputFormat to selected item
    outputCodec = codec
    
    Logger.info("User did select codec: \(codec.rawValue)")
    
  }
  
  /// Called when the user updates dropdown selection item
  @IBAction func selectCodec(_ sender: NSPopUpButton) {
    userSelectedCodec = sender.titleOfSelectedItem!
    userSelectedCodecType = getUserSelectedCodec(userSelectedCodec)
    // Handler function
    userDidSelectCodec(userSelectedCodecType)
  }
  
}
