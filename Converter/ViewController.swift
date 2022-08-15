//
//  ViewController.swift
//  Converter
//
//  Created by Justin Bush on 8/12/22.
//

import Cocoa
import ffmpegkit

class ViewController: NSViewController {

  @IBOutlet weak var dragDropView: NSImageView!
  @IBOutlet weak var formatDropdown: NSPopUpButton!
  @IBOutlet weak var progressBar: NSProgressIndicator!
  @IBOutlet weak var convertButton: NSButton!
  
  var outputFormat: VideoFormat = .mp4   // Default output
    var inputFileUrl: URL?
    var outputFileUrl: URL?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Init view
    updateProgressBar(.hide)
    initDropdownMenu()
      
      // TODO: This is a hack to test input file selection until we get the drag-and-drop working
      selectInputFileUrl()
  }
    
    // TODO: Drag and drop https://developer.apple.com/documentation/uikit/drag_and_drop/adopting_drag_and_drop_in_a_custom_view
  
  /// Returns VideoFormat type upon user dropdown selection (ie. `.mp4`)
  func userDidSelectFormat(_ format: VideoFormat) {
    // Update outputFormat to selected item
    outputFormat = format
    
    print("User did select \(format.rawString)")
  }
  
  func userDidClickConvert() { userDidClickConvert(outputFormat) }
  func userDidClickConvert(_ withFormat: VideoFormat) {

    selectOutputFileUrl(format: withFormat)
      
    updateProgressBar(.show)
    updateProgressBar(withValue: 0)
      
    let duration = getVideoDuration(inputFilePath: inputFileUrl!.path)
      
      if (inputFileUrl == nil || outputFileUrl == nil) {
          print("User has not selected input or output file, skipping conversion!")
          return
      }
      
      var timer = Timer()
      
      let ffmpegSession = runFfmpegConversion(inputFilePath: inputFileUrl!.path, outputFilePath: outputFileUrl!.path) { _ in
          print("Done converting!")
          timer.invalidate()
          
          // TODO: This doesnt work currently. We need this to ensure the progress bar updates if the conversion completes before the timer interval starts
          self.updateProgressBar(withValue: 100)
      }
      
      // This currently updates progress every 0.5 seconds
      timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { _ in
              
          let statistics = ffmpegSession.getStatistics()
          let count = statistics!.count
          if (count > 0) {
              if let lastStat = statistics![count-1] as? Statistics {
                  let time = Double(lastStat.getTime() / 1000)
                  let progressPercentage = (time / duration) * 100
                  print("Progress: \(progressPercentage) %")
                  self.updateProgressBar(withValue: progressPercentage)
              }
          }
        })
  }
  
    // TODO: Handle drag-n-drop
    
    func selectInputFileUrl() {
        let openPanel = NSOpenPanel()
        
        // TODO: Restrict allowed file types
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.canChooseFiles = true
        
        let response = openPanel.runModal()
        if response == .OK {
            inputFileUrl = openPanel.url!
        }
    }
    
    func selectOutputFileUrl(format: VideoFormat) {
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.title = "Save your video"
        savePanel.message = "Choose a name for your converted video:"
        savePanel.nameFieldLabel = "Video file name:"
        savePanel.nameFieldStringValue = "Untitled"
        
        // TODO: Should be using allowedContentTypes, but for some reason it's not available, likely a version compat. issue
        savePanel.allowedFileTypes = [format.rawString]
        savePanel.allowsOtherFileTypes = false
        savePanel.isExtensionHidden = true
        
        let response = savePanel.runModal()
        if response == .OK {
            outputFileUrl = savePanel.url!
        }
    }
  
  /// Initialize dropdown menu with titles (see `VideoFormat.dropdownTitle` for values)
  func initDropdownMenu() {
    formatDropdown.removeAllItems()
    formatDropdown.addItems(withTitles: getDropdownTitles())
  }
  
  /// Return VideoFormat title strings as an array for dropdown presentation
  func getDropdownTitles() -> [String] {
      // TODO: Filter out the input file type
    return [VideoFormat.mp4.dropdownTitle,
            VideoFormat.m4v.dropdownTitle,
            VideoFormat.mkv.dropdownTitle,
            VideoFormat.mov.dropdownTitle,
//            VideoFormat.gif.dropdownTitle,
            VideoFormat.webm.dropdownTitle
    ]
  }
  /// Return VideoFormat type from dropdown item selection
  func getFormat(_ item: String) -> VideoFormat {
    if item.contains("MP4") { return .mp4 }
    else if item.contains("M4V") { return .m4v }
    else if item.contains("MKV") { return .mkv }
      else if item.contains("MOV") { return .mov }
      else if item.contains("WEBM") { return .webm }
//    else if item.contains("GIF") { return .gif }
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
