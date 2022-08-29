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
  @IBOutlet weak var actionButton: NSButton!
  @IBOutlet weak var estimatedTimeText: NSTextField!
  
  // DragDropView titles
  @IBOutlet weak var dragDropTopTitle: NSTextField!
  @IBOutlet weak var dragDropBottomTitle: NSTextField!
  
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
  
  // TODO: After conversion is done, we should change the state of the "Convert" button. We could do something like "Reset" to clear the entire UI. Or just auto clear the input file so that the user is forced to drag a new one in if they want to click "Convert" again.
  
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
  /// Sets the dragDropBox title text without affecting the box style (ie. `bottom: inputFileName`)
  func updateDragDropTitle(_ top: String = "", bottom: String = "") {
    if !top.isEmpty { dragDropTopTitle.stringValue = top }
    if !bottom.isEmpty { dragDropBottomTitle.stringValue = bottom }
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
  
  /// Calculates the video conversion progress in percentage.
  func getProgressPercentage(statistics: Statistics) -> Double {
    let time = Double(statistics.getTime() / 1000)
    let progressPercentage = (time / self.videoDuration!) * 100
    return progressPercentage
  }
  
  /// Calculates an estimated time remaining for the active video conversion.
  func getEstimatedTimeRemaining(statistics: Statistics, progressPercentage: Double) -> Double {
    let timeElapsed = self.startOfConversion!.timeIntervalSinceNow * -1
    let convertedFrames = statistics.getVideoFrameNumber()
    let totalConversionTime = timeElapsed * (self.totalNumberOfFrames! / Double(convertedFrames))
    
    let timeRemaining = totalConversionTime - timeElapsed
    return timeRemaining
  }
  
  /// Checks whether time estimates are stable or not, and sets isTimeRemainingStable to true once they have stabalized. Estimates are stable if they have not deviated by more than 20% since the last statistics query.
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
    
    // Since the last statistic will have been checked Constants.progressUpdateInterval earlier then the current one, we need to adjust it for comparison
    let adjustedLastTimeRemaining = lastTimeRemaining - Constants.progressUpdateInterval
    
    // We determine the time remaining to be stable if timeRemaining and adjustedTimeRemaining are within 20% of each other
    self.isTimeRemainingStable = max(timeRemaining, adjustedLastTimeRemaining) / min(timeRemaining, adjustedLastTimeRemaining) < 1.2
  }
  
  var isActivelyConverting = false
  func userDidClickActionButton() {
    if isActivelyConverting {
      userDidClickStop()
      actionButton.title = "Convert"
    } else {
      userDidClickConvert()
      actionButton.title = "Stop"
    }
    isActivelyConverting = !isActivelyConverting
  }
  
  /// Called when the user clicks "Stop" upon a conversion-in-progress
  func userDidClickStop() {
    // TODO: Stop conversion process, possibly with an alert and deleting the mid-converted file?
    print("User did stop conversion process")
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
      timer.invalidate()
      
      DispatchQueue.main.async {
        self.updateProgressBar(value: 100)
        self.estimatedTimeText.stringValue = "Done 🚀"
      }
    }
    
    // This currently updates progress every 0.5 seconds
    timer = Timer.scheduledTimer(withTimeInterval: Constants.progressUpdateInterval, repeats: true, block: { _ in
      
      if let statisticsArray = ffmpegSession.getStatistics() as? [Statistics] {
        // This must be called before updateTimeRemaining to ensure we know whether the time remaining is stable or not.
        self.checkStabilityOfTimeRemaining(statisticsArray: statisticsArray)
        
        let lastStatistics = statisticsArray[statisticsArray.count - 1]
        
        let progressPercentage = self.getProgressPercentage(statistics: lastStatistics)
        let timeRemaining = self.getEstimatedTimeRemaining(statistics: lastStatistics, progressPercentage: progressPercentage)
        
        self.updateProgressBar(value: progressPercentage)
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
    
    if h > 0 {
      estimatedTimeText.stringValue = "\(h)h \(m)m"
    } else if m > 0 {
      estimatedTimeText.stringValue = "\(m)m \(s)s"
    } else if s > 0 {
      estimatedTimeText.stringValue = "\(s)s"
    } else {
      // FFMPEG has a slight lag after frames are done processing but before the conversion is compelete, so we show the user a message to avoid freezing the time estimate.
      estimatedTimeText.stringValue = "Finishing up..."
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
  
  @IBAction func clickActionButton(_ sender: Any) {
    // User did click button: "Convert" or "Stop"
    userDidClickActionButton()
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
  func updateProgressBar(value: Double, withInterval: Double = 0.5) {
    progressBar.animate(to: value)
  }
  
  func resetProgressBar() {
    updateProgressBar(value: 0)
    estimatedTimeText.stringValue = "–:–"
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
