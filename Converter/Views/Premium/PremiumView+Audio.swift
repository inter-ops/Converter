//
//  PremiumView+Audio.swift
//  Converter
//
//  Created by Justin Bush on 10/28/22.
//

import Cocoa

extension ViewController {
  
  /// Called when the user toggles the state of the copy all audio streams checkmark
  @IBAction func toggleCopyAllAudioCheckbox(_ sender: NSButton) {
    let checkboxState = sender.state
    Logger.info("Copy all audio streams: \(checkboxState.toString)")
  }
  
}
