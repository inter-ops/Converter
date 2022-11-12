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
    initCodecDropdownMenu(forFormat: format)
  }
  /// Initialize dropdown menu with titles (see `VideoCodec.dropdownTitle` for values)
  func initCodecDropdownMenu(forFormat: VideoFormat) {
    codecDropdown.removeAllItems()
    codecDropdown.addItems(withTitles: getCodecDropdownTitles(forFormat: forFormat))
    // Set new default output codec based on format
    outputCodec = forFormat.compatibleCodecs[0]
    Logger.debug("New default codec selected: \(outputCodec.rawValue)")
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
  func getUserSelectedCodec(fromTitle: String) -> VideoCodec {
    for codec in VideoCodec.allCases {
      if title == codec.dropdownTitle {
        return codec
      }
    }
    Logger.error("Unable to read selected codec type\nReturning default type: VideoCodec.h264")
    return .h264
  }
  /// Called when the user updates dropdown selection item
  @IBAction func selectCodec(_ sender: NSPopUpButton) {
    let title = sender.titleOfSelectedItem!
    let codec = getUserSelectedCodec(fromTitle: title)
    outputCodec = codec
    Logger.info("User did select codec: \(codec.rawValue)")
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
  /// Return VideoQuality type from dropdown item selection
  func getUserSelectedQuality(fromTitle: String) -> VideoQuality {
    for quality in VideoQuality.allCases {
      if title == quality.dropdownTitle {
        return quality
      }
    }
    Logger.error("Unable to read selected quality type\nReturning default type: VideoQuality.balanced")
    return .balanced
  }
  /// Called when the user updates dropdown selection item
  @IBAction func selectQuality(_ sender: NSPopUpButton) {
    let title = sender.titleOfSelectedItem!
    let quality = getUserSelectedQuality(fromTitle: title)
    outputQuality = quality
    // Handler function
    Logger.info("User did select quality: \(quality.rawValue)")
  }
  
}
