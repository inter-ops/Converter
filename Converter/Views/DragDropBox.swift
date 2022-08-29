//
//  DragDropBox.swift
//  Converter
//
//  Created by Justin Bush on 8/17/22.
//

import Cocoa

enum DragDropBox {
  
  case empty
  case videoFile
  case warning
  
  var image: NSImage {
    switch self {
    case .empty:        return NSImage(named: "DragDropBox-Icon")!
    case .videoFile:    return NSImage(named: "DragDropBox-Icon-Selected")!
    case .warning:      return NSImage(named: "DragDropBox-Warning")!
    }
  }
  
}
