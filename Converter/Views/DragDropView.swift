//
//  DragDropView.swift
//  Converter
//
//  Created by Justin Bush on 8/16/22.
//
//  Ref: https://stackoverflow.com/questions/31657523/get-file-path-using-drag-and-drop-swift-macos
//

import Cocoa

@objc protocol DragViewDelegate {
  func dragViewDidReceive(fileURLs: [URL])
}

class DragDropView: NSView {
  
  var filePath: String?
  let expectedExt = supportedFormats
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    wantsLayer = true
    layer?.backgroundColor = NSColor.gray.cgColor
    registerForDraggedTypes([NSPasteboard.PasteboardType.URL, NSPasteboard.PasteboardType.fileURL])
  }
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    // Drawing code here.
  }
  
  override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
    if checkExtension(sender) == true {
      self.layer?.backgroundColor = NSColor.blue.cgColor
      return .copy
    } else {
      return NSDragOperation()
    }
  }
  
  fileprivate func checkExtension(_ drag: NSDraggingInfo) -> Bool {
    guard let board = drag.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
          let path = board[0] as? String
    else { return false }
    
    let suffix = URL(fileURLWithPath: path).pathExtension
    for ext in self.expectedExt {
      if ext.lowercased() == suffix {
        return true
      }
    }
    return false
  }
  
  override func draggingExited(_ sender: NSDraggingInfo?) {
    self.layer?.backgroundColor = NSColor.gray.cgColor
  }
  
  override func draggingEnded(_ sender: NSDraggingInfo) {
    self.layer?.backgroundColor = NSColor.gray.cgColor
  }
  
  override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
    guard let pasteboard = sender.draggingPasteboard.propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
          let path = pasteboard[0] as? String
    else { return false }
    
    //GET YOUR FILE PATH !!!
    self.filePath = path
    Swift.print("FilePath: \(path)")
    
    return true
  }
  
}
