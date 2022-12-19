//
//  ViewController+SKHelpers.swift
//  Converter
//
//  Created by Justin Bush on 12/19/22.
//

import Foundation

extension ViewController {
  
  func initStoreKitHelper() {
    initSKObservers()
    initReceiptCheck()
    StoreKitHelper.shared.getProducts(products: Products.premium())
  }
  
}
