//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by nouf alharbi on 2/19/19.
//  Copyright © 2019 nouf alharbi. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var stack = CoreDataStack.shared
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        mapView.delegate = self
        self.loadPinData()
        
        let defaults = UserDefaults.standard
        defaults.synchronize()
        
        if let region = defaults.object(forKey: "MapViewRegion") as! [CLLocationDegrees]! {
            
            let center = CLLocationCoordinate2D(latitude: region[0], longitude: region[1])
            let span = MKCoordinateSpan(latitudeDelta: region[2], longitudeDelta: region[3])
            let region = MKCoordinateRegion(center: center, span: span)
            
            mapView.setRegion(region, animated: true)
            mapView.regionThatFits(region)
        }
        
        // Add long-press gesture to map to add pins
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.addAnnotation))
        recognizer.minimumPressDuration = 0.8
        recognizer.allowableMovement = 0.0
        mapView.addGestureRecognizer(recognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        for annotation in mapView.annotations {
            mapView.deselectAnnotation(annotation, animated: false)
        }
    }
    
    func loadPinData() {
        
        let request = Pin.createFetchRequest()
        
        do {
            let pins = try stack.viewContext.fetch(request)
            
            for pin in pins {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
                self.mapView.addAnnotation(annotation)
            }
        } catch {
            AlertMessage.display(con: self, error: "Loading pin data failed.")
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let defaults = UserDefaults.standard
        let region: [CLLocationDegrees] = [self.mapView.region.center.latitude, self.mapView.region.center.longitude, self.mapView.region.span.latitudeDelta, self.mapView.region.span.longitudeDelta]
        defaults.set(region, forKey: "MapViewRegion")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "Pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        
        return pinView
    }
    
    @objc func addAnnotation(gestureRecognizer: UIGestureRecognizer) {
        
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = mapView.convert(gestureRecognizer.location(in: mapView), toCoordinateFrom: mapView)
            self.mapView.addAnnotation(annotation)
            
            // Add pin data
            let pin = Pin(context: (stack.persistentContainer.viewContext))
            pin.latitude = annotation.coordinate.latitude
            pin.longitude = annotation.coordinate.longitude
            stack.saveContext()
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        var controller = PhotoAlbumViewController()
        controller = self.storyboard?.instantiateViewController(withIdentifier: "photoAlbumView") as! PhotoAlbumViewController
        
        controller.latitude = (view.annotation?.coordinate.latitude)! as Double
        controller.longitude = (view.annotation?.coordinate.longitude)! as Double
        
        // Fetch current pin data
        let request = Pin.createFetchRequest()
        
        do {
            let pins = try (stack.persistentContainer.viewContext).fetch(request)
            
            for pin in pins {
                
                if pin.latitude == controller.latitude && pin.longitude == controller.longitude {
                    
                    controller.pinData = pin
                    break
                }
            }
        } catch {
            AlertMessage.display(con: self, error: "Cannot fetch pin data: \(error), \(String(describing: error._userInfo))")
        }
        
        self.present(controller, animated: true, completion: nil)
    }
}

