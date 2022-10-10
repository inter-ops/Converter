//
//  AppMenu+Global.swift
//  Converter
//
//  Created by Justin Bush on 10/10/22.
//

import Cocoa

// MARK: Global Menu Items
// MainMenu items accessible from anywhere within the app (non-window specific)

extension AppDelegate {
  
  // MARK: - File Menu
  /// Presents to front `mainWindow` and calls `openFileBrowser()` from `ViewController`
  ///
  /// **MainMenu:** `File > Open...`
  @IBAction func openWindowFileMenu(_ sender: NSMenuItem) {
    mainWindow.makeKeyAndOrderFront(self)
    // Open File
    let viewController = mainWindow.contentViewController as? ViewController
    viewController?.openFileBrowser()
  }
  
  
  
  // MARK: - Window Menu
  /// Presents to front `mainWindow`
  ///
  /// **MainMenu:** `Window > Open Video Converter`
  @IBAction func openMainWindowMenu(_ sender: NSMenuItem) {
    mainWindow.makeKeyAndOrderFront(self)
  }
  
  
}
