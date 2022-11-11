//
//  ProcessLoader.swift
//  Converter
//
//  Created by Justin Bush on 11/11/22.
//

import Cocoa

extension ViewController {
  
  func showProcessLoaderAnimation() {
    indeterminateProgressBar.startAnimation(self)
    indeterminateProgressBar.isHidden = false
  }
  
  func hideProcessLoaderAnimation() {
    indeterminateProgressBar.isHidden = true
    indeterminateProgressBar.stopAnimation(self)
  }
  
}
