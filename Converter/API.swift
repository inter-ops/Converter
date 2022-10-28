//
//  API.swift
//  Converter
//
//  Created by Francesco Virga on 2022-10-01.
//

import Foundation

func sendPostRequest(url: String, data: Dictionary<String, AnyObject>, completion: @escaping (_ responseData: Dictionary<String, AnyObject>?, _ errorMessage: String?) -> Void) {
  Logger.debug("Sending POST request")
  
  var request = URLRequest(url: URL(string: url)!)
  request.httpMethod = "POST"
  request.httpBody = try? JSONSerialization.data(withJSONObject: data, options: [])
  request.addValue("application/json", forHTTPHeaderField: "Content-Type")
  
  let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
    Logger.debug("Received an API response")
    
    // This occurs if the dataTask fails to execute (eg network cuts out or is too slow).
    if error != nil {
      Logger.error("Data task failed to execute")
      return completion(nil, error!.localizedDescription)
    }
    
    let httpResponse = response as! HTTPURLResponse
    let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type") ?? ""
    
    var jsonData: Dictionary<String, AnyObject> = [:]
    
    if contentType.hasPrefix("application/json") && data!.count > 0 {
      do {
        jsonData = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
      } catch {
        // TODO: Report error, this should never happen
        Logger.error("Error with deserializing response data \(error)")
        return completion(jsonData, "Something went wrong, please try again.")
      }
    }
    
    if httpResponse.statusCode > 299 {
      if let errorMessage = jsonData["error"] as? String {
        return completion(jsonData, errorMessage)
      }
      else {
        // TODO: Report error
        // This means an error occurred but wasn't formatted by our backend error formatter, so likely caused at the GCP level.
        Logger.error("Unknown error returned from API: \(jsonData)")
        return completion(jsonData, "Something went wrong, please try again.")
      }
    }
    
    completion(jsonData, nil)
  })
  
  task.resume()
}

struct API {
  
  static func contactForm(name: String, email: String, topic: String, message: String, completion: @escaping (_ responseData: Dictionary<String, AnyObject>?, _ errorMessage: String?) -> Void) {
    let params = ["name":name, "email":email, "topic": topic, "message": message] as Dictionary<String, AnyObject>
    
    sendPostRequest(url: Constants.API.contactFormUrl, data: params, completion: completion)
  }
  
  static func errorReport(name: String, email: String, additionalDetails: String, inputVideos: [Video], applicationLogs: String?, completion: @escaping (_ responseData: Dictionary<String, AnyObject>?, _ errorMessage: String?) -> Void) {
    
    var videosData = [] as [Dictionary<String, AnyObject>]
    
    var sanitizedApplicationLogs = applicationLogs
    
    inputVideos.forEach { inputVideo in
      let inputFilePath = inputVideo.filePath
      let outputFilePath = inputVideo.outputFilePath
      
      // Remove current input and output file paths from application logs. This is done for all videos, whether errored or not.
      sanitizedApplicationLogs = sanitizedApplicationLogs != nil ? sanitizeFilePaths(textToSanitize: sanitizedApplicationLogs!, inputFilePath: inputFilePath, outputFilePath: outputFilePath) : nil
      
      // Skip videos that did not have errors
      if !inputVideo.didError {
        return
      }
      
      let sanitizedFfmpegCommand = sanitizeFilePaths(textToSanitize: inputVideo.ffmpegCommand!, inputFilePath: inputFilePath, outputFilePath: outputFilePath)
      let sanitizedFfmpegSessionLogs = sanitizeFilePaths(textToSanitize: inputVideo.ffmpegSessionLogs!, inputFilePath: inputFilePath, outputFilePath: outputFilePath)
      let sanitizedFfprobeOutput = sanitizeFilePaths(textToSanitize: inputVideo.ffprobeOutput, inputFilePath: inputFilePath, outputFilePath: outputFilePath)

      let inputFileExtension = URL(fileURLWithPath: inputFilePath).pathExtension
      let outputFileExtension = URL(fileURLWithPath: outputFilePath).pathExtension
      
      let videoData = ["ffmpegCommand": sanitizedFfmpegCommand, "ffmpegSessionLogs": sanitizedFfmpegSessionLogs, "ffprobeOutput": sanitizedFfprobeOutput, "inputFileExtension": inputFileExtension, "outputFileExtension": outputFileExtension] as Dictionary<String, AnyObject>
      
      videosData.append(videoData)
    }
    
    
    
    // TODO: Change API to accept an array of videos
    
    var params = ["name":name, "email":email, "additionalDetails": additionalDetails, "videos": videosData, "applicationLogs": sanitizedApplicationLogs ?? ""] as Dictionary<String, AnyObject>
    
    sendPostRequest(url: Constants.API.errorReportUrl, data: params, completion: completion)
  }
}

// This should be moved to a util if it needs to be used elsewhere.
func sanitizeFilePaths(textToSanitize: String, inputFilePath: String, outputFilePath: String) -> String {
  return textToSanitize.replacingOccurrences(of: inputFilePath, with: "{{ input-path }}").replacingOccurrences(of: outputFilePath, with: "{{ output-path }}")
}



