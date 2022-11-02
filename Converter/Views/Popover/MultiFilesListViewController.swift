//
//  MultiFilesListViewController.swift
//  Converter
//
//  Created by Justin Bush on 11/2/22.
//

import Cocoa

class MultiFilesListViewController: NSViewController {
  
  @IBOutlet weak var multiFilesListView: NSTextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  override func viewDidAppear() {
    updateMultiFilesListView()
  }
  
  func updateMultiFilesListView() {
    var outputString = ""
    
    for file in DragDropBox.videoFilesList {
      outputString.append("\(file)\n")
    }
    
    multiFilesListView.stringValue = outputString
    multiFilesListView.font = .monospacedSystemFont(ofSize: 12, weight: .medium)
  }
  
}
