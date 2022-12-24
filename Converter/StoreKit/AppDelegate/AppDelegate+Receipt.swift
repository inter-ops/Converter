//
//  AppDelegate+Receipt.swift
//  Converter
//
//  Created by Justin Bush on 12/17/22.
//

import Foundation
import TPInAppReceipt

extension AppDelegate {
  
  var userReceiptDoesContainPremium: Bool {
    return userReceiptDoesContainPremiumPurchase()
  }
  
  func userReceiptDoesContainPremiumPurchase() -> Bool {
    if let receipt = try? InAppReceipt.localReceipt() {
      if localReceiptIsValid(receipt: receipt) {
        // All genuine users should reach this point
        Logger.debug("Purchase Status: \(IAPStore.shared.isProductPurchased(Store.Products.premium.id))")
        return IAPStore.shared.isProductPurchased(Store.Products.premium.id)
      }
      
    } else {
      // Only Xcode, TestFlight and App Store Review builds should reach this point
      Logger.debug("Receipt: Not found. Requesting from Sandbox...")
      requestReceiptFromSandbox()
    }
    return false
  }
  
  func localReceiptIsValid(receipt: InAppReceipt) -> Bool {
    do {
      try receipt.validate()
      
    } catch IARError.validationFailed(reason: .hashValidation) {
      // Hash validation failed
      Logger.error("Receipt: Hash validation failed")
      return false
      
    } catch IARError.validationFailed(reason: .bundleIdentifierVerification) {
      // Bundle identifier verification failed
      Logger.error("Receipt: Bundle ID validation failed")
      return false
      
    } catch IARError.validationFailed(reason: .signatureValidation) {
      // Signature validation
      Logger.error("Receipt: Signature validation failed")
      return false
      
    } catch {
      // Miscellaneous error
      Logger.error("Receipt: Unknown validation error")
      return false
      
    }
    
    Logger.debug("Receipt: Passed validation checks")
    return true
  }
  
  // MARK: - Sandbox Testing
  
  func requestReceiptFromSandbox() {
    InAppReceipt.refresh { (error) in
      if let err = error {
        Logger.error("Receipt: \(err)")
      } else {
        Logger.debug("Receipt: Refresh successful")
        self.handleSandboxReceiptRequest()
      }
    }
  }
  
  func handleSandboxReceiptRequest() {
    if userReceiptDoesContainPremium {
      Logger.debug("Receipt: Enabling Premium for Sandbox account")
      enablePremiumInViewController()
    }
  }
  
}
