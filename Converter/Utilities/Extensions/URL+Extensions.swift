//
//  URL+Extensions.swift
//  Converter
//
//  Created by Francesco Virga on 2022-11-09.
//

import Foundation

extension URL {
  func createDirectory() {
    Logger.debug("Creating directory")
    
    do {
      try FileManager.default.createDirectory(at: self, withIntermediateDirectories: true)
    } catch {
      Logger.error("Error creating directory: \(error.localizedDescription)")
    }
  }
}
