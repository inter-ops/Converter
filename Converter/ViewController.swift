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
  var videoDuration: Double?
  var totalNumberOfFrames: Double?
  var startOfConversion: Date?
  var isTimeRemainingStable = false
  
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
  
  func getProgressPercentage(statistics: Statistics) -> Double {
    let time = Double(statistics.getTime() / 1000)
    let progressPercentage = (time / self.videoDuration!) * 100
    return progressPercentage
  }
  
  func getEstimatedTimeRemaining(statistics: Statistics, progressPercentage: Double) -> Double {
    let timeElapsed = self.startOfConversion!.timeIntervalSinceNow * -1
    let convertedFrames = statistics.getVideoFrameNumber()
    let totalConversionTime = timeElapsed * (self.totalNumberOfFrames! / Double(convertedFrames))
    
    let timeRemaining = totalConversionTime - timeElapsed
    return timeRemaining
  }
  
  func checkStabilityOfTimeRemaining(statisticsArray: [Statistics]) -> Void {
    // If we've already determined that the time remaining is stable, nothing to do
    if self.isTimeRemainingStable {
      return
    }
    
    // Wait until we've collected at least 3 statistics before evaluating whether time estimates are stable
    if statisticsArray.count < 3 {
      return
    }
    
    let progressPercentage = getProgressPercentage(statistics: statisticsArray[statisticsArray.count-1])
    let timeRemaining = getEstimatedTimeRemaining(statistics: statisticsArray[statisticsArray.count-1], progressPercentage: progressPercentage)
    
    let lastProgressPercentage = getProgressPercentage(statistics: statisticsArray[statisticsArray.count-2])
    let lastTimeRemaining = getEstimatedTimeRemaining(statistics: statisticsArray[statisticsArray.count-2], progressPercentage: lastProgressPercentage)
    
    // Since the last statistic will have been checked PROGRESS_UPDATE_INTERVAL earlier then the current one, we need to adjust it for comparison
    let adjustedLastTimeRemaining = lastTimeRemaining-PROGRESS_UPDATE_INTERVAL
    
    // We determine the time remaining to be stable if timeRemaining and adjustedTimeRemaining are within 20% of each other
    self.isTimeRemainingStable = max(timeRemaining, adjustedLastTimeRemaining) / min(timeRemaining, adjustedLastTimeRemaining) < 1.2
  }
  
  func userDidClickConvert() { userDidClickConvert(outputFormat) }
  func userDidClickConvert(_ withFormat: VideoFormat) {
    
    selectOutputFileUrl(format: withFormat)
    
    updateProgressBar(.show)
    updateProgressBar(value: 0)
    
    if (inputFileUrl == nil || outputFileUrl == nil) {
      print("User has not selected input or output file, skipping conversion!")
      return
    }
    
    var timer = Timer()
    
    self.videoDuration = getVideoDuration(inputFilePath: inputFileUrl!.path)
    self.totalNumberOfFrames = getNumberOfFrames(inputFilePath: inputFileUrl!.path)
    self.startOfConversion = Date()
    
    let ffmpegSession = runFfmpegConversion(inputFilePath: inputFileUrl!.path, outputFilePath: outputFileUrl!.path) { _ in
      print("Done converting!")
      timer.invalidate()
      
      // TODO: This doesnt work currently. We need this to ensure the progress bar updates if the conversion completes before the timer interval starts
      self.updateProgressBar(value: 100)
    }
    
    // This currently updates progress every 0.5 seconds
    timer = Timer.scheduledTimer(withTimeInterval: PROGRESS_UPDATE_INTERVAL, repeats: true, block: { _ in
      
      if let statisticsArray = ffmpegSession.getStatistics() as? [Statistics] {
        self.checkStabilityOfTimeRemaining(statisticsArray: statisticsArray)
        
        let lastStatistics = statisticsArray[statisticsArray.count - 1]
        
        let progressPercentage = self.getProgressPercentage(statistics: lastStatistics)
        let timeRemaining = self.getEstimatedTimeRemaining(statistics: lastStatistics, progressPercentage: progressPercentage)
        
        self.updateProgressBar(value: progressPercentage, withInterval: PROGRESS_UPDATE_INTERVAL)
        self.updateTimeRemaining(timeRemaining)
      }
      
    })
  }
  
  /// Takes total seconds remaining, formats to `hr, min, sec` and updates the UI text to reflect
  func updateTimeRemaining(_ remainingInSeconds: Double) {
    if !self.isTimeRemainingStable {
      return
    }
    
    let seconds = Int(remainingInSeconds)
    let (h, m, s) = (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    
    // TODO: Implement "Finishing up..." phase before "Done!"
    // This TODO may not be necessary if we implement progress Timer properly
    if h > 0 {
      estimatedTimeText.stringValue = "\(h)h \(m)m"
    } else if m > 0 {
      estimatedTimeText.stringValue = "\(m)m \(s)s"
    } else if s > 0 {
      estimatedTimeText.stringValue = "\(s)s"
    } else {
      estimatedTimeText.stringValue = "Done!"
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
  /// Initialize progress bar with hidden default state and config values,
  /// ie. `progressBar.progressColor = .blue` or `progressBar.cornerRadius = 3`
  func initProgressBar() {
    // ProgressBar init
    updateProgressBar(.hide)
  }
  
  /// Show/hide progress bar animation
  func updateProgressBar(_ animate: AnimateFade) {
    progressBar.alphaValue = animate.alpha
  }
  
  /// Update progress bar animation with Double value
  func updateProgressBar(value: Double, withInterval: Double = PROGRESS_UPDATE_INTERVAL) {
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
