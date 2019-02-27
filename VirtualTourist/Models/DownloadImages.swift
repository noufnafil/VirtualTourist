//
//  DownloadImages.swift
//  VirtualTourist
//
//  Created by nouf alharbi on 2/19/19.
//  Copyright © 2019 nouf alharbi. All rights reserved.
//

import Foundation
import UIKit

class DownloadImages {
    
    static func getImage(imageURL: URL) -> UIImage {
        
        let image = try! UIImage(data: Data(contentsOf: imageURL))
        
        return image!
    }
}
