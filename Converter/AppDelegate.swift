//
//  AppDelegate.swift
//  Converter
//
//  Created by Justin Bush on 8/12/22.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

  var mainWindow: NSWindow!
  @IBOutlet weak var debugMenu: NSMenuItem!

  @IBAction func openMainWindowMenu(_ sender: NSMenuItem) {
    mainWindow.makeKeyAndOrderFront(self)
  }
  
  @IBAction func openWindowFileMenu(_ sender: NSMenuItem) {
    mainWindow.makeKeyAndOrderFront(self)
    // Open File
    let viewController = self.mainWindow.contentViewController as? ViewController
    viewController?.openFileMenuItem()
  }
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Insert code here to initialize your application
    mainWindow = NSApplication.shared.windows[0]
    NSApp.activate(ignoringOtherApps: true)
    
    debugMenu.isHidden = !debug
    debugMenu.isEnabled = debug
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
  
  var openAppWithFilePath: String? = nil
  var mainViewHasAppeared = false
  
  // Handles the dropping of a video file onto the App icon
  func application(_ sender: NSApplication, openFile filename: String) -> Bool {
    // Checks to see if the mainView has initialized display
    if mainViewHasAppeared {
      let viewController = self.mainWindow.contentViewController as? ViewController
      viewController?.dragDropViewDidReceive(fileUrl: filename)
    } else {
      // Otherwise, set String flag for opening once mainView hasAppeared
      openAppWithFilePath = filename
    }
    return true
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }


}

// MARK: Preprocessor Debug
#if DEBUG
let debug = true
#else
let debug = false
#endif
