//
//  InputMultiFilesListViewController.swift
//  Converter
//
//  Created by Justin Bush on 10/31/22.
//

import Cocoa

class InputMultiFilesListViewController: NSViewController {
  
  @IBOutlet weak var multiFilesListView: NSTextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    var outputString = ""
    
    for file in DragDropBox.videoFilesList {
      outputString.append("\(file)\n")
    }
    
    multiFilesListView.stringValue = outputString
    multiFilesListView.font = .monospacedSystemFont(ofSize: 12, weight: .medium)
  }
  
}
