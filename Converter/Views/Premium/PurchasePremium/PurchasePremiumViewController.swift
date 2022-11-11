//
//  PurchasePremiumViewController.swift
//  Converter
//
//  Created by Justin Bush on 11/3/22.
//

import Cocoa
import AVKit

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
  @IBOutlet weak var darkOverlayImageView: NSImageView!
  @IBOutlet weak var videoPlayer: AVPlayerView!
  @IBOutlet weak var videoPreviewHeightConstraint: NSLayoutConstraint!
  // 4. Bottom: Action Buttons
  @IBOutlet weak var actionRowView: NSView!
  @IBOutlet weak var purchasePremiumButton: NSButton!
  @IBOutlet weak var restorePurchaseButton: NSButton!
  
  @IBAction func dismissSheetViewController(_ sender: NSButton) {
    videoPlayer.player?.pause() // Ensure player stop
    // Dismiss sheet view
    dismiss(self)
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    appDelegate.collapsePremiumView(self)
    
  }
  
  @IBAction func presentVideoPreviewButtonAction(_ sender: NSButton) {
    expandAndPlayVideo()
  }
  
  @IBAction func dismissVideoPreviewButtonAction(_ sender: NSButton) {
    collapseAndStopVideo()
  }
  
  @IBAction func purchaseButtonAction(_ sender: NSButton) {
    Logger.info("PurchasePremium: User did select purchase button")
    // Call In-App Purchase window
  }
  
  @IBAction func restorePurchaseButtonAction(_ sender: NSButton) {
    Logger.info("PurchasePremium: User did select restore purchase button")
    // Call Purchase Restore window
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initVideoPreview()
  }
  
  
  // MARK: - Video Player
  /// Initialize premium video player
  func initVideoPreview() {
    initVideo()
    initVideoView()
  }
  /// Expand video player view and play video
  func expandAndPlayVideo() {
    expandVideoView()
    playVideo()
  }
  /// Collapse video player view and pause video
  func collapseAndStopVideo() {
    collapseVideoView()
    stopVideo()
  }
  /// Expand video view with `animator()`
  func expandVideoView() {
    videoPreviewHeightConstraint.animator().constant = 190
    dismissVideoPreviewButton.animator().isHidden = false
    presentVideoPreviewButton.animator().isHidden = true
    darkOverlayImageView.animator().isHidden = true
  }
  /// Collapse video view with `animator()`
  func collapseVideoView() {
    videoPreviewHeightConstraint.animator().constant = 80
    dismissVideoPreviewButton.animator().isHidden = true
    presentVideoPreviewButton.animator().isHidden = false
    darkOverlayImageView.animator().isHidden = false
  }
  /// Initialize video container in collapsed state and without animation context
  func initVideoView() {
    videoPreviewHeightConstraint.constant = 80
    dismissVideoPreviewButton.isHidden = true
    presentVideoPreviewButton.isHidden = false
    darkOverlayImageView.isHidden = false
  }
  /// Initialize AVPlayer and play video from source
  func initVideo() {
    // TODO: Replace with premium video preview once premium implementation is complete
    let videoUrl = URL(string: "https://converter.airtv.io/app-assets/premium-preview.mov")
    let player = AVPlayer(url: videoUrl!)
    videoPlayer.player = player
    player.actionAtItemEnd = .none
    // NotificationCenter observer for looping video at end
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(playerItemDidReachEnd(notification:)),
                                           name: .AVPlayerItemDidPlayToEndTime,
                                           object: player.currentItem)
  }
  /// `play()` AVPlayer contents
  func playVideo() {
    videoPlayer.player?.play()
  }
  /// `pause()` AVPlayer contents
  func stopVideo() {
    videoPlayer.player?.pause()
  }
  /// On observed Notification, seek video at 0:00
  @objc func playerItemDidReachEnd(notification: Notification) {
    if let playerItem = notification.object as? AVPlayerItem {
      playerItem.seek(to: CMTime.zero, completionHandler: nil)
    }
  }

  
}
