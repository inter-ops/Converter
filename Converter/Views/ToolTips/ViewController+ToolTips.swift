//
//  ViewController+ToolTips.swift
//  Converter
//
//  Created by Justin Bush on 11/24/22.
//

import Cocoa

extension ViewController {
  
  func initToolTips() {
    formatDropdown.toolTip = formatDropdownToolTip
    codecDropdown.toolTip = codecDropdownToolTip
    qualityDropdown.toolTip = qualityDropdownToolTip
  }
  
  var formatDropdownToolTip: String {
    return UiToolTips.formatDropdown
  }
  
  var codecDropdownToolTip: String {
    return UiToolTips.codecDropdown
  }
  
  var qualityDropdownToolTip: String {
    if outputCodec == .prores {
      return UiToolTips.proResQualityDropdown
    }
    return UiToolTips.defaultQualityDropdown
  }
  
  
  struct UiToolTips {
    
    static let formatDropdown =
      """
      The output container format.
      
      Depending on your usage, MP4 is generally the most compatible format.
      """
    
    static var codecDropdown =
      """
      Determines the encoder used to convert your video.
      
      • Auto (default): Our smart algorithms will automatically determine the most ideal codec for both quality and compatibility. Prioritizes transmuxing when available.
      
      • H.264: The most compatible codec available. Good quality with average file size. Recommended for 1080p content.
      
      • H.265 (HEVC): The most powerful codec available with built-in HDR and 10-bit color range. Compatible with the Apple TV 4K and later. Recommended for 4K content.
      
      Transmuxing is the process of swapping your video's container to a different format, without the need to encode the entire media file. This preserves both quality and file size, while bringing it to a more compatible medium.
      """
    
    static var defaultQualityDropdown =
      """
      Determines the target output quality for your video.
      
      • Better Quality: Targets the highest possible quality, at the expense of a larger file size.
      
      • Balanced (default): Maintains an appropriate balance between both quality and file size. The most ideal option.
      
      • Smaller Size: Targets a smaller file size, at the expense of overall quality.
      """
    
    static var proResQualityDropdown =
      """
      Apple ProRes codecs provide an unparalleled combination of multistream, real-time editing performance, impressive image quality, and reduced storage rates. Apple ProRes codecs take full advantage of multicore processing and feature fast, reduced-resolution decoding modes.
      
      Auto (default): Selects the most optimal codec based on the input file.
      
      See the Apple ProRes resource in the Help menu to learn more.
      """
      
  }
  
}
