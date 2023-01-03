//
//  ViewController+VersionCheck.swift
//  Converter
//
//  Created by Justin Bush on 1/3/23.
//

import Cocoa

extension ViewController {
  
  var appVersion: Double {
    if let appVersionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      if let appVersionDouble = Double(appVersionString) {
        return appVersionDouble
      }
    }
    
    Logger.error("Error fetching app version, returning 1.0")
    
    return 1.0
  }
  
  func checkInternetAndMinimumAppVersion() {
    if Reachability.isConnectedToNetwork() {
      checkMinimumAppVersion()
      return
    }
    
    let appVersionWasPreviouslyLowerThanRequired = UserDefaults.standard.bool(forKey: Constants.Keys.appVersionIsLowerThanRequired)
    // If flag was previously triggered, require connection to the internet
    if appVersionWasPreviouslyLowerThanRequired {
      DispatchQueue.main.async {
        self.disableUiAndShowConnectionRequiredAlert()
      }
    }
    
  }
  
  func checkMinimumAppVersion() {
    API.getMinimumAppVersion { responseData, errorMessage in
      if let minimumAppVersion = responseData?["version"] as? Double {
        if self.appVersion < minimumAppVersion {
          Logger.debug("App version \(self.appVersion) is older than minimum version \(minimumAppVersion), disabling UI")
          UserDefaults.standard.set(true, forKey: Constants.Keys.appVersionIsLowerThanRequired)
          
          DispatchQueue.main.async {
            self.disableUiAndShowLatestVersionAlert()
          }
        }
        else {
          Logger.debug("App version \(self.appVersion) is valid for minimum version \(minimumAppVersion)")
          UserDefaults.standard.set(false, forKey: Constants.Keys.appVersionIsLowerThanRequired)
        }
      }
      else {
        Logger.error("Invalid data returned when fetching app version")
      }
    }
        
  }
  
  func disableUiAndShowLatestVersionAlert() {
    disableUI()
    showLatestVersionAlert()
  }
  
  func disableUiAndShowConnectionRequiredAlert() {
    disableUI()
    showConnectionRequiredAlert()
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
    if let url = URL(string: Constants.appStoreUrl) {
      NSWorkspace.shared.open(url)
      NSApplication.shared.terminate(self)
    }
  }
  
  func showConnectionRequiredAlert() {
    let a = NSAlert()
    a.messageText = "Internet Connection Required"
    a.informativeText = "Please connect your device to the internet so that we can validate your copy of Video Converter.\n\nYou only need to do this once!"
    a.addButton(withTitle: "OK")
    a.alertStyle = NSAlert.Style.informational
    
    a.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
      
      if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
        NSApplication.shared.terminate(self)
      }
      
    })
  }
  
}
