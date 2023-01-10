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
    Logger.debug("User selected codec: \(codec.rawValue)")
    // Reinitialize ToolTips based on new codec selection
    initToolTips()
  }
  /// Initialize dropdown menu with titles (see `VideoCodec.dropdownTitle` for values)
  func initCodecDropdownMenu(forFormat: VideoFormat) {
    let previouslySelectedCodec = getUserSelectedCodec(fromTitle: codecDropdown.titleOfSelectedItem!)
    
    let titles = getCodecDropdownTitles(forFormat: forFormat)
    codecDropdown.removeAllItems()
    codecDropdown.addItems(withTitles: titles)
    
    setOutputCodec(forFormat: forFormat, previouslySelectedCodec: previouslySelectedCodec)
  }
  /// Sets new video codec menu items, but maintains the selection if compatible and appropriate (see ignoreDefaultCases).
  func setOutputCodec(forFormat: VideoFormat, previouslySelectedCodec: VideoCodec) {
    // If the previously selected codec is also available for the new format, keep option selected.
    if shouldUseSameCodec(forFormat, previouslySelectedCodec) {
      codecDropdown.selectItem(withTitle: previouslySelectedCodec.dropdownTitle)
      return
    }
    // Otherwise, set codec to auto
    outputCodec = .auto
    codecDropdown.selectItem(withTitle: outputCodec.dropdownTitle)
    Logger.debug("New default codec selected: \(outputCodec.rawValue)")
  }
  
  /// Determines whether we should keep the selected codec when switching to a new output format. For certain edge cases we never want to keep
  /// the selected codec  (when the codec is supported but not ideal to use for the format, e.g. WEBM -> MKV), and otherwise check that the selected codec is supported in the new output format.
  func shouldUseSameCodec(_ forFormat: VideoFormat, _ previouslySelectedCodec: VideoCodec) -> Bool {
    // We only keep MPEG4 if the new format is AVI, otherwise we want to switch to auto
    if previouslySelectedCodec == .mpeg4 && forFormat != .avi {
      return false
    }
    if previouslySelectedCodec == .vp8 && forFormat == .mkv {
      return false
    }
    
    return forFormat.compatibleCodecs.contains(previouslySelectedCodec)
  }
  
  /// Return VideoCodec title strings as an array for dropdown presentation
  func getCodecDropdownTitles(forFormat: VideoFormat) -> [String] {
    var titles: [String] = []
    for codec in forFormat.compatibleCodecs {
      titles.append(codec.dropdownTitle)
    }
    return titles
  }
  /// Return VideoCodec type from dropdown item selection
  func getUserSelectedCodec(fromTitle: String) -> VideoCodec {
    for codec in VideoCodec.allCases {
      if fromTitle == codec.dropdownTitle {
        return codec
      }
    }
    Logger.error("Unable to read selected codec type, returning .auto")
    return .auto
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
    
    setOutputQuality(selectedQuality: selectedQualityMenuItem, forCodec: forCodec)
  }
  /// Sets new video quality menu items, but maintains the selection if compatible.
  func setOutputQuality(selectedQuality: VideoQuality, forCodec: VideoCodec) {
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
    Logger.debug("User selected quality: \(quality.rawValue)")
  }
  
}
