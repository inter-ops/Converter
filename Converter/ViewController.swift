//
//  ViewController.swift
//  Converter
//
//  Created by Justin Bush on 8/12/22.
//

import Cocoa
import ffmpegkit

class ViewController: NSViewController, NSPopoverDelegate, DragDropViewDelegate {
  
  /// Set to `true` if user has purchased premium
  //var userDidPurchasePremium = false
  
  /// Set to `true` to hide the expandable button, as well as all the premium features
  var isPremiumHiddenFromApp = false // false will also isPremiumEnabled = true
  /// Set to `true` to enable all premium UI components
  var isPremiumEnabled = false
  
  @IBOutlet weak var mainView: NSView!
  @IBOutlet weak var formatDropdown: NSPopUpButton!
  @IBOutlet weak var progressBar: ColorfulProgressIndicator!
  @IBOutlet weak var actionButton: NSButton!
  @IBOutlet weak var estimatedTimeText: NSTextField!
  @IBOutlet weak var estimatedTimeLabel: NSTextField!
  
  @IBOutlet weak var expandCollapsePremiumViewButton: NSButton!
  var premiumViewIsExpanded = false
  var dragDropBoxStyleState: DragDropBox.Style = .regular
  
  // DragDropView objects
  @IBOutlet weak var dragDropBackgroundImageView: NSImageView!
  @IBOutlet weak var dragDropIconImageView: NSImageView!
  @IBOutlet weak var dragDropTopTitle: NSTextField!
  @IBOutlet weak var dragDropBottomTitle: NSTextField!
  @IBOutlet weak var clearInputFileButton: NSButton!
  @IBOutlet weak var showInputFilesButton: NSButton!
  
  // PremiumView: Video
  @IBOutlet weak var expandablePremiumView: NSView!
  @IBOutlet weak var codecDropdown: NSPopUpButton!
  //@IBOutlet weak var gpuCheckbox: NSButton!
  //@IBOutlet weak var qualitySlider: NSSlider!
  @IBOutlet weak var qualityDropdown: NSPopUpButton!
  // PremiumView: Audio
  @IBOutlet weak var copyAllAudioCheckbox: NSButton!
  // PremiumView: Subtitles
  @IBOutlet weak var copyAllSubtitlesCheckbox: NSButton!
  @IBOutlet weak var burnInSubtitleCheckbox: NSButton!
  @IBOutlet weak var burnInSubtitleDropdown: NSPopUpButton!
  
  @IBOutlet weak var formatControlRowView: NSView!
  @IBOutlet weak var actionControlRowView: NSView!
  
  // MARK: ViewConstraints
  @IBOutlet weak var mainViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var mainViewWidthConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var expandCollapsePremiumButtonTrailingConstraint: NSLayoutConstraint!
  
  // PremiumView variables
  var codecTitles: [String] = []

  var qualityTitles: [String] = []
  var copyAllAudioState: NSControl.StateValue = .off      // default unchecked
  var copyAllSubtitlesState: NSControl.StateValue = .off  // default unchecked
  var burnInSubtitleState: NSControl.StateValue = .off    // default unchecked

  // Video object variables
  var outputFormat: VideoFormat = .mp4  //  User select output format (mp4 default)
  var outputCodec: VideoCodec = .h264   // User select output codec (h264 default)
  var outputQuality: VideoQuality = .balanced // User select output quality (balanced default)
  
  var inputVideos: [Video] = []
  var activeVideoIndex: Int?
  
  var isTimeRemainingStable = false
  
