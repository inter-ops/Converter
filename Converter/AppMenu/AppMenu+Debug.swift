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
  
  @IBAction func toggleExpandCollapsePremiumView(_ sender: NSMenuItem) {
    let viewController = mainWindow.contentViewController as? ViewController
    viewController?.toggleExpandCollapsePremiumView(self)
  }
  
  @IBAction func togglePurchasePremiumView(_ sender: NSMenuItem) {
    let viewController = mainWindow.contentViewController as? ViewController
    viewController?.segue(.sheetPurchasePremium)
  }
  
  @IBAction func collapsePremiumView(_ sender: Any) {
    let viewController = mainWindow.contentViewController as? ViewController
    viewController?.collapsePremiumIfExpanded()
  }
  
  @IBAction func enableViewControllerUI(_ sender: Any) {
    let viewController = mainWindow.contentViewController as? ViewController
    viewController?.enableUi()
  }
  
  @IBAction func disableViewControllerUI(_ sender: Any) {
    let viewController = mainWindow.contentViewController as? ViewController
    viewController?.disableUi()
  }
  
  @IBAction func disableViewControllerUIWithAnimation(_ sender: Any) {
    let viewController = mainWindow.contentViewController as? ViewController
    viewController?.disableUi(withLoaderAnimation: true)
  }
  
  // MARK: - StoreKit
  
  @IBAction func debugPurchasePremiumTransaction(_ sender: Any) {
    purchasePremium()
  }
  
  @IBAction func debugRestorePurchaseSession(_ sender: Any) {
    restorePurchases()
  }
  
  // MARK: - Receipt Validation
  
  @IBAction func debugCheckPremiumPurchaseReceipt(_ sender: Any) {
    Logger.debug("Premium Purchase Status: \(userReceiptDoesContainPremium)")
  }
  
  @IBAction func debugRequestReceiptRefresh(_ sender: Any) {
    requestReceiptFromSandbox()
  }
  
  @IBAction func debugSimulateLowerRequiredVersion(_ sender: Any) {
    let viewController = mainWindow.contentViewController as? ViewController
    viewController?.disableUiAndShowLatestVersionAlert()
  }
  
}
