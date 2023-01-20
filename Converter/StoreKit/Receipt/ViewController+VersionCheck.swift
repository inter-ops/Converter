//
//  ViewController+VersionCheck.swift
//  Converter
//
//  Created by Justin Bush on 1/3/23.
//

import Cocoa

extension ViewController {
  
  var appBuildNumber: Int {
    if let buildNumberString = Constants.buildNumberString as? String {
      if let buildNumberInt = buildNumberString.toInt() {
        return buildNumberInt
      }
    }
    
    let defaultBuildNumber = 1
    Logger.error("Error fetching local build number, returning \(defaultBuildNumber)")
    return defaultBuildNumber
  }
  
  var appVersionString: String {
    if let appVersionString = Constants.appVersionString as? String {
      return appVersionString
    }
    
    let defaultVersionNumber = "1.0.0"
    Logger.error("Error fetching app version, returning \(defaultVersionNumber)")
    return defaultVersionNumber
  }
  
  
  func logCurrentAppVersion() {
    Logger.debug("App Version: \(appVersionString) (\(appBuildNumber))")
  }
  
  func checkIfAppVersionHasBeenFlagged() {
    // If app version was flagged, require internet check to resolve
    if UserDefaults.standard.appVersionHasBeenFlagged() {
      Logger.debug("App version has been flagged, prompting user for internet connection")
      DispatchQueue.main.async {
        self.disableUiAndShowConnectionRequiredAlert()
      }
    }
  }
  
  func checkInternetAndMinimumAppVersion() {
    if Reachability.isConnectedToNetwork() {
      checkMinimumAppVersion()
      return
    }
    
    Logger.debug("Unable to connect to the internet for app version validation")
    checkIfAppVersionHasBeenFlagged()
  }
  
  func checkMinimumAppVersion() {
    API.getMinimumAppVersion { responseData, errorMessage in
      if errorMessage != nil && errorMessage!.contains("The request timed out") {
        Logger.debug("Request to get minimum app version timed out")
        self.checkIfAppVersionHasBeenFlagged()
        return
      }
      
      if let minimumAppVersion = responseData?["version"] as? String {
        if minimumAppVersion.compare(self.appVersionString, options: .numeric) == .orderedDescending {
          Logger.debug("App version \(self.appVersionString) is older than minimum version \(minimumAppVersion), disabling UI")
          UserDefaults.standard.flagAppVersionAsLowerThanRequired(true)
          
          DispatchQueue.main.async {
            self.disableUiAndShowLatestVersionAlert()
          }
        }
        else {
          Logger.debug("App version \(self.appVersionString) is valid for minimum version \(minimumAppVersion)")
          UserDefaults.standard.flagAppVersionAsLowerThanRequired(false)
        }
      }
      else {
        Logger.error("Invalid data returned when fetching app version")
      }
    }
        
  }
  
  func disableUiAndShowLatestVersionAlert() {
    disableUi()
    showLatestVersionAlert()
  }
  
  func disableUiAndShowConnectionRequiredAlert() {
    disableUi()
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
