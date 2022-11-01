//
//  DragDropBox.swift
//  Converter
//
//  Created by Justin Bush on 8/17/22.
//

import Cocoa

struct DragDropBox {
  
  enum Style {
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
  
  
  
  enum Icon {
    case empty, warning, videoFile
    
    var image: NSImage {
      switch self {
      case .empty:      return NSImage(named: "dbox-icon-empty")!
      case .warning:    return NSImage(named: "dbox-icon-warning")!
      case .videoFile:  return NSImage(named: "dbox-icon-videofile")!
      }
    }
    
  }
  
  static func getMultiVideoFileIcons(forCount: Int) -> NSImage {
    if forCount > 9 {
      return NSImage(named: "dbox-icon-videofiles-10")!
    } else {
      return NSImage(named: "dbox-icon-videofiles-\(forCount)")!
    }
  }
  
}
