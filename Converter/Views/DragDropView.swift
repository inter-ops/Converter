//
//  DragDropView.swift
//  Converter
//
//  Created by Justin Bush on 8/16/22.
//
//  Ref: https://stackoverflow.com/questions/31657523/get-file-path-using-drag-and-drop-swift-macos
//

import Cocoa

@objc protocol DragDropViewDelegate {
  func dragDropViewDidReceive(fileUrl: String)
}

class DragDropView: NSView {
  
  @IBOutlet weak var delegate: DragDropViewDelegate?
  @IBOutlet weak var topTextField: NSTextField!
  @IBOutlet weak var bottomTextField: NSTextField!
  
  var filePath: String?
  let expectedExt = Format.supported //supportedFormats
  
  let clearColor = NSColor.clear.cgColor
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    wantsLayer = true
    layer?.backgroundColor = clearColor //NSColor.gray.cgColor
    registerForDraggedTypes([NSPasteboard.PasteboardType.URL, NSPasteboard.PasteboardType.fileURL])
  }
  
  override func mouseDown(with event: NSEvent) {
    let clickCount: Int = event.clickCount
    
    if clickCount > 1 {
      selectInputFileUrl()
    }
  }
  
  func selectInputFileUrl() {
    let openPanel = NSOpenPanel()
    
    // TODO: Restrict allowed file types
    openPanel.allowsMultipleSelection = false
    openPanel.canChooseDirectories = true
    openPanel.canCreateDirectories = true
    openPanel.canChooseFiles = true
    
    let response = openPanel.runModal()
    if response == .OK {
      let path = openPanel.url!.absoluteString
      delegate?.dragDropViewDidReceive(fileUrl: path)
      // Set bottomTextField to equal filename
      
      updateTextField(bottom: path.lastPathComponent)
    }
  }
  
  override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
    if checkExtension(sender) == true {
      layer?.backgroundColor = NSColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor //NSColor.blue.cgColor
      return .copy
    } else {
      return NSDragOperation()
    }
  }
  
  fileprivate func checkExtension(_ drag: NSDraggingInfo) -> Bool {
    guard let board = drag.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
          let path = board[0] as? String
    else { return false }
    
    let testFilePath = path.lowercased()
    if Format.isSupported(testFilePath) {
      return true
    }
    return false
    
//    let suffix = URL(fileURLWithPath: path).pathExtension
//    for ext in self.expectedExt {
//      if ext.lowercased() == suffix {
//        return true
//      }
//    }
//    return false
  }
  
  override func draggingExited(_ sender: NSDraggingInfo?) {
    layer?.backgroundColor = clearColor //NSColor.gray.cgColor
  }
  
  override func draggingEnded(_ sender: NSDraggingInfo) {
    layer?.backgroundColor = clearColor //NSColor.gray.cgColor
  }
  
  override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
    guard let pasteboard = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
          let path = pasteboard[0] as? String
    else { return false }
    
    filePath = path
    delegate?.dragDropViewDidReceive(fileUrl: path)
    
    // Set bottomTextField to equal filename
    updateTextField(bottom: path.lastPathComponent)
    
    return true
  }
  
  func updateTextField(top: String = "", bottom: String) {
    if !top.isEmpty { topTextField.stringValue = top }
    if !bottom.isEmpty { bottomTextField.stringValue = bottom }
  }
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    // Drawing code here.
  }
  
}

extension String {
  var fileURL: URL { return URL(fileURLWithPath: self) }
  var pathExtension: String { return fileURL.pathExtension.lowercased() }
  var lastPathComponent: String { return fileURL.lastPathComponent }
}
