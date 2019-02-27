//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by nouf alharbi on 2/19/19.
//  Copyright © 2019 nouf alharbi. All rights reserved.
//

import Foundation

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var albumCollectionView: UICollectionView!
    @IBOutlet weak var createNewCollectionButton: UIBarButtonItem!
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var photoIDList = [String]()
    var photoURLList = [String]()
    var stack = CoreDataStack.shared
    var pinData: Pin?
    var photoCount: Int = 0
    var photosFromDisk = [UIImage]()
    
    let limit = 50
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        mapView.delegate = self
        albumCollectionView.delegate = self
        albumCollectionView.dataSource = self
        
        mapView.isUserInteractionEnabled = false
        createNewCollectionButton.isEnabled = false 
        
        // Add map pin annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: (pinData?.latitude)!, longitude: (pinData?.longitude)!)
        self.mapView.addAnnotation(annotation)
        
        let center = annotation.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let region = MKCoordinateRegion(center: center, span: span)
        
        mapView.setRegion(region, animated: true)
        mapView.regionThatFits(region)
        
      
            
       
        photoCount = (pinData?.hasPhotos?.count)!
        
        if photoCount > 0 {
            
            let photoObjects = pinData?.hasPhotos?.allObjects
            
            for photoData in photoObjects! {
                
                let photo = photoData as! Photo
                let image = UIImage(data: photo.image! as Data)
                photosFromDisk.append(image!)
            }
            
            self.createNewCollectionButton.isEnabled = true
        } else {
            
            downloadAndDisplayImages()
        }
            
        
        
        
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createNewCollection(_ sender: UIBarButtonItem) {
        
        self.createNewCollectionButton.isEnabled = false
        
        // Reset local variables
        photoIDList = [String]()
        photoURLList = [String]()
        photoCount = 0
        photosFromDisk = [UIImage]()
        
        // Empty associated photos from data model
        let photoSet = pinData?.hasPhotos
        for photo in photoSet! {
            stack.persistentContainer.viewContext.delete(photo as! NSManagedObject)
        }
        
        albumCollectionView.reloadData()
        downloadAndDisplayImages()
    }
    
    func downloadAndDisplayImages() {
        
        //display network activity
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        FlickrAPI.getPhotoPageCount(latitude: self.latitude, longitude: self.longitude, resultHandler: { (pageCount, error) in
            
        
            
            if error != nil {
                AlertMessage.display(con: self, error: "Cannot get photo page count: \(String(describing: error)), \(String(describing: error?._userInfo))")
                return
            }
            
            let randomPage = arc4random_uniform(UInt32(pageCount!) + 1)
            
            FlickrAPI.getPhotoIDsByLocation(latitude: self.latitude, longitude: self.longitude, limit: self.limit, page: Int(randomPage), resultHandler: { (result, error) in
                
                if error != nil {
                    AlertMessage.display(con: self, error: "Cannot get photo IDs: \(String(describing: error)), \(String(describing: error?._userInfo))")
                }
                
                // Inform user no images are available and force dismissal of album view
                if result?.count == 0 {
                    
                    let alertViewController = UIAlertController(title: "", message: "No images available.\n\nLatitude: \(self.latitude)\nLongitude: \(self.longitude)", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alertViewController.addAction(UIAlertAction(title: "Back to Map View", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    
                    self.present(alertViewController, animated: true, completion: nil)
                }
                
                self.photoIDList = result!
                self.photoCount = self.photoIDList.count
                
                DispatchQueue.main.async {
                    self.albumCollectionView.reloadData()
                }
                
                // Get each photo URL by ID
                for id in self.photoIDList {
                    
                    FlickrAPI.getPhotoURL(id: id, resultHandler: { (result, error) in
                        
                        self.photoURLList.append(result!)
                        
                        // Download photo
                        let downloadedPhoto = DownloadImages.getImage(imageURL: URL(string: result!)!)
                        self.photosFromDisk.append(downloadedPhoto)
                        
                        // Add photo data to pin
                        let photo = Photo(context: (self.stack.persistentContainer.viewContext))
                        photo.image = UIImagePNGRepresentation(downloadedPhoto) as NSData?
                        self.pinData?.addToHasPhotos(photo)
                        self.stack.saveContext()
                        
                        DispatchQueue.main.sync {
                            
                            let path = IndexPath(item: self.photosFromDisk.count - 1, section: 0)
                            self.albumCollectionView.reloadItems(at: [path])
                            
                            // Enable create button once downloaded photo count matches expected count
                            if self.photosFromDisk.count == self.photoCount {
                                self.createNewCollectionButton.isEnabled = true
                            }
                        }
                    })
                }
            })
        })
        
        //hide network activity
        UIApplication.shared.isNetworkActivityIndicatorVisible = false

    }
}

extension PhotoAlbumViewController {
    
   
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return photoCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = PhotoCell()
        
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! PhotoCell
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        
        cell.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.015)
        
        if self.photosFromDisk.count >= indexPath.item + 1 {
            DispatchQueue.main.async {
                
                // Display photo
                cell.imageView.image = self.photosFromDisk[indexPath.item]
                print("Index: \(indexPath.item)")
            }
        }else {
            DispatchQueue.main.async {
                cell.imageView.image = nil
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.createNewCollectionButton.isEnabled == false {
            AlertMessage.display(con: self, error: "Please wait until all photos are downloaded before removing one.")
        }else {
            self.photoCount -= 1
            self.photosFromDisk.remove(at: indexPath.item)
            self.albumCollectionView.deleteItems(at: [indexPath])
            
            // Remove from core data model
            let photoObjs = self.pinData?.hasPhotos?.allObjects
            let photoObj = photoObjs?[indexPath.item] as? Photo
            
            stack.persistentContainer.viewContext.delete(photoObj!)
            stack.saveContext()
        }
    }
}
