//
//  ViewController.swift
//  Converter
//
//  Created by Justin Bush on 8/12/22.
//

import Cocoa

class ViewController: NSViewController {

  @IBOutlet weak var dragDropView: NSImageView!
  @IBOutlet weak var formatDropdown: NSPopUpButton!
  @IBOutlet weak var progressBar: NSProgressIndicator!
  @IBOutlet weak var convertButton: NSButton!
  
  var outputFormat: VideoFormat = .mp4   // Default output
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Init view
    updateProgressBar(.hide)
    initDropdownMenu()
    
  }
  
  /// Returns VideoFormat type upon user dropdown selection (ie. `.mp4`)
  func userDidSelectFormat(_ format: VideoFormat) {
    // Update outputFormat to selected item
    outputFormat = format
    
    print("User did select \(format.rawString)")
  }
  
  func userDidClickConvert() { userDidClickConvert(outputFormat) }
  func userDidClickConvert(_ withFormat: VideoFormat) {
    updateProgressBar(.show)
    // Perform some function for each case
    switch withFormat {
    case .mp4:
      print("User did request conversion to .mp4")
    case .m4v:
      print("User did request conversion to .m4v")
    case .mkv:
      print("User did request conversion to .mkv")
    case .gif:
      print("User did request conversion to .gif")
    }
  }
  
  
  /// Initialize dropdown menu with titles (see `VideoFormat.dropdownTitle` for values)
  func initDropdownMenu() {
    formatDropdown.removeAllItems()
    formatDropdown.addItems(withTitles: getDropdownTitles())
  }
  
  /// Return VideoFormat title strings as an array for dropdown presentation
  func getDropdownTitles() -> [String] {
    return [VideoFormat.mp4.dropdownTitle,
            VideoFormat.m4v.dropdownTitle,
            VideoFormat.mkv.dropdownTitle,
            VideoFormat.gif.dropdownTitle]
  }
  /// Return VideoFormat type from dropdown item selection
  func getFormat(_ item: String) -> VideoFormat {
    if item.contains("MP4") { return .mp4 }
    else if item.contains("M4V") { return .m4v }
    else if item.contains("MKV") { return .mkv }
    else if item.contains("GIF") { return .gif }
    else { print("Error, unable to read selected format type\nReturning default type: VideoFormat.mp4") }
    return .mp4
  }
  
  /// Called when the user updates dropdown selection item
  @IBAction func selectFormat(_ sender: NSPopUpButton) {
    userSelectedFormat = sender.titleOfSelectedItem!
    userSelectedFormatType = getFormat(userSelectedFormat)
    // Handler function
    userDidSelectFormat(userSelectedFormatType)
  }
  var userSelectedFormat = "MP4"
  var userSelectedFormatType: VideoFormat = .mp4
  
  @IBAction func clickConvert(_ sender: Any) {
    // User did click "Convert" button
    userDidClickConvert()
  }
  
  // MARK: Progress Bar
  /// Show/hide progress bar animation
  func updateProgressBar(_ animate: AnimateFade) {
    progressBar.alphaValue = animate.alpha
  }
  
  /// Update progress bar animation with Double value
  func updateProgressBar(withValue: Double) {
    if withValue >= 100 {
      updateProgressBar(.hide)
      progressBar.doubleValue = 0
    } else {
      progressBar.doubleValue = withValue
    }
  }


}



enum AnimateFade {
  case show, hide
  
  var alpha: CGFloat {
    switch self {
    case .show: return CGFloat(1)
    case .hide: return CGFloat(0)
    }
    
  }
}
