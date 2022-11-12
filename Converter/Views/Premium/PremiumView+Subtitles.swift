//
//  PremiumView+Subtitles.swift
//  Converter
//
//  Created by Justin Bush on 10/28/22.
//

import Cocoa

extension ViewController {
  
  /// Called when the user toggles the state of the copy all subtitles checkmark
  @IBAction func toggleCopyAllSubtitlesCheckbox(_ sender: NSButton) {
    let checkboxState = sender.state
    Logger.info("Copy all subtitle streams: \(checkboxState.toString)")
  }
  
  /// Called when the user toggles the state of the burn-in subtitles checkmark
  @IBAction func selectBurnInSubtitlesCheckbox(_ sender: NSButton) {
    let checkboxState = sender.state
    if checkboxState == .on {
      burnInSubtitleDropdown.isEnabled = true
    } else {
      burnInSubtitleDropdown.isEnabled = false
    }
    Logger.info("Burn in subtitles: \(checkboxState.toString)")
  }
  /// Populate the dropdown with subtitle tracks
  func updateBurnInSubtitles(subtitleList: [String]) {
    burnInSubtitleDropdown.removeAllItems()
    burnInSubtitleDropdown.addItems(withTitles: subtitleList)
  }
  /// Return the title of the selected dropdown (should equal one of the String arrays of `updateBurnInSubtitles(subtitleList:)`)
  func getSelectedBurnInSubtitles() -> String {
    Logger.info("Burn in with selected subtitle: \(String(describing: burnInSubtitleDropdown.titleOfSelectedItem))")
    return burnInSubtitleDropdown.titleOfSelectedItem!
  }
  
}



extension NSControl.StateValue {
  /// Returns string value of NSControl StateValue (ie. `checkbox == .on, return "on"`)
  var toString: String {
    if self == .on { return "on" }
    else if self == .off { return "off" }
    else if self == .mixed { return "mixed" }
    else { return "unknown" }
  }
  
}
