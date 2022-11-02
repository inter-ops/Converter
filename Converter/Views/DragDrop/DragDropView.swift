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
  func dragDropViewDidReceive(filePath: String)
  func dragDropViewDidReceive(filePaths: [String])
  func updateDragDrop(title: String, subtitle: String, withWarning: Bool)
  func showSupportedFormatsPopover()
  func hideSupportedFormatsPopover()
  func openFileBrowser()
}

class DragDropView: NSView {
  
  @IBOutlet weak var delegate: DragDropViewDelegate?
  
  var filePath: String?
  var filePaths: [String]?
  
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
      delegate?.openFileBrowser()
    }
  }

  override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
    if checkExtension(sender) == true {
      layer?.backgroundColor = NSColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor //NSColor.blue.cgColor
      delegate?.hideSupportedFormatsPopover()
      return .copy
    } else {
      layer?.backgroundColor = NSColor(red: 225, green: 0, blue: 0, alpha: 0.2).cgColor
      delegate?.updateDragDrop(title: "", subtitle: "Unsupported file type", withWarning: true)
      delegate?.showSupportedFormatsPopover()
      return NSDragOperation()
    }
  }
  
  fileprivate func checkExtension(_ drag: NSDraggingInfo) -> Bool {
    guard let board = drag.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
          let path = board[0] as? String
    else { return false }
    
    let testFilePath = path.lowercased()
    return VideoFormat.isSupportedAsInput(testFilePath)
  }
  
  override func draggingExited(_ sender: NSDraggingInfo?) {
    layer?.backgroundColor = clearColor //NSColor.gray.cgColor
  }
  
  override func draggingEnded(_ sender: NSDraggingInfo) {
    layer?.backgroundColor = clearColor //NSColor.gray.cgColor
  }
  
  override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
    // TODO: If the user draps multiple files, show an error
    guard let pasteboard = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
          let path = pasteboard[0] as? String,
          let filePaths = pasteboard as? [String]
    else { return false }
    
    filePath = path
    delegate?.dragDropViewDidReceive(filePaths: filePaths)
    
    return true
  }
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    // Drawing code here.
  }
  
}
