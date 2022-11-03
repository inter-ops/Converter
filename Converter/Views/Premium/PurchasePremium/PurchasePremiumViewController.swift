//
//  PurchasePremiumViewController.swift
//  Converter
//
//  Created by Justin Bush on 11/3/22.
//

import Cocoa
import WebKit

class PurchasePremiumViewController: NSViewController {
  
  @IBOutlet weak var premiumDetailsImageView: NSImageView!
  
  @IBOutlet weak var purchasePremiumButton: NSButton!
  @IBOutlet weak var restorePurchaseButton: NSButton!
  
  @IBOutlet weak var previewPremiumVideoWebView: WKWebView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Collapse video preview by default
    
  }
  
  // TODO: Begin load video in background
  
  // TODO: Expand to autoplay video, collapse to restart and stop video
  
}
