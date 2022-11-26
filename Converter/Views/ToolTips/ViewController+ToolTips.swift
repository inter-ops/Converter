//
//  ViewController+ToolTips.swift
//  Converter
//
//  Created by Justin Bush on 11/24/22.
//

import Cocoa

extension ViewController {
  
  enum ElementToolTips: String {
    case formatDropdown
    case codecDropdown
    case qualityDropdown
    
    var stringValue: String {
      switch self {
      case .formatDropdown: return
        """
        The intended output container format. Depending on your usage, MP4 is generally the most compatible format.
        """
      case .codecDropdown: return
        """
        Determines the encoder used to convert your video file. Auto selected by default.
        
        • Auto (default): Allow our smart algorithms to automatically determine the most ideal codec for both quality and compatibility.
        """
      case .qualityDropdown: return
        """
        Determines the target output quality for your video file. Balanced selected by default.
        
        • Better Quality: Targets the highest possible quality, at the expense of a larger file size.
        
        • Balanced (default): Maintains an appropriate balance between both quality and file size. The most ideal option.
        
        • Smaller Size: Targets a smaller file size, at the expense of overall quality.
        """
      }
    }
  }
  
  func initToolTips() {
    formatDropdown.toolTip = ElementToolTips.formatDropdown.stringValue
    codecDropdown.toolTip = ElementToolTips.codecDropdown.stringValue
    qualityDropdown.toolTip = ElementToolTips.qualityDropdown.stringValue
  }
  
}
