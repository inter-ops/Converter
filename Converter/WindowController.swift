//
//  WindowController.swift
//  Converter
//
//  Created by Justin Bush on 10/24/22.
//

import Cocoa

class WindowController: NSWindowController {
  
  let minWindowWidth = Constants.Frame.mainViewWidth
  let minWindowHeight = Constants.Frame.mainViewHeight + 22 // Custom window with size for title bar
  
  let minViewWidth = Constants.Frame.mainViewWidth
  let minViewHeight = Constants.Frame.mainViewHeight
  
  override func windowDidLoad() {
    super.windowDidLoad()
    
    // initWindowRect()
    
  }
  
  override func windowWillLoad() {
    // setWindowAppearance()
    // initResizeConstraints()
  }
  
}
