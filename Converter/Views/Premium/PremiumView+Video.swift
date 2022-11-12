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
    initQualityDropdownMenu(forCodec: outputCodec)
  }
  func didSelectNewOutput(codec: VideoCodec) {
    outputCodec = codec
    initQualityDropdownMenu(forCodec: codec)
    Logger.info("User selected codec: \(codec.rawValue)")
  }
  /// Initialize dropdown menu with titles (see `VideoCodec.dropdownTitle` for values)
  func initCodecDropdownMenu(forFormat: VideoFormat) {
    let selectedCodecMenuItem = getUserSelectedCodec(fromTitle: codecDropdown.titleOfSelectedItem!)
    
    let titles = getCodecDropdownTitles(forFormat: forFormat)
    codecDropdown.removeAllItems()
    codecDropdown.addItems(withTitles: titles)
    
    setOrMaintainMenuItem(selectedCodec: selectedCodecMenuItem, forFormat: forFormat)
  }
  /// Sets new video codec menu items, but maintains the selection if compatible and appropriate (see ignoreDefaultCases).
  func setOrMaintainMenuItem(selectedCodec: VideoCodec, forFormat: VideoFormat) {
    // If user selected menu item is available with new format, maintain format
    if forFormat.compatibleCodecs.contains(selectedCodec) && ignoreDefaultCases(selectedCodec) {
      codecDropdown.selectItem(withTitle: selectedCodec.dropdownTitle)
      return
    }
    // Otherwise, set new default codec at selection index
    outputCodec = forFormat.defaultCodec
    codecDropdown.selectItem(withTitle: outputCodec.dropdownTitle)
    Logger.debug("New default codec selected: \(outputCodec.rawValue)")
  }
  /// Ignores specific edge cases for MPEG-4 and VP8 video codecs; ie.
  /// Switching from MKV (H.264) to WebM (VP8) and back would otherwise result in MKV (VP8) due to compatibility.
  func ignoreDefaultCases(_ selectedCodec: VideoCodec) -> Bool {
    let ignoredCases: [VideoCodec] = [.mpeg4, .vp8]
    if ignoredCases.contains(selectedCodec) {
      return false
    }
    return true
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
      if fromTitle == codec.dropdownTitle {
        return codec
      }
    }
    Logger.error("Unable to read selected codec type\nReturning default type: \(outputFormat.defaultCodec.rawValue)")
    return outputFormat.defaultCodec
  }
  /// Called when the user updates dropdown selection item
  @IBAction func selectCodec(_ sender: NSPopUpButton) {
    let title = sender.titleOfSelectedItem!
    let codec = getUserSelectedCodec(fromTitle: title)
    didSelectNewOutput(codec: codec)
  }
  
  
  
  // MARK: - Video Quality
  
  /// Initialize dropdown menu with titles (see `VideoQuality.dropdownTitle` for values)
  func initQualityDropdownMenu(forCodec: VideoCodec) {
    let selectedQualityMenuItem = getUserSelectedQuality(fromTitle: qualityDropdown.titleOfSelectedItem!)
    
    let titles = getQualityDropdownTitles(forCodec: forCodec)
    qualityDropdown.removeAllItems()
    qualityDropdown.addItems(withTitles: titles)
    
    setOrMaintainMenuItem(selectedQuality: selectedQualityMenuItem, forCodec: forCodec)
  }
  /// Sets new video quality menu items, but maintains the selection if compatible.
  func setOrMaintainMenuItem(selectedQuality: VideoQuality, forCodec: VideoCodec) {
    // If user selected menu item is available with new format, maintain format
    if forCodec.qualityTypes.contains(selectedQuality) {
      qualityDropdown.selectItem(withTitle: selectedQuality.dropdownTitle)
      return
    }
    // Otherwise, set new default codec at selection index
    outputQuality = forCodec.defaultQuality
    qualityDropdown.selectItem(withTitle: outputQuality.dropdownTitle)
    Logger.debug("New default quality selected: \(outputQuality.rawValue)")
  }
  
  /// Return VideoQuality title strings as an array for dropdown presentation
  func getQualityDropdownTitles(forCodec: VideoCodec) -> [String] {
    var titles: [String] = []
    for quality in forCodec.qualityTypes {
      titles.append(quality.dropdownTitle)
    }
    return titles
  }
  /// Return VideoQuality type from dropdown item selection
  func getUserSelectedQuality(fromTitle: String) -> VideoQuality {
    for quality in VideoQuality.allCases {
      if fromTitle == quality.dropdownTitle {
        return quality
      }
    }
    Logger.error("Unable to read selected quality type\nReturning default type: \(outputCodec.defaultQuality.rawValue)")
    return outputCodec.defaultQuality
  }
  /// Called when the user updates dropdown selection item
  @IBAction func selectQuality(_ sender: NSPopUpButton) {
    let title = sender.titleOfSelectedItem!
    let quality = getUserSelectedQuality(fromTitle: title)
    outputQuality = quality
    Logger.info("User selected quality: \(quality.rawValue)")
  }
  
}
