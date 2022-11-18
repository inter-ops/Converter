//
//  AppDelegate.swift
//  Converter
//
//  Created by Justin Bush on 8/12/22.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

  /// WindowController.window used to handle and present ViewController
  var mainWindow: NSWindow!
  
  // MARK: - AppDelegate Methods
  
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
  /// Flag to determine if AppDelegate has already dispatched an input file queue to ViewController
  var didDispatchFileQueue = false
  /// String path of the input file, requested to be open with mainWindow ViewController, if applicable
  var openAppWithFilePaths: [String] = []
  /// Handles the opening of the app with multiple input files (see below).
  ///
  /// Called regardless of the application's current status (opened/closed) and includes, but is not limited to, such states:
  ///  * From Finder, right-click input file, `Open With... > [this application]`
  ///  * Dragging and dropping an input file onto the application icon in dock
  func application(_ application: NSApplication, open urls: [URL]) {
    // Append each url to openAppWithFilePaths as a String
    for url in urls {
      openAppWithFilePaths.append(url.path)
    }
    /// If the application has already initialized, and ViewController.didAppear, call function directly.
    /// Otherwise, let ViewController.didAppear handle function call (cannot init before this method; will crash).
    if mainViewHasAppeared {
      let viewController = mainWindow.contentViewController as? ViewController
      viewController?.queueImportFilesFromFinder()
      mainWindow.makeKeyAndOrderFront(self)
    }
  }
  
  /// Called upon application's request to terminate (ie. `App > Quit App`)
  func applicationWillTerminate(_ aNotification: Notification) {
    Logger.debug("Application is expected to terminate")
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
  
  
  
  // MARK: - AppMenu Items
  // Application MainMenu items that must be explicitly defined within AppDelegate
  
  /// **MainMenu:** `Debug`
  @IBOutlet weak var debugMenu: NSMenuItem!
  
  
  
  // MARK: - Global Functions
  
  /// Presents mainWindow ViewController as key window, then calls `messageDidSentAlert()`
  func bringMainWindowToFrontWithMessageDidSendAlert() {
    mainWindow.makeKeyAndOrderFront(self)
    let viewController = mainWindow.contentViewController as? ViewController
    viewController?.messageDidSendAlert()
  }
  
  /// Presents ContactWindow from the AppDelegate hierarchy and subsequentially dismisses the HelpInfo popover
  func showContactWindow() {
    let viewController = mainWindow.contentViewController as? ViewController
    viewController?.hideHelpInfoPopover()
    let sb = NSStoryboard(name: "Main", bundle: nil)
    let contactWindowController = sb.instantiateController(withIdentifier: "ContactWindowControllerID") as? NSWindowController
    contactWindowController?.showWindow(self)
  }
  
  
}
