//
//  ViewController.swift
//  Converter
//
//  Created by Justin Bush on 8/12/22.
//

import Cocoa
import ffmpegkit

class ViewController: NSViewController, NSPopoverDelegate, DragDropViewDelegate {
  
  @IBOutlet weak var formatDropdown: NSPopUpButton!
  @IBOutlet weak var progressBar: ColorfulProgressIndicator!
  @IBOutlet weak var actionButton: NSButton!
  @IBOutlet weak var estimatedTimeText: NSTextField!
  @IBOutlet weak var estimatedTimeLabel: NSTextField!
  
  // DragDropView objects
  @IBOutlet weak var dragDropView: NSImageView!
  @IBOutlet weak var dragDropTopTitle: NSTextField!
  @IBOutlet weak var dragDropBottomTitle: NSTextField!
  @IBOutlet weak var clearInputFileButton: NSButton!
  
  // PremiumView: Video
  @IBOutlet weak var premiumView: NSView!
  @IBOutlet weak var codecDropdown: NSPopUpButton!
  @IBOutlet weak var gpuCheckbox: NSButton!
  //@IBOutlet weak var qualitySlider: NSSlider!
  @IBOutlet weak var qualityDropdown: NSPopUpButton!
  // PremiumView: Audio
  @IBOutlet weak var includeAllAudioCheckbox: NSButton!
  // PremiumView: Subtitles
  @IBOutlet weak var includeAllSubtitlesCheckbox: NSButton!
  @IBOutlet weak var burnInSubtitleCheckbox: NSButton!
  @IBOutlet weak var burnInSubtitleDropdown: NSPopUpButton!
  
  // PremiumView variables
  var codecTitles: [String] = []
  
  // MainView variables
  var outputFormat: VideoFormat = .mp4   // Default output format
  var inputFileUrl: URL?
  var outputFileUrl: URL?
  var startOfConversion: Date?
  var isTimeRemainingStable = false
  var ffmpegCommand: String?
  
  var inputVideo: Video?
  
