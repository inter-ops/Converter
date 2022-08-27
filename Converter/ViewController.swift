//
//  ViewController.swift
//  Converter
//
//  Created by Justin Bush on 8/12/22.
//

import Cocoa
import ffmpegkit

class ViewController: NSViewController, DragDropViewDelegate {
  
  @IBOutlet weak var dragDropView: NSImageView!
  @IBOutlet weak var formatDropdown: NSPopUpButton!
  @IBOutlet weak var progressBar: ColorfulProgressIndicator!
  @IBOutlet weak var convertButton: NSButton!
  @IBOutlet weak var estimatedTimeText: NSTextField!
  
  @IBOutlet weak var supportedSubText: NSTextField!
  
  var outputFormat: VideoFormat = .mp4   // Default output format
  var inputFileUrl: URL?
  var outputFileUrl: URL?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Init view
    initProgressBar()
    initDropdownMenu()
    updateSupportedSubText(.hide)
  }
  
  override func viewDidAppear() {
    // Open file browser on startup
    //selectInputFileUrl()
  }
  
  func dragDropViewDidReceive(fileUrl: String) {
    print("dragDropViewDidReceive(fileUrl: \(fileUrl))")
    
    var newInputFileUrl = fileUrl
    
    if fileUrl.prefix(7) == "file://" {
      newInputFileUrl = String(fileUrl.dropFirst(7)) //fileUrl.replacingOccurrences(of: "file://", with: "")
    }
    inputFileUrl = newInputFileUrl.fileURL.absoluteURL
    
    if Format.isSupported(fileUrl) {
      updateDragDropView(.videoFile)
      updateSupportedSubText(.hide)
    } else {
      updateDragDropView(.unsupported)
      updateSupportedSubText(.show)
    }
  }
  
  func updateDragDropView(_ forType: DragDropBox) {
    dragDropView.image = forType.image
  }
  
  // TODO: Replace with Supported Formats popover view
  func updateSupportedSubText(_ animate: AnimateFade) {
    let supportedFileTypes = Format.supported.joined(separator: ", ")
    switch animate {
    case .show:
      supportedSubText.stringValue = "Supported: \(supportedFileTypes)"
    case .hide:
      supportedSubText.stringValue = ""
    }
  }
  
  /// Returns VideoFormat type upon user dropdown selection (ie. `.mp4`)
  func userDidSelectFormat(_ format: VideoFormat) {
    // Update outputFormat to selected item
    outputFormat = format
    
    print("User did select \(format.rawValue)")
  }
  
  func userDidClickConvert() { userDidClickConvert(outputFormat) }
  func userDidClickConvert(_ withFormat: VideoFormat) {
    
    selectOutputFileUrl(format: withFormat)
    
    updateProgressBar(.show)
    updateProgressBar(value: 0)
    
    let duration = getVideoDuration(inputFilePath: inputFileUrl!.path)
    
    if (inputFileUrl == nil || outputFileUrl == nil) {
      print("User has not selected input or output file, skipping conversion!")
      return
    }
    
    var timer = Timer()
    
    let totalNumberOfFrames = getNumberOfFrames(inputFilePath: inputFileUrl!.path)
    let startOfConversion = Date()
    
    let ffmpegSession = runFfmpegConversion(inputFilePath: inputFileUrl!.path, outputFilePath: outputFileUrl!.path) { _ in
      print("Done converting!")
      timer.invalidate()
      
      // TODO: This doesnt work currently. We need this to ensure the progress bar updates if the conversion completes before the timer interval starts
      self.updateProgressBar(value: 100)
    }
    
    // TODO: time estimate is very unstable in first few seconds, lets hide it until we see it stabalize?
    
    // This currently updates progress every 0.5 seconds
    let interval = 0.5
    timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: { _ in
      
      let statistics = ffmpegSession.getStatistics()
      let count = statistics!.count
      if (count > 0) {
        if let lastStat = statistics![count-1] as? Statistics {
          let time = Double(lastStat.getTime() / 1000)
          let progressPercentage = (time / duration) * 100
          print("Progress: \(progressPercentage) %")
          self.updateProgressBar(value: progressPercentage, withInterval: interval)
          
          let timeElapsed = startOfConversion.timeIntervalSinceNow * -1
          print("Time elapsed: \(timeElapsed)")
          let convertedFrames = lastStat.getVideoFrameNumber()
          print("Number of converted frames: \(convertedFrames)")
          let totalConversionTime = timeElapsed * (totalNumberOfFrames / Double(convertedFrames))
          
          let timeRemaining = totalConversionTime - timeElapsed
          print("Estimated time remaining: \(timeRemaining)s")
          self.updateTimeRemaining(timeRemaining)
        }
      }
    })
  }
  
  /// Takes total seconds remaining, formats to `hr, min, sec` and updates the UI text to reflect
  func updateTimeRemaining(_ remainingInSeconds: Double) {
    let seconds = Int(remainingInSeconds)
    let (h, m, s) = (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    
    if h > 0 {
      estimatedTimeText.stringValue = "\(h)h \(m)m"
    } else {
      estimatedTimeText.stringValue = "\(m)m \(s)s"
    }
  }
  
  func selectOutputFileUrl(format: VideoFormat) {
    let savePanel = NSSavePanel()
    savePanel.canCreateDirectories = true
    savePanel.title = "Save your video"
    savePanel.message = "Choose a name for your converted video:"
    savePanel.nameFieldLabel = "Video file name:"
    savePanel.nameFieldStringValue = "Untitled"
    
    savePanel.allowedFileTypes = [format.rawValue]
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
  
  var formatTitles: [String] = []
  /// Return VideoFormat title strings as an array for dropdown presentation
  func getDropdownTitles() -> [String] {
    for format in VideoFormat.allCases {
      formatTitles.append(format.dropdownTitle)
    }
    return formatTitles
  }
  
  /// Return VideoFormat type from dropdown item selection
  func getFormat(_ item: String) -> VideoFormat {
    for format in VideoFormat.allCases {
      if item == format.dropdownTitle {
        return format
      }
    }
    print("Error, unable to read selected format type\nReturning default type: VideoFormat.mp4")
    return .mp4
  }
  
  /// Called when the user updates dropdown selection item
  @IBAction func selectFormat(_ sender: NSPopUpButton) {
    userSelectedFormat = sender.titleOfSelectedItem!
    userSelectedFormatType = getFormat(userSelectedFormat)
    // Handler function
    userDidSelectFormat(userSelectedFormatType)
  }
  var userSelectedFormat = VideoFormat.mp4.dropdownTitle
  var userSelectedFormatType: VideoFormat = .mp4
  
  @IBAction func clickConvert(_ sender: Any) {
    // User did click "Convert" button
    userDidClickConvert()
  }
  
  // MARK: Progress Bar
  /// Initialize progress bar with hidden default state
  func initProgressBar() {
    progressBar.progressColor = NSColor.controlAccentColor
    progressBar.backgroundColor = NSColor.controlBackgroundColor
    progressBar.borderColor = NSColor.placeholderTextColor //.separatorColor
    progressBar.borderWidth = 0.3
    progressBar.cornerRadius = 3
    progressBar.animate(to: 0, minValue: 0, maxValue: 100)
    
    updateProgressBar(.hide)
  }
  
  /// Show/hide progress bar animation
  func updateProgressBar(_ animate: AnimateFade) {
    progressBar.alphaValue = animate.alpha
  }
  
  /// Update progress bar animation with Double value
  func updateProgressBar(value: Double, withInterval: Double = 0.5) {
    if value >= 100 {
      updateProgressBar(.hide)
      progressBar.animate(to: 0)
    } else {
      updateProgressBar(.show)
      progressBar.animate(to: value)
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
