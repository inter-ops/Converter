//
//  WebView+Extensions.swift
//  Converter
//
//  Created by Justin Bush on 11/4/22.
//

import Foundation
import WebKit

// MARK: WKWebView
extension WKWebView {
  /// Quick and short load URL String in a WKWebView
  func load(_ string: String) {
    if let url = URL(string: string) {
      let request = URLRequest(url: url)
      load(request)
    }
  }
  /// Quick and short load URL in a WKWebView
  func load(_ url: URL) {
    let request = URLRequest(url: url)
    load(request)
  }
}
