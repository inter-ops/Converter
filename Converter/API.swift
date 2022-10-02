//
//  API.swift
//  Converter
//
//  Created by Francesco Virga on 2022-10-01.
//

import Foundation

let contactFormUrl = "https://contact-form-u7kjuwr4da-uc.a.run.app"
let errorReportUrl = "https://error-report-u7kjuwr4da-uc.a.run.app"


func sendPostRequest(url: String, data: Dictionary<String, AnyObject>, completion: @escaping (_ responseData: Dictionary<String, AnyObject>?, _ errorMessage: String?) -> Void) {
  print("Sending POST request")
  
  var request = URLRequest(url: URL(string: url)!)
  request.httpMethod = "POST"
  request.httpBody = try? JSONSerialization.data(withJSONObject: data, options: [])
  request.addValue("application/json", forHTTPHeaderField: "Content-Type")
  
  let task = URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
    if error != nil {
      print("Error sending HTTP request \(error!.localizedDescription)")
      // TODO: Return proper error message
      completion(nil, "Error with request")
      return
    }
    
    // TODO: Return an error to display to user
    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
      print("Error with the response, unexpected status code: \(response)")
      // TODO: Return proper error message
      completion(nil, "Error with request")
      return
    }
    
    if data!.count > 0 {
      do {
        let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
        print("JSON \(json)")
        
        completion(json, nil)
      } catch {
        print("Error with deserializing! \(error.localizedDescription)")
        // TODO: Return proper error message
        completion(nil, "Error with request")
      }
    }
    
    completion(nil, nil)
  })
  
  task.resume()
}

struct API {
  
  static func contactForm(name: String, email: String, topic: String, message: String, completion: @escaping (_ responseData: Dictionary<String, AnyObject>?, _ errorMessage: String?) -> Void) {
    let params = ["name":name, "email":email, "topic": topic, "message": message] as Dictionary<String, AnyObject>
    
    sendPostRequest(url: contactFormUrl, data: params, completion: completion)
  }
  
  static func errorReport(name: String, email: String, errorMessage: String, additionalDetails: String, ffprobeOutput: String, applicationLogs: String?, completion: @escaping (_ responseData: Dictionary<String, AnyObject>?, _ errorMessage: String?) -> Void) {
    let params = ["name":name, "email":email, "errorMessage": errorMessage, "additionalDetails": additionalDetails, "ffprobeOutput": ffprobeOutput, "applicationLogs": applicationLogs] as Dictionary<String, AnyObject>
    
    sendPostRequest(url: errorReportUrl, data: params, completion: completion)
  }

}



