//
//  AppMenu+Debug.swift
//  Converter
//
//  Created by Justin Bush on 10/10/22.
//

import Cocoa

// MARK: Debug Menu Items
// Debug menu items and function calls accessible from anywhere within the app (non-window specific)

extension AppDelegate {
  
  /// Sets the Debug menu's `isHidden` and `isEnabled` properties based on the current environment (see Configuration.swift)
  func initDebugMenu() {
    debugMenu.isHidden = !Config.shared.debug
    debugMenu.isEnabled = Config.shared.debug
  }
  
}
