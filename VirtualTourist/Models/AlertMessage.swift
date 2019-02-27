//
//  AlertMessage.swift
//  VirtualTourist
//
//  Created by nouf alharbi on 2/19/19.
//  Copyright © 2019 nouf alharbi. All rights reserved.
//

import Foundation
import UIKit

class AlertMessage {
    
    static func display(con: UIViewController, error: String) {
        
        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "Done", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(doneAction)
        
        DispatchQueue.main.async {
            con.present(alertController, animated: true, completion: nil)
        }
    }
}
