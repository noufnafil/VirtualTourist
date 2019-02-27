//
//  APIHelper.swift
//  VirtualTourist
//
//  Created by nouf alharbi on 2/19/19.
//  Copyright © 2019 nouf alharbi. All rights reserved.
//

import Foundation

class APIHelper {
    
    static func getMethod(_ url: URL, headerValues: [String : String]?, callingMethodName: String = #function, resultHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        
     
            
      
 
        let request = NSMutableURLRequest(url: url)
        
        request.httpMethod = "GET"
        
        // Add additional header values
        if headerValues != nil {
            for header in headerValues! {
                request.addValue(header.0, forHTTPHeaderField: header.1)
            }
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            guard error == nil else {
                resultHandler(nil, Errors.createError(error: "Create session error. '\(error.debugDescription)'", domain: "getMethod"))
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                statusCode >= 200 && statusCode <= 299 else {
                    resultHandler(nil, Errors.createError(error: "Response status code not 2xx.", domain: "getMethod"))
                    return
            }
            
            guard data != nil else {
                resultHandler(nil, Errors.createError(error: "Session created, but no data was retrieved from the server.", domain: "getMethod"))
                return
            }
            
            do {
                let parsedData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : AnyObject]
                
                resultHandler(parsedData as AnyObject?, nil)
            }catch {
                resultHandler(nil, Errors.createError(error: "Cannot parse JSON data.", domain: "stripDataIfRequired"))
                return
            }
        })
        
        task.resume()
        
    }
}
