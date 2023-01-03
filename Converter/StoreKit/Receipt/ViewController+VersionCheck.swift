//
//  ViewController+VersionCheck.swift
//  Converter
//
//  Created by Justin Bush on 1/3/23.
//

import Cocoa

extension ViewController {
  
  var firebaseVersion: Double? {
    // TODO: Return Firebase variable if available:
    // if reachable { return Double value } else { return nil }
    return nil
  }
  
  func firebaseVersionCheck() {
    if let latestRequiredVersion = firebaseVersion {
      if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? Double {
        Logger.debug("App Version: \(appVersion) vs. Latest Version: \(latestRequiredVersion)")
        if appVersion < latestRequiredVersion {
          disableUiAndShowLatestVersionAlert()
        }
      }
    }
  }
  
  func disableUiAndShowLatestVersionAlert() {
    disableUI()
    showLatestVersionAlert()
  }
  
  func showLatestVersionAlert() {
    let a = NSAlert()
    a.messageText = "New Version Available"
    a.informativeText = "Please update Video Converter to continue using it"
    a.addButton(withTitle: "OK")
    a.alertStyle = NSAlert.Style.informational
    
    a.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
      
      if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
        Logger.debug("User did open app in Mac App Store")
        self.openAppInMacAppStore()
      }
      
    })
  }
  
  func openAppInMacAppStore() {
    if let url = URL(string: "macappstore://apps.apple.com/us/app/video-converter/id1518836004") {
      NSWorkspace.shared.open(url)
      NSApplication.shared.terminate(self)
    }
  }
  
}