  let appDelegate = NSApplication.shared.delegate as! AppDelegate
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Init view
    initDropdownMenu()
    displayClearButton(.hide)
  }
  
  override func viewDidDisappear() {
    hidePopover(supportedFormatsPopover)
    hidePopover(helpInfoPopover)
  }
  
  func openFileBrowser() {
    let openPanel = NSOpenPanel()
    
    openPanel.allowsMultipleSelection = false
    openPanel.canChooseDirectories = true
    openPanel.canCreateDirectories = true
    openPanel.canChooseFiles = true
    openPanel.allowedFileTypes = supportedInputFormats
    
    let response = openPanel.runModal()
    if response == .OK {
      let path = openPanel.url?.path
      Logger.info("path: \(String(describing: path))")
      dragDropViewDidReceive(fileUrl: path!)
    }
  }
  
  override func viewDidAppear() {
    // Handles opening of file in application on launch after initial load
    DispatchQueue.main.async {
      if self.appDelegate.openAppWithFilePath != nil {
        self.dragDropViewDidReceive(fileUrl: self.appDelegate.openAppWithFilePath!)
        self.appDelegate.openAppWithFilePath = nil
      }
      self.appDelegate.mainViewHasAppeared = true
    }
  }
  
  /// Handles all input file requests, checks for validity and adjust the dragDropView box to reflect any errors
  func dragDropViewDidReceive(fileUrl: String) {
    Logger.debug("dragDropViewDidReceive(fileUrl: \(fileUrl))")
    
    inputFileUrl = fileUrl.fileURL.absoluteURL
    
    if Format.isSupportedAsInput(fileUrl) {
      updateDragDrop(subtitle: fileUrl.lastPathComponent, withStyle: .videoFile)
      displayClearButton(.show)
      
      let isValid = isFileValid(inputFilePath: inputFileUrl!.path)
      if !isValid {
        updateDragDrop(subtitle: "Video file is corrupt", withStyle: .warning)
        inputFileUrl = nil
      }
    } else {
      updateDragDrop(subtitle: "Unsupported file type", withStyle: .warning)
      showSupportedFormatsPopover()
    }
  }
  
  /// Handler for all things dragDropBox related; set `withStyle: .empty` for default state
  /// - parameters:
  ///   - title: Edits the top title text of the box (ie. "Drag and drop your video here")
  ///   - subtitle: Edits the bottom title text of the box (used for additional info and warning descriptors)
  ///   - withStyle: Shows the box style (ie. `.warning` for red outline box)
  /// ```
  /// // Default launch state
  /// updateDragDrop(withStyle: .empty)
  /// // Red box with error message
  /// updateDragDrop(subtitle: "Please select a file first", withStyle: .warning)
  /// ```
  func updateDragDrop(title: String = "", subtitle: String = "", withStyle: DragDropBox) {
    if withStyle == .empty && (title.isEmpty && subtitle.isEmpty) {
      updateDragDrop(title: "Drag and drop your video here", subtitle: "or double click to browse...", withStyle: .empty)
    } else {
      updateDragDropView(withStyle)
      updateDragDropTitle(title, bottom: subtitle)
    }
  }
  /// Obj-C compatible function for passing updateDragDop through delegate
  func updateDragDrop(title: String, subtitle: String, withWarning: Bool) {
    if withWarning {
      updateDragDrop(title: title, subtitle: subtitle, withStyle: .warning)
    } else {
      updateDragDrop(title: title, subtitle: subtitle, withStyle: .videoFile)
      hidePopover(supportedFormatsPopover)
    }
  }
  /// Sets the dragDropBox image view (ie. Set red warning box with `.warning`)
  func updateDragDropView(_ forType: DragDropBox) {
    dragDropView.image = forType.image
  }
  /// Sets the dragDropBox title text without affecting the box style (ie. `bottom: inputFileName`)
  func updateDragDropTitle(_ top: String = "", bottom: String = "") {
    if !top.isEmpty { dragDropTopTitle.stringValue = top }
    if !bottom.isEmpty { dragDropBottomTitle.stringValue = bottom }
  }
  
  /// Returns VideoFormat type upon user dropdown selection (ie. `.mp4`)
  func userDidSelectFormat(_ format: VideoFormat) {
    // Update outputFormat to selected item
    outputFormat = format
    
    Logger.info("User did select \(format.rawValue)")
  }
  
  /// Calculates the video conversion progress in percentage.
  func getProgressPercentage(statistics: Statistics) -> Double {
    let timeElapsed = self.startOfConversion!.timeIntervalSinceNow * -1
    let videoTime = Double(statistics.getTime())/1000
    let totalConversionTime = timeElapsed * (self.inputVideo!.duration / videoTime)
    
    let progressPercentage = (timeElapsed / totalConversionTime) * 100
    return progressPercentage
  }
  
  /// Calculates an estimated time remaining for the active video conversion.
  func getEstimatedTimeRemaining(statistics: Statistics, progressPercentage: Double) -> Double {
    let timeElapsed = self.startOfConversion!.timeIntervalSinceNow * -1
    let videoTime = Double(statistics.getTime())/1000
    let totalConversionTime = timeElapsed * (self.inputVideo!.duration / videoTime)
    
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
  
  /// Determines the state of the conversion process for the Action button (ie. if `.ready`, the app is ready to begin the process; if `.converting`, the app is undergoing conversion
  var currentStatus: ConversionState = .ready
  /// Triggers the action button handler if there exists a valid input file; if no input exists, show an error
  func userDidClickActionButton() {
    if inputFileUrl == nil {
      updateDragDrop(subtitle: "Please select a file first", withStyle: .warning)
    } else {
      handleActionButton(withStatus: currentStatus)
    }
  }
  /// Handles the action button states, and their respective actions, based on the current ConversionState: `.ready` or `.converting`
  func handleActionButton(withStatus: ConversionState) {
    switch withStatus {
    case .ready:      
      selectOutputFileUrl(format: outputFormat)
      
      // If the user had previously canceled a conversion, this will be set to true. Reset it to false to ensure the conversion completion block executes properly.
      resetProgressBar()
      
      // Note that we check this after resetting the app state. This prevents the user from mistaking a previously shown "Done 🚀" message with the state of the canceled conversion. If we checked this before resetting the progress bar, a user may think the conversion they canceled was actually done, since the done message from the previous conversion would still be shown.
      if outputFileUrl == nil {
        Logger.warning("User canceled output file selection, skipping conversion")
        return
      }
      
      if inputFileUrl!.path == outputFileUrl!.path {
        self.errorAlert(withMessage: "Input and output file names are the same. Please choose a different name.")
        return
      }
      
      startConversion()
      actionButton.title = "Stop"
      currentStatus = .converting
    case .converting:
      userDidClickStop()
      actionButton.title = "Convert"
      currentStatus = .ready
    }
  }
  
  /// Called when a conversion process is completed and the app's state needs to be reset
  func resetActionButton() {
    actionButton.title = "Convert"
    currentStatus = .ready
  }
  
  /// Called when the user clicks "Stop" upon a conversion-in-progress
  func userDidClickStop() {
    FFmpegKit.cancel()
  }
  
  func startConversion() {
    var analyticsTimer = Timer()
    
    self.inputVideo = getAllVideoProperties(inputFilePath: inputFileUrl!.path)
    
    self.startOfConversion = Date()
    self.ffmpegCommand = getFfmpegCommand(inputVideo: inputVideo!, outputFilePath: outputFileUrl!.path)
    
    let ffmpegSession = runFfmpegCommand(command: ffmpegCommand!) { session in
      let returnCode = session!.getReturnCode()
      analyticsTimer.invalidate()
      
      DispatchQueue.main.async {
        // Reference: https://github.com/tanersener/ffmpeg-kit-test/blob/main/macos/test-app-cocoapods/FFmpegKitMACOS/CommandViewController.m
        if returnCode!.isValueCancel() {
          self.updateProgressBar(value: 0)
          self.estimatedTimeText.stringValue = "Canceled ⚠️"
        }
        else if returnCode!.isValueError() {
          self.updateProgressBar(value: 100)
          self.estimatedTimeText.stringValue = "Error ⛔️"

          let ffmpegSessionLogs = session!.getAllLogsAsString().trimmingCharacters(in: .whitespacesAndNewlines)
          let ffprobeOutput = getFfprobeOutput(inputFilePath: self.inputFileUrl!.path)
          
          self.unexpectedErrorAlert(ffmpegCommand: self.ffmpegCommand!, ffmpegSessionLogs: ffmpegSessionLogs, ffprobeOutput: ffprobeOutput, inputFilePath: self.inputFileUrl!.path, outputFilePath: self.outputFileUrl!.path)
        }
        else {
          self.updateProgressBar(value: 100)
          self.estimatedTimeText.stringValue = "Done 🚀"
          self.alertConversionDidComplete(withOutputPath: self.outputFileUrl!)
        }
        
        self.resetActionButton()
        self.outputFileUrl = nil
        self.isTimeRemainingStable = false
        self.inputVideo = nil
        self.startOfConversion = nil
        self.ffmpegCommand = nil
        
        // In case the conversion finished before the time remaining was estimated
        self.estimatedTimeLabel.stringValue = Constants.estimatedTimeLabelText
      }
    }
    
    estimatedTimeLabel.stringValue = Constants.estimatingTimeLabelText
    
    // This currently updates progress every 0.5 seconds
    analyticsTimer = Timer.scheduledTimer(withTimeInterval: Constants.progressUpdateInterval, repeats: true, block: { _ in
      
      if let statisticsArray = ffmpegSession.getStatistics() as? [Statistics], statisticsArray.count > 0 {
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
    
    estimatedTimeLabel.stringValue = Constants.estimatedTimeLabelText
    
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
    savePanel.nameFieldStringValue = inputFileUrl!.deletingPathExtension().lastPathComponent // Input file name with extension removed
    
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
    Logger.error("Unable to read selected format type\nReturning default type: VideoFormat.mp4")
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

  /// Update progress bar animation with Double value
  func updateProgressBar(value: Double, withInterval: Double = 0.5) {
    progressBar.animate(to: value)
  }
  
  func resetProgressBar() {
    updateProgressBar(value: 0)
    estimatedTimeText.stringValue = "–:–"
  }
  
  
  
  // MARK: Clear Input File Button
  /// Clear the input file and revert UI to default state; hide clearInputFileButton when complete
  @IBAction func clearInputFile(_ sender: Any) {
    updateDragDrop(withStyle: .empty)
    inputFileUrl = nil
    displayClearButton(.hide)   // Hide clear button
  }
  /// Set the display state of clearInputFileButton: `.hide` or `.show`
  func displayClearButton(_ state: ObjectDisplay) {
    switch state {
    case .show: clearInputFileButton.alphaValue = 0.6   // Default dim appearance
    case .hide: clearInputFileButton.alphaValue = 0
    }
  }
  
  
  
  // MARK: Popovers
  /// Initialize popover to call `SupportedFormatsViewController`
  lazy var supportedFormatsPopover: NSPopover = {
    let popover = NSPopover()
    popover.behavior = .semitransient
    popover.contentViewController = SupportedFormatsViewController()
    popover.delegate = self
    popover.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
    return popover
  }()
  /// Displays `supportedFormatsPopover` to maxX-position of `dragDropView`
  func showSupportedFormatsPopover() {
    let positioningView = dragDropView!
    let positioningRect = NSZeroRect
    let preferredEdge = NSRectEdge.maxX
    supportedFormatsPopover.show(relativeTo: positioningRect, of: positioningView, preferredEdge: preferredEdge)
  }
  /// Initialize popover to call `HelpInfoViewController`
  lazy var helpInfoPopover: NSPopover = {
    let popover = NSPopover()
    popover.behavior = .semitransient
    popover.contentViewController = HelpInfoViewController()
    popover.delegate = self
    popover.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
    return popover
  }()
  /// Displays `helpInfoPopover` to minY-position of object sender: `(?)`
  @IBAction func showHelpInfoPopover(sender: NSButton) {
    if (helpInfoPopover.isShown) {
      hidePopover(helpInfoPopover)
    } else {
      let positioningView = sender
      let positioningRect = NSZeroRect
      let preferredEdge = NSRectEdge.minY
      helpInfoPopover.show(relativeTo: positioningRect, of: positioningView, preferredEdge: preferredEdge)
    }
  }
  /// Hide specific NSPopover object
  func hidePopover(_ popover: NSPopover) {
    if popover.isShown {
      popover.performClose(nil)
    }
  }
  /// Obj-C compatible function for dismissing supportedFormatsPopover from delegate
  func hideSupportedFormatsPopover() {
    hidePopover(supportedFormatsPopover)
  }
  func hideHelpInfoPopover() {
    hidePopover(helpInfoPopover)
  }
  
}

enum ObjectDisplay {
  case show, hide
}

enum ConversionState {
  case ready
  case converting
}


