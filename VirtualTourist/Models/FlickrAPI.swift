//
//  FlickrAPI.swift
//  VirtualTourist
//
//  Created by nouf alharbi on 2/19/19.
//  Copyright © 2019 nouf alharbi. All rights reserved.
//

import Foundation
import UIKit

class FlickrAPI {
    
    static func getPhotoIDsByLocation(latitude: Double, longitude: Double, limit: Int, page: Int = 1, resultHandler: @escaping (_ result: [String]?, _ error: NSError?) -> Void) {
        
        let url = URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&format=json&nojsoncallback=1&api_key=\(Constants.API_KEY)&lat=\(latitude)&lon=\(longitude)&radius=1&page=\(page)")!
        
        APIHelper.getMethod(url, headerValues: nil, resultHandler: { (result, error) in
            
            guard error == nil else {
                resultHandler(nil, error)
                return
            }
            
            // Get the list of photo ID's
            let photos = result?["photos"] as! [String : AnyObject]
            var photo = photos["photo"] as! [AnyObject]
            var photoCount = photo.count
            var photoIDArray = [String]()
            var repeatCount: Int8
            
            repeatCount = Int8((limit < photoCount) ? limit : photoCount)
            
            for _ in 1...repeatCount {
                
                let randomPhotoIndex = arc4random_uniform(UInt32(photoCount))
                
                let obj = photo.remove(at: Int(randomPhotoIndex))
                photoIDArray.append(obj["id"] as! String)
                
                photoCount -= 1
            }
            
            resultHandler(photoIDArray, nil)
        })
    }
    
    static func getPhotoPageCount(latitude: Double, longitude: Double, resultHandler:
        @escaping (_ result: Int?, _ error: NSError?) -> Void ) {
        
        let url = URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&format=json&nojsoncallback=1&api_key=\(Constants.API_KEY)&lat=\(latitude)&lon=\(longitude)&radius=1")!
        
        APIHelper.getMethod(url, headerValues: nil, resultHandler: { (result, error) in
            
            guard error == nil else {
                resultHandler(nil, error)
                return
            }
            
            // Get photo list page count
            let photos = result?["photos"] as! [String : AnyObject]
            let pageCount = photos["pages"] as! Int
            
            resultHandler(pageCount, nil)
        })
    }
    
    static func getPhotoURL(id: String, resultHandler: @escaping (_ result: String?, _ error: NSError?) -> Void) {
        
        let url = URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.getInfo&format=json&nojsoncallback=1&api_key=\(Constants.API_KEY)&photo_id=\(id)")!
        
        APIHelper.getMethod(url, headerValues: nil, resultHandler: { (result, error) in
            
            guard error == nil else {
                resultHandler(nil, error)
                return
            }
            
            let photo = result?["photo"] as! [String : AnyObject]
            let farm = photo["farm"] as! Int8
            let serverID = photo["server"] as! String
            let id = photo["id"] as! String
            let secret = photo["secret"] as! String
            let url = "https://farm\(farm).staticflickr.com/\(serverID)/\(id)_\(secret).jpg"
            
            resultHandler(url, nil)
        })
    }
}
