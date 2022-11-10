//
//  Date.swift
//  Converter
//
//  Created by Francesco Virga on 2022-10-06.
//

import Foundation

extension ISO8601DateFormatter {
  convenience init(_ formatOptions: Options) {
    self.init()
    self.formatOptions = formatOptions
  }
}

extension Formatter {
  static let iso8601withFractionalSeconds = ISO8601DateFormatter([.withInternetDateTime, .withFractionalSeconds])
}

extension Date {
  var iso8601withFractionalSeconds: String { return Formatter.iso8601withFractionalSeconds.string(from: self) }
  
  func stringFormat(_ format: String) -> String {
    let dateformat = DateFormatter()
    dateformat.dateFormat = format
    return dateformat.string(from: self)
  }
}
