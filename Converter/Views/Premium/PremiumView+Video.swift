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
    initQualityDropdownMenu(forCodec: format.defaultCodec)
  }
  func didSelectNewOutput(codec: VideoCodec) {
    initQualityDropdownMenu(forCodec: codec)
    outputCodec = codec
    Logger.info("User selected codec: \(codec.rawValue)")
    Logger.debug("New default quality selected: \(outputQuality.rawValue)")
  }
  /// Initialize dropdown menu with titles (see `VideoCodec.dropdownTitle` for values)
  func initCodecDropdownMenu(forFormat: VideoFormat) {
    let titles = getCodecDropdownTitles(forFormat: forFormat)
    codecDropdown.removeAllItems()
    codecDropdown.addItems(withTitles: titles)
    // Set new default output codec based on format
    outputCodec = forFormat.defaultCodec
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
    let titles = getQualityDropdownTitles(forCodec: forCodec)
    qualityDropdown.removeAllItems()
    qualityDropdown.addItems(withTitles: titles)
    // Set default selected item
    outputQuality = forCodec.defaultQuality
    let selectedItem = forCodec.defaultQuality
    qualityDropdown.selectItem(withTitle: selectedItem.dropdownTitle)
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
    Logger.info("User did select quality: \(quality.rawValue)")
  }
  
}
