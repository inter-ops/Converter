//
//  ViewController+ReceiptCheck.swift
//  Converter
//
//  Created by Justin Bush on 12/11/22.
//

import Foundation
import TPInAppReceipt

extension ViewController {
  
  func initReceiptCheck() {
    checkLocalReceipt()
  }
  
  func checkLocalReceipt() {
    if let receipt = try? InAppReceipt.localReceipt() {
      // do your validation or parsing here
      _ = verifyLocalReceipt(receipt: receipt)
    } else {
      print("[ERROR] Receipt not found")
      requestReceiptRefresh()
    }
  }
  
  func verifyLocalReceipt(receipt: InAppReceipt) -> InAppReceipt? {
    do {
      try receipt.validate()
    } catch IARError.validationFailed(reason: .hashValidation) {
      // Hash validation failed
      print("[FATAL] Hash validation failed")
      return nil
      
    } catch IARError.validationFailed(reason: .bundleIdentifierVerification) {
      // Bundle identifier verification failed
      print("[FATAL] Bundle ID validation failed")
      return nil
      
    } catch IARError.validationFailed(reason: .signatureValidation) {
      // Signature validation
      print("[FATAL] Signature validation failed")
      return nil
      
    } catch {
      // Miscellaneous error
      print("[FATAL] Unknown error")
      return nil
      
    }
    
    print("[VALID] No fatal errors found")
    return receipt
  }
  
  func getLocalReceipt() -> InAppReceipt? {
    if let receipt = try? InAppReceipt.localReceipt() {
      // do your validation or parsing here
      return verifyLocalReceipt(receipt: receipt)
    } else {
      print("[ERROR] Receipt not found, but should exist")
      return nil
    }
  }
  
  func hasPurchasedPremium() {
//    guard let receipt = getLocalReceipt() else {
//      print("[FATAL] Guard reached")
//      return
//    }
//    hasPurchasedPremium(receipt: receipt)
    
    requestReceiptRefresh()
  }
  
  func hasPurchasedPremium(receipt: InAppReceipt) {
    if receipt.containsPurchase(ofProductIdentifier: Store.Products.premium.id){
      print("[STORE] User has purchased Premium")
      return
    }
    print("[ERROR] Receipt not found for Premium")
  }
  
  func requestReceiptRefresh() {
    print("[STORE] Requesting receipt refresh")
    InAppReceipt.refresh { (error) in
      if let err = error {
        print("[ERROR] \(err)")
      } else {
        // do your stuff with the receipt data here
        if let receipt = try? InAppReceipt.localReceipt() {
          // Check if user has purchased premium
          self.hasPurchasedPremium(receipt: receipt)
        }
      }
    }
  }
  
}
