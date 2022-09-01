//
//  AppDelegate.swift
//  Converter
//
//  Created by Justin Bush on 8/12/22.
//

import Cocoa

let debug = true

@main
class AppDelegate: NSObject, NSApplicationDelegate {

  var mainWindow: NSWindow!

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Insert code here to initialize your application
    mainWindow = NSApplication.shared.windows[0]
    NSApp.activate(ignoringOtherApps: true)
  }
  
  // Handles Reopening of Main Window
  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    if !flag {
      for window in sender.windows {
        window.makeKeyAndOrderFront(self)
      }
    }
    return true
  }
  // Handles the dropping of a video file onto the App icon
  func application(_ sender: NSApplication, openFile filename: String) -> Bool {
    let viewController = self.mainWindow.contentViewController as? ViewController
    viewController?.openFileFrom(filename)
    
    return true
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }


}

