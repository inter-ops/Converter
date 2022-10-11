//
//  String+Extensions.swift
//  Converter
//
//  Created by Justin Bush on 10/10/22.
//

import Foundation

extension String {
  /// Returns a URL that references the local file or directory at path. Mostly used for String-URL interpolation within other String extensions (see String+Extensions.swift).
  var fileURL: URL {
    return URL(fileURLWithPath: self)
  }
  /// Returns the *lowercased* path extension of a String.
  ///
  /// ```
  /// let fileUrl = "path/to/video.MP4"
  /// fileUrl.pathExtension // "mp4"
  /// ```
  var pathExtension: String {
    return fileURL.pathExtension.lowercased()
  }
  /// Returns the last path component of a String.
  ///
  /// ```
  /// let fileUrl = "path/to/video.mp4"
  /// fileUrl.lastPathComponent // "video.mp4"
  /// ```
  var lastPathComponent: String {
    return fileURL.lastPathComponent
  }
  
}
