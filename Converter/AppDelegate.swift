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
    /// If the app has no visible windows, present `mainWindow`
    if !flag {
      mainWindow.makeKeyAndOrderFront(self)
    }
    return true
  }
  
  /// Flag to determine if mainWindow ViewController has loaded to the point of accepting call requests
  var mainViewHasAppeared = false
  /// String path of the input file, requested to be open with mainWindow ViewController, if applicable
  var openAppWithFilePath: String? = nil
  /// Handles the opening of the app with an input file, see below
  ///
  /// Called regardless of the application's current status (opened/closed) and includes, but is not limited to, such states:
  ///  * From Finder, right-click input file, `Open With... > [this application]`
  ///  * Dragging and dropping an input file onto the application icon in dock
  func application(_ sender: NSApplication, openFile filename: String) -> Bool {
    /// If the mainWindow ViewController has been loaded and is able to accept calls from AppDelegate
    if mainViewHasAppeared {
      /// Load the input file request and bring the mainWindow to front
      let viewController = mainWindow.contentViewController as? ViewController
      viewController?.dragDropViewDidReceive(fileUrl: filename)
      mainWindow.makeKeyAndOrderFront(self)
    } else {
      /// Otherwise, set the String path of the input file for handling by the mainWindow ViewController once it is ready
      openAppWithFilePath = filename
    }
    return true
  }

  ///Called upon application's request to terminate (ie. `App > Quit App`)
  func applicationWillTerminate(_ aNotification: Notification) {
    Logger.debug("Application is expected to terminate")
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
