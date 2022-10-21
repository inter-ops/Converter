//
//  PremiumView.swift
//  Converter
//
//  Created by Justin Bush on 10/21/22.
//

import Cocoa

extension ViewController {
  
  /// Initialize dropdown menu with titles (see `VideoFormat.dropdownTitle` for values)
  func initCodecDropdownMenu(forFormat: VideoFormat) {
    codecDropdown.removeAllItems()
    codecDropdown.addItems(withTitles: getCodecDropdownTitles(format: forFormat))
  }
  
  
  /// Return VideoFormat title strings as an array for dropdown presentation
  func getCodecDropdownTitles(format: VideoFormat) -> [String] {

    for codec in format.compatibleCodecs {
      codecTitles.append(codec.dropdownTitle)
    }
    
    return codecTitles
  }
  
}
