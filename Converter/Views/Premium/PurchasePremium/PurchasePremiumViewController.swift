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
  
  @IBAction func presentVideoPreviewButtonAction(_ sender: NSButton) {
    expandAndPlayVideo()
  }
  
  @IBAction func dismissVideoPreviewButtonAction(_ sender: NSButton) {
    collapseAndStopVideo()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initVideoPreview()
  }
  
  func initVideoPreview() {
    expandVideoView()
    initVideo()
  }
  
  func expandAndPlayVideo() {
    expandVideoView()
    playVideo()
  }
  
  func collapseAndStopVideo() {
    collapseVideoView()
    stopVideo()
  }
  
  func expandVideoView() {
    videoPreviewHeightConstraint.animator().constant = 190
    dismissVideoPreviewButton.isHidden = false
    presentVideoPreviewButton.isHidden = true
    darkOverlayImageView.animator().isHidden = true
  }
  
  func collapseVideoView() {
    videoPreviewHeightConstraint.animator().constant = 80
    dismissVideoPreviewButton.isHidden = true
    presentVideoPreviewButton.isHidden = false
    darkOverlayImageView.animator().isHidden = false
  }
  
  func initVideo() {
    let videoUrl = URL(string: "https://converter.airtv.io/app-assets/premium-preview.mov")
    let player = AVPlayer(url: videoUrl!)
    videoPlayer.player = player
    player.play()
    player.actionAtItemEnd = .none
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(playerItemDidReachEnd(notification:)),
                                           name: .AVPlayerItemDidPlayToEndTime,
                                           object: player.currentItem)
  }
  
  func playVideo() {
    videoPlayer.player?.play()
  }
  
  func stopVideo() {
    videoPlayer.player?.pause()
  }
  

  @objc func playerItemDidReachEnd(notification: Notification) {
    if let playerItem = notification.object as? AVPlayerItem {
      playerItem.seek(to: CMTime.zero, completionHandler: nil)
    }
  }

  
}
