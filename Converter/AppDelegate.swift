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
  
  // Explicitly-defined MenuBar items
  @IBOutlet weak var debugMenu: NSMenuItem!
  //weak var viewController: NSViewController?
  
  /// Called upon initial application launch
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    /// Set mainWindow as initial window presented
    mainWindow = NSApplication.shared.windows[0]
    NSApp.activate(ignoringOtherApps: true)
    /// Initialize Debug menu
    initDebugMenu()
    /// Initialize Logger
    Logger.initFfmpegLogs()
  }
  
  /// Called upon request to reactivate NSApp from an inactive state (ie. clicking the app from the dock)
  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    /// If the app has no visible windows, open `mainWindow`
    if !flag {
      mainWindow.makeKeyAndOrderFront(self)
    }
    return true
  }
  
  var mainViewHasAppeared = false
  var openAppWithFilePath: String? = nil
  // Handles the dropping of a video file onto the App icon
  func application(_ sender: NSApplication, openFile filename: String) -> Bool {
    // Checks to see if the mainView has initialized display
    if mainViewHasAppeared {
      let viewController = mainWindow.contentViewController as? ViewController
      viewController?.dragDropViewDidReceive(fileUrl: filename)
      mainWindow.makeKeyAndOrderFront(self)
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
  
  
  
  // Bring ViewController to front with success message
  func bringMainWindowToFrontWithMessageDidSendAlert() {
    mainWindow.makeKeyAndOrderFront(self)
    let viewController = mainWindow.contentViewController as? ViewController
    viewController?.messageDidSendAlert()
  }

  var contactWindowController: NSWindowController?
  func showContactWindow() {
    let viewController = mainWindow.contentViewController as? ViewController
    viewController?.hideHelpInfoPopover()
    let sb = NSStoryboard(name: "Main", bundle: nil)
    contactWindowController = sb.instantiateController(withIdentifier: "ContactWindowControllerID") as? NSWindowController
    contactWindowController?.showWindow(self)
  }
  
}
