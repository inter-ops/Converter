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

enum DragDropBoxWindowState {
  case regular, wide
}

enum DragDropBoxStyle {
  
  case regular, warning
  
  var backgroundImage: NSImage {
    switch self {
    case .regular: return NSImage(named: "dbox-default")!
    case .warning: return NSImage(named: "dbox-red")!
    }
  }
  
  var backgroundImageWide: NSImage {
    switch self {
    case .regular: return NSImage(named: "dbox-default-wide")!
    case .warning: return NSImage(named: "dbox-red-wide")!
    }
  }
  
}

enum DragDropBoxIcon {
  
  case empty, warning, videoFile//, videoFileTwo, videoFileThree, videoFileFour, videoFilePlus
  
  var image: NSImage {
    switch self {
    case .empty:      return NSImage(named: "dbox-icon-empty")!
    case .warning:    return NSImage(named: "dbox-icon-warning")!
    case .videoFile:  return NSImage(named: "dbox-icon-videofile")!
    }
  }
  
}