  let appDelegate = NSApplication.shared.delegate as! AppDelegate
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Init view
    initMainView()
    initDropdownMenu()
    displayClearButton(.hide)
    initPremiumView()
    updateDragDrop(withStyle: .regular)
  }
  
  func initMainView() {
    mainViewWidthConstraint.constant = Constants.Frame.mainViewWidth
    mainViewHeightConstraint.constant = Constants.Frame.mainViewHeight
    
    expandablePremiumView.isHidden = true
    
    // TODO: Remove once premium is ready for prod
    if isPremiumHiddenFromApp {
      expandCollapsePremiumViewButton.isHidden = true
      expandCollapsePremiumButtonTrailingConstraint.constant = -8
    } else {
      // If premium is shown, enable premium components
      isPremiumEnabled = true
    }
  }
  
  override func viewDidDisappear() {
    hidePopover(supportedFormatsPopover)
    hidePopover(helpInfoPopover)
    hidePopover(multiFilesListPopover)
  }
  
  // TODO: This needs to be accessible even if a file is already selected, only in premium
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
      dragDropViewDidReceive(filePath: path!)
    }
  }
  
  override func viewDidAppear() {
    // Handles opening of file in application on launch after initial load
    DispatchQueue.main.async {
      if self.appDelegate.openAppWithFilePath != nil {
        self.dragDropViewDidReceive(filePath: self.appDelegate.openAppWithFilePath!)
        self.appDelegate.openAppWithFilePath = nil
      }
      self.appDelegate.mainViewHasAppeared = true
    }
  }
  
  
  enum InputFileState {
    case valid, unsupported, corrupt, directory
  }
  
  func validateInputFile(fileUrl: URL) -> InputFileState {
    if fileUrl.isDirectory {
      return .directory
    }
    
    if !VideoFormat.isSupportedAsInput(fileUrl.path) {
      return .unsupported
    }
    
    if !isFileValid(inputFilePath: fileUrl.path) {
      return .corrupt
    }
    
    return .valid
  }
  
  
  func dragDropViewDidReceive(filePath: String) {
    dragDropViewDidReceive(filePaths: [filePath])
  }
  
  // TODO: Disable all UI while this executes and show a loading indicator
  func getVideoPathsInDirectory(baseUrl: URL) -> [String] {
    // https://stackoverflow.com/questions/27721418/getting-list-of-files-in-documents-folder
    // https://stackoverflow.com/questions/57640119/listing-all-files-in-a-folder-recursively-with-swift
    
    var filePaths = [String]()
    if let enumerator = FileManager.default.enumerator(at: baseUrl, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
      
        for case let fileUrl as URL in enumerator {
          do {
            let fileAttributes = try fileUrl.resourceValues(forKeys:[.isRegularFileKey])
            
            if fileAttributes.isRegularFile! && VideoFormat.isSupportedAsInput(fileUrl.path) {
              filePaths.append(fileUrl.path)
            }
          } catch {
            Logger.error("Error getting resource values for file \(fileUrl.path): \(error.localizedDescription)")
          }
        }
      }
    
    
    return filePaths
  }
  
  // TODO: If a user clears or replaces the current input files during a multi-file conversion, it crashes the app. The dragdrop box and the clear button should be disabled during processing.
  
  /// Handles multiple input file requests, checks for validity and adjust the dragDropBackgroundImageView box to reflect any errors
  func dragDropViewDidReceive(filePaths: [String]) {
    Logger.debug("Processing input paths: \(filePaths)")
    
    resetProgressBar()
    
    // Clear existing input videos
    if inputVideos.count > 0 {
      inputVideos = []
    }
    
    var filteredPaths: [String] = []
    
    for filePath in filePaths {
      let inputFileUrl = filePath.fileURL.absoluteURL
      
      switch validateInputFile(fileUrl: inputFileUrl) {
      case .unsupported:
        showUnsupportedFileTypeBox()
        return
      case .corrupt:
        showCorruptVideoFileBox()
        return
      case .directory:
        let directoryPaths = getVideoPathsInDirectory(baseUrl: inputFileUrl)
        
        if filteredPaths.count + directoryPaths.count > Constants.fileCountLimit {
          showTooManyInputVideosBox()
          return
        }
        
        filteredPaths.append(contentsOf: directoryPaths)
        break
      case .valid:
        if filteredPaths.count + 1 > Constants.fileCountLimit {
          showTooManyInputVideosBox()
          return
        }
        
        filteredPaths.append(filePath)
        break
      }
    }
    
    // This means the user passed in a directory, but after traversing the directory we did not find any supported files
    if filteredPaths.isEmpty {
      showNoSupportedFilesBox()
      return
    }
    
    // if premium, handle multi-file
    if isPremiumEnabled {
      // TODO: Add a loading animation for this and disable UI, it can be slow with 100 files. If we want to let the user still interact with the UI, we could use ffprobe.executeAsync for these calls.
      for filePath in filteredPaths {
        addVideoToInputs(filePath: filePath)
      }
    }
    else {
      // if free user, route first dragged file to singular dragDropDidReceive
      addVideoToInputs(filePath: filteredPaths[0])
      // TODO: show notice: maximum one file input, upgrade for more
      //premiumNotice()
    }
    
    updateDragDrop(selectedVideos: inputVideos, icon: .videoFile, withStyle: .regular)
  }
  
  /// Handles singular input file requests, checks for validity and adjust the dragDropBackgroundImageView box to reflect any errors
  func addVideoToInputs(filePath: String) {
    let inputFileUrl = filePath.fileURL.absoluteURL
    let inputVideo = getAllVideoProperties(inputFileUrl: inputFileUrl)
    inputVideos.append(inputVideo)
  }
  
  /// Clears input videos and hides clearInputFileButton
  func clearInputVideos() {
    inputVideos = []
    clearInputFileButton.alphaValue = 0
  }
  
  // TODO: The updateDragDrop functions have become way too multi purpose and muddled. We should rething the abstractions and split them up better
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
  func updateDragDrop(title: String = "", subtitle: String = "", selectedVideos: [Video] = [], icon: DragDropBox.Icon = .empty, withStyle: DragDropBox.Style) {
    dragDropBoxStyleState = withStyle
    if withStyle == .regular && (title.isEmpty && subtitle.isEmpty) && selectedVideos.count == 0 {
      updateDragDrop(title: topTitleString, subtitle: "or double click to browse...", icon: .empty, withStyle: .regular)
    } else {
      
      updateDragDropView(withStyle)
      
      if selectedVideos.count > 1 {
        updateDragDropTitle(bottom: "\(inputVideos.count) videos selected")
        dragDropIconImageView.image = DragDropBox.getMultiVideoFileIcons(forCount: selectedVideos.count)
        showInputFilesButton.isHidden = false // Button to show list of multiple files
        displayClearButton(.show)
        
        // TODO: For now we're just setting the file name to the list of files, but we should come up with a cleaner way to do this.
        let videoFilesList = inputVideos.map { $0.filePath.lastPathComponent }
        DragDropBox.videoFilesList = videoFilesList
      }
      else if selectedVideos.count == 1 {
        updateDragDropTitle(bottom: selectedVideos[0].filePath.lastPathComponent)
        dragDropIconImageView.image = icon.image
        showInputFilesButton.isHidden = true  // Button to show list of multiple files
        displayClearButton(.show)
      }
      else {
        updateDragDropTitle(title, bottom: subtitle)
        dragDropIconImageView.image = icon.image
        // hide button
        showInputFilesButton.isHidden = true
      }
    }
  }
  /// Sets the DragDropBox top title string depending on premium status
  var topTitleString: String {
    if isPremiumEnabled {
      return "Drag and drop your videos here"
    } else {
      return "Drag and drop your video here"
    }
  }
  /// Obj-C compatible function for passing updateDragDop through delegate
  func updateDragDrop(title: String, subtitle: String, withWarning: Bool) {
    if withWarning {
      updateDragDrop(title: title, subtitle: subtitle, icon: .warning, withStyle: .warning)
    } else {
      updateDragDrop(title: title, subtitle: subtitle, icon: .videoFile, withStyle: .regular)
      hidePopover(supportedFormatsPopover)
    }
  }
  /// Sets the dragDropBox image view (ie. Set red warning box with `.warning`)
  func updateDragDropView(_ forType: DragDropBox.Style) {
    if premiumViewIsExpanded {
      dragDropBackgroundImageView.image = forType.backgroundImageWide
    } else {
      dragDropBackgroundImageView.image = forType.backgroundImage
    }
  }
  /// Sets the dragDropBox title text without affecting the box style (ie. `bottom: inputFileName`)
  func updateDragDropTitle(_ top: String = "", bottom: String = "") {
    if !top.isEmpty { dragDropTopTitle.stringValue = top }
    if !bottom.isEmpty { dragDropBottomTitle.stringValue = bottom }
  }
  /// Sets DragDropBox for error state: Unsupported file type
  func showUnsupportedFileTypeBox() {
    Logger.debug("Displaying unsupported file error")
    clearInputVideos()
    updateDragDrop(subtitle: "Unsupported file type", withStyle: .warning)
    showSupportedFormatsPopover()
  }
  /// Sets DragDropBox for error state: Corrupted video file
  func showCorruptVideoFileBox() {
    Logger.debug("Displaying corrupt file error")
    clearInputVideos()
    updateDragDrop(subtitle: "Video file is corrupt", withStyle: .warning)
  }
  
  /// Sets DragDropBox for error state: No supported files found in input directory
  func showNoSupportedFilesBox() {
    Logger.debug("Displaying no supported files error")
    clearInputVideos()
    updateDragDrop(subtitle: "No supported files we're found", withStyle: .warning)
    showSupportedFormatsPopover()
  }
  
  /// Sets DragDropBox for error state: Too many input videos
  func showTooManyInputVideosBox() {
    Logger.debug("Displaying too many videos error")
    clearInputVideos()
    updateDragDrop(subtitle: "Too many videos selected (maximum \(Constants.fileCountLimit))", withStyle: .warning)
  }
  
  /// Returns VideoFormat type upon user dropdown selection (ie. `.mp4`)
  func userDidSelectFormat(_ format: VideoFormat) {
    // Update outputFormat to selected item
    outputFormat = format
    
    Logger.debug("User selected output format: \(format.rawValue)")
    
    // Set default codec for new format type (if premium)
    didSelectNewOutput(format: format)
  }
  
  
  // TODO: These methods should be moved to a util
  func getEstimatedTotalConversionTime(statistics: Statistics, timeElapsed: Double) -> Double {
    let videoTime = Double(statistics.getTime())/1000
    let totalConversionTime = timeElapsed * (self.inputVideos[self.activeVideoIndex!].duration / videoTime)
    return totalConversionTime
  }
  
  /// Calculates the video conversion progress in percentage.
  func getProgressPercentage(statistics: Statistics, startOfConversion: Date) -> Double {
    let timeElapsed = startOfConversion.timeIntervalSinceNow * -1
    let totalConversionTime = getEstimatedTotalConversionTime(statistics: statistics, timeElapsed: timeElapsed)
    
    let progressPercentage = (timeElapsed / totalConversionTime) * 100
    return progressPercentage
  }
  
  /// Calculates an estimated time remaining for the active video conversion.
  func getEstimatedTimeRemaining(statistics: Statistics, startOfConversion: Date, progressPercentage: Double) -> Double {
    let timeElapsed = startOfConversion.timeIntervalSinceNow * -1
    let totalConversionTime = getEstimatedTotalConversionTime(statistics: statistics, timeElapsed: timeElapsed)
    
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
    
    let inputVideo = inputVideos[activeVideoIndex!]
    let startOfConversion = inputVideo.startOfConversion!
    
    let progressPercentage = getProgressPercentage(statistics: statisticsArray[statisticsArray.count-1], startOfConversion: startOfConversion)
    let timeRemaining = getEstimatedTimeRemaining(statistics: statisticsArray[statisticsArray.count-1], startOfConversion: startOfConversion, progressPercentage: progressPercentage)
    
    let lastProgressPercentage = getProgressPercentage(statistics: statisticsArray[statisticsArray.count-2], startOfConversion: startOfConversion)
    let lastTimeRemaining = getEstimatedTimeRemaining(statistics: statisticsArray[statisticsArray.count-2], startOfConversion: startOfConversion, progressPercentage: lastProgressPercentage)
    
    // Since the last statistic will have been checked Constants.progressUpdateInterval earlier then the current one, we need to adjust it for comparison
    let adjustedLastTimeRemaining = lastTimeRemaining - Constants.progressUpdateInterval
    
    // We determine the time remaining to be stable if timeRemaining and adjustedTimeRemaining are within 20% of each other, or if we've already processed more than 20% of the video (we should have a stable time by this point, if we don't it means the video is processing quickly)
    self.isTimeRemainingStable = (max(timeRemaining, adjustedLastTimeRemaining) / min(timeRemaining, adjustedLastTimeRemaining) < 1.2) || progressPercentage > 20
  }
  
  /// Determines the state of the conversion process for the Action button (ie. if `.ready`, the app is ready to begin the process; if `.converting`, the app is undergoing conversion
  var currentStatus: ConversionState = .ready
  /// Triggers the action button handler if there exists a valid input file; if no input exists, show an error
  func userDidClickActionButton() {
    if inputVideos.count == 0 {
      updateDragDrop(subtitle: "Please select a file first", withStyle: .warning)
    } else {
      handleActionButton(withStatus: currentStatus)
    }
  }
  
  func configureOutputDirectory(outputDirectory: URL, inputBaseDirectory: String, inputSubdirectories: [String]) {
    do {
      // Create output directory
      try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: false)
      
      // Create output subdirectories
      for dir in inputSubdirectories {
        // If we remove baseDirectory from the path, we now have a file path relative to the baseDirectory
        let relativePath = dir.replacingOccurrences(of: inputBaseDirectory, with: "")
        
        // Append the relative directory to our outputDirectory and we get an absolute path
        let directoryToCreate = outputDirectory.appendingPathComponent(relativePath)
        
        try FileManager.default.createDirectory(at: directoryToCreate, withIntermediateDirectories: false)
      }
    } catch {
      // TODO: Handle this better
      self.errorAlert(withMessage: "Something went wrong!\n\(error.localizedDescription)")
      return
    }
  }
  
  
  /// Handles the action button states, and their respective actions, based on the current ConversionState: `.ready` or `.converting`
  func handleActionButton(withStatus: ConversionState) {
    switch withStatus {
    case .ready:
      if inputVideos.count > 1 {
        let userSelectedOutputDirectory = selectOutputDirectory()
        if userSelectedOutputDirectory == nil {
          self.errorAlert(withMessage: "You must select an output file path to add this file.")
          return
        }
        
        let dateString = Date().iso8601withFractionalSeconds
        // TODO: Clean generated title up
        let generatedOutputDirectory = "Video-Converter-\(dateString)"
        
        let outputDirectory = userSelectedOutputDirectory!.appendingPathComponent(generatedOutputDirectory)
        
        // This is a set of directories that we need to create in our output folder. We use a set to avoid duplication.
        var inputSubdirectories: Set<String> = []
        
        for inputVideo in inputVideos {
          let parentDirectory = inputVideo.fileUrl.deletingLastPathComponent()
          
          inputSubdirectories.insert(parentDirectory.path)
        }
      
        // Sort paths based on length, shorted first
        var sortedInputDirectories = inputSubdirectories.sorted(by: { $0.count < $1.count })
        
        // This will be the base directory that all selected input files are in. We remove this from sortedDirectories since we don't need to create this one in the output directory. The `outputDirectory` URL that we created a file for above takes the place of this directory.
        let inputBaseDirectory = sortedInputDirectories.removeFirst()
        
        // Generate the output directory and create any subdirectories it needs. This way we can freely generate output files without worrying about a subdirectory missing.
        configureOutputDirectory(outputDirectory: outputDirectory, inputBaseDirectory: inputBaseDirectory, inputSubdirectories: sortedInputDirectories)
        
        var startMessage = "Converting input videos\n"
        self.inputVideos.enumerated().forEach { (i, inputVideo) in
        
          // Replace input file extension with output extension and remove the base dir to turn into a relative path
          let relativeOutputPath = inputVideo.fileUrl
              .deletingPathExtension()
              .appendingPathExtension(outputFormat.rawValue).path
              .replacingOccurrences(of: inputBaseDirectory, with: "")
            
          let outputFileUrl = outputDirectory.appendingPathComponent(relativeOutputPath)
          
          inputVideos[i].outputFileUrl = outputFileUrl
          startMessage += "\(i+1). \(inputVideo.filePath) -> \(outputFileUrl.path)\n"
        }
        Logger.info(startMessage)
      }
      else {
        let outputFileUrl = selectOutputFileUrl(format: outputFormat, inputFileUrl: inputVideos[0].fileUrl)
        inputVideos[0].outputFileUrl = outputFileUrl
      }
      
      startConversion(activeVideoIndex: 0)
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
  
  func setEstimatedTimeLabel(_ label: String) {
    if inputVideos.count > 1 && activeVideoIndex != nil {
      self.estimatedTimeLabel.stringValue = "(\(activeVideoIndex!+1)/\(inputVideos.count)) \(label)"
    }
    else {
      self.estimatedTimeLabel.stringValue = label
    }
  }
  
  func startConversion(activeVideoIndex: Int) {
    resetProgressBar()
    var analyticsTimer = Timer()
    
    self.activeVideoIndex = activeVideoIndex
    let ffmpegCommand = getFfmpegCommand(inputVideo: inputVideos[activeVideoIndex])
    self.inputVideos[activeVideoIndex].startOfConversion = Date()
    self.inputVideos[activeVideoIndex].ffmpegCommand = ffmpegCommand
    
    let ffmpegSession = runFfmpegCommand(command: ffmpegCommand) { session in
      let returnCode = session!.getReturnCode()
      analyticsTimer.invalidate()
      
      DispatchQueue.main.async {
        // Reference: https://github.com/tanersener/ffmpeg-kit-test/blob/main/macos/test-app-cocoapods/FFmpegKitMACOS/CommandViewController.m
        
        if returnCode!.isValueCancel() {
          self.updateProgressBar(value: 0)
          self.estimatedTimeText.stringValue = "Canceled ⚠️"
          self.activeVideoIndex = nil
          return
        }
        
        self.updateProgressBar(value: 100)
        self.isTimeRemainingStable = false
        // In case the conversion finished before the time remaining was estimated
        self.setEstimatedTimeLabel(Constants.estimatedTimeLabelText)
        
        let isLastVideo = self.activeVideoIndex == self.inputVideos.count-1
        self.inputVideos[self.activeVideoIndex!].isComplete = true
        
        if returnCode!.isValueError() {
          let ffmpegSessionLogs = session!.getAllLogsAsString().trimmingCharacters(in: .whitespacesAndNewlines)
          self.inputVideos[self.activeVideoIndex!].ffmpegSessionLogs = ffmpegSessionLogs
          self.inputVideos[self.activeVideoIndex!].didError = true
          // We don't use the main logger for this because we don't want to crowd application logs with ffmpeg logs. Instead
          // we just print out so that we can see the error in the Xcode console.
          if Config.shared.debug {
            print("Error from ffmpeg command: \(ffmpegSessionLogs)")
          }
          
          // TODO: Show error toast
          self.estimatedTimeText.stringValue = "Error ⛔️"
        }
        else {
          // TODO: Show success toast
          self.estimatedTimeText.stringValue = "Done 🚀"
        }
        
        if isLastVideo {
          self.activeVideoIndex = nil
          self.resetActionButton()
          
          if !self.inputVideos.allSatisfy({ $0.didError == false }) {
            self.estimatedTimeText.stringValue = "Error ⛔️"
            self.unexpectedErrorAlert(inputVideos: self.inputVideos)
          }
          else {
            if self.inputVideos.count > 1 {
              let parentDir = self.inputVideos[0].outputFileUrl!.deletingLastPathComponent()
              self.alertConversionDidComplete(withOutputUrl: parentDir)
            }
            else {
              self.alertConversionDidComplete(withOutputUrl: self.inputVideos[0].outputFileUrl!)
            }
            
          }
        }
        else {
          self.startConversion(activeVideoIndex: activeVideoIndex + 1)
        }
        
      }
    }
    
    setEstimatedTimeLabel(Constants.estimatingTimeLabelText)
    
    // This currently updates progress every 0.5 seconds
    analyticsTimer = Timer.scheduledTimer(withTimeInterval: Constants.progressUpdateInterval, repeats: true, block: { _ in
      
      if let statisticsArray = ffmpegSession.getStatistics() as? [Statistics], statisticsArray.count > 0 {
        // This must be called before updateTimeRemaining to ensure we know whether the time remaining is stable or not.
        self.checkStabilityOfTimeRemaining(statisticsArray: statisticsArray)
        
        let lastStatistics = statisticsArray[statisticsArray.count - 1]
        
        let startOfConversion = self.inputVideos[self.activeVideoIndex!].startOfConversion!
        let progressPercentage = self.getProgressPercentage(statistics: lastStatistics, startOfConversion: startOfConversion)
        let timeRemaining = self.getEstimatedTimeRemaining(statistics: lastStatistics, startOfConversion: startOfConversion, progressPercentage: progressPercentage)
        
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
    
    setEstimatedTimeLabel(Constants.estimatedTimeLabelText)
    
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
  
  func selectOutputDirectory() -> URL? {
    let savePanel = NSOpenPanel()
    savePanel.canCreateDirectories = true
    savePanel.canChooseDirectories = true
    savePanel.canChooseFiles = false
    savePanel.title = "Save your videos"
    savePanel.message = "Choose a directory for your converted videos"
    
    savePanel.isExtensionHidden = true
    
    let response = savePanel.runModal()
    if response == .OK {
      return savePanel.url!
    }
    else {
      return nil
    }
  }
  
  func selectOutputFileUrl(format: VideoFormat, inputFileUrl: URL) -> URL? {
    let savePanel = NSSavePanel()
    savePanel.canCreateDirectories = true
    savePanel.title = "Save your video"
    savePanel.message = "Choose a name for your converted video:"
    savePanel.nameFieldLabel = "Video file name:"
    savePanel.nameFieldStringValue = inputFileUrl.deletingPathExtension().lastPathComponent // Input file name with extension removed
    
    savePanel.allowedFileTypes = [format.rawValue]
    savePanel.allowsOtherFileTypes = false
    savePanel.isExtensionHidden = true
    
    let response = savePanel.runModal()
    if response == .OK {
      return savePanel.url!
    }
    else {
      return nil
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
  // selectFormat(sender:)
  var userSelectedFormat = VideoFormat.mp4.dropdownTitle
  var userSelectedFormatType: VideoFormat = .mp4
  // selectCodec(sender:)
  var userSelectedCodec = VideoCodec.h264.dropdownTitle
  var userSelectedCodecType: VideoCodec = .h264
  // selectQuality(sender:)
  var userSelectedQuality = VideoQuality.balanced.dropdownTitle
  var userSelectedQualityType: VideoQuality = .balanced
  
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
    setEstimatedTimeLabel(Constants.estimatedTimeLabelText)
    estimatedTimeText.stringValue = "–:–"
  }
  
  // TODO: Rename to clearAllInputFiles
  
  // MARK: Clear Input File Button
  /// Clear the input file and revert UI to default state; hide clearInputFileButton when complete
  @IBAction func clearInputFile(_ sender: Any) {
    updateDragDrop(icon: .empty, withStyle: .regular)
    inputVideos = []
    resetProgressBar()
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
  /// Displays `supportedFormatsPopover` to maxX-position of `dragDropBackgroundImageView`
  func showSupportedFormatsPopover() {
    let positioningView = dragDropBackgroundImageView!
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
  /// Initialize popover to call `MultiFilesListViewController`
  lazy var multiFilesListPopover: NSPopover = {
    let popover = NSPopover()
    popover.behavior = .semitransient
    popover.contentViewController = MultiFilesListViewController()
    popover.delegate = self
    popover.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
    return popover
  }()
  /// Displays `multiFilesListPopover` to minY-position of object sender: `(?)`
  @IBAction func showMultiFileListPopover(sender: NSButton) {
    if (multiFilesListPopover.isShown) {
      hidePopover(multiFilesListPopover)
    } else {
      let positioningView = sender
      let positioningRect = NSZeroRect
      let preferredEdge = NSRectEdge.minY
      multiFilesListPopover.show(relativeTo: positioningRect, of: positioningView, preferredEdge: preferredEdge)
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
  func hideMultiFilesListPopover() {
    hidePopover(multiFilesListPopover)
  }
  
}

enum ObjectDisplay {
  case show, hide
}

enum ConversionState {
  case ready
  case converting
}
