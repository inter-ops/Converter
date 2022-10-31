//
//  PremiumView+Video.swift
//  Converter
//
//  Created by Justin Bush on 10/28/22.
//

import Cocoa

extension ViewController {
  
  // MARK: Video Codecs
  
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
    Logger.error("Unable to read selected codec type\nReturning default type: VideoCodec.h264")
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
  
  
  
  // MARK: - Video Quality
  
  /// Initialize dropdown menu with titles (see `VideoQuality.dropdownTitle` for values)
  func initQualityDropdownMenu() {
    qualityDropdown.removeAllItems()
    qualityDropdown.addItems(withTitles: getQualityDropdownTitles())
    // Set middle item (balanced) as default selection
    qualityDropdown.selectItem(withTitle: VideoQuality.balanced.dropdownTitle)
  }
  /// Return VideoQuality title strings as an array for dropdown presentation
  func getQualityDropdownTitles() -> [String] {
    qualityTitles = []  // clear all quality types
    for quality in VideoQuality.allCases {
      qualityTitles.append(quality.dropdownTitle)
    }
    return qualityTitles
  }
  
  /// Returns VideoQuality type upon user dropdown selection (ie. `.balanced`)
  func userDidSelectQuality(_ quality: VideoQuality) {
    // Update outputQuality to selected item
    outputQuality = quality
    
    Logger.info("User did select quality: \(quality.rawValue)")
    
  }
  /// Return VideoQuality type from dropdown item selection
  func getUserSelectedQuality(_ item: String) -> VideoQuality {
    for quality in VideoQuality.allCases {
      if item == quality.dropdownTitle {
        return quality
      }
    }
    Logger.error("Unable to read selected quality type\nReturning default type: VideoQuality.balanced")
    return .balanced
  }
  /// Called when the user updates dropdown selection item
  @IBAction func selectQuality(_ sender: NSPopUpButton) {
    userSelectedQuality = sender.titleOfSelectedItem!
    userSelectedQualityType = getUserSelectedQuality(userSelectedQuality)
    // Handler function
    userDidSelectQuality(userSelectedQualityType)
  }
  
}
