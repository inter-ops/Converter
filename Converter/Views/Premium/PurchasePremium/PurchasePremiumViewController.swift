//
//  PurchasePremiumViewController.swift
//  Converter
//
//  Created by Justin Bush on 11/3/22.
//

import Cocoa
import WebKit

class PurchasePremiumViewController: NSViewController {
  
  @IBOutlet weak var mainView: NSView!
  // 1. Top View: Logo and Dismiss Button
  @IBOutlet weak var premiumLogoView: NSView!
  @IBOutlet weak var dismissViewButton: NSButton!
  // 2. Top-Middle View: Checkmark Details
  @IBOutlet weak var premiumDetailsView: NSView!
  @IBOutlet weak var premiumDetailsImageView: NSImageView!
  // 3. Bottom-Middle View: Video Preview
  @IBOutlet weak var videoPreviewView: NSView!
  @IBOutlet weak var presentVideoPreviewButton: NSButton!
  @IBOutlet weak var dismissVideoPreviewButton: NSButton!
  @IBOutlet weak var videoPreviewWebView: WKWebView!
  @IBOutlet weak var videoPreviewHeightConstraint: NSLayoutConstraint!
  // 4. Bottom: Action Buttons
  @IBOutlet weak var actionRowView: NSView!
  @IBOutlet weak var purchasePremiumButton: NSButton!
  @IBOutlet weak var restorePurchaseButton: NSButton!

  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Collapse video preview by default
    
  }
  
  // TODO: Begin load video in background
  
  // TODO: Expand to autoplay video, collapse to restart and stop video
  
}
