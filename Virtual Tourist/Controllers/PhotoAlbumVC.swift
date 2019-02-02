//
//  PhotoAlbumVC.swift
//  Virtual Tourist
//
//  Created by Saud Alhelali on 02/02/2019.
//  Copyright © 2019 Saud Alhelali. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumVC: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var pin: Pin?
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    var album: [Photo] = [Photo]()
    var totalPages: Int? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateFlowLayout(view.frame.size)
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        
        // Get pin sent from travel map
        guard let pin = pin else {
            return
        }
        
        showOnTheMap(pin)
        setupFetchedResultControllerWith(pin)
        
        if !refreshImageSet() {
            // pin selected has no photos stored
            fetchPhotosFromAPI(pin)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        updateFlowLayout(size)
    }
    
    func refreshImageSet() -> Bool {
        // Get photos from core data
        let photoSet: NSSet? = pin?.photos
        if photoSet != nil && photoSet?.count ?? 0 > 0 {
            album = Array(photoSet!) as! [Photo]
            self.collectionView.reloadData()
            return true
        }
        return false
    }
    
    // MARK: - Helpers
    private func setupFetchedResultControllerWith(_ pin: Pin) {
        let fr: NSFetchRequest<Photo> = Photo.fetchRequest()
        fr.sortDescriptors = []
        fr.predicate = NSPredicate(format: "pin == %@", argumentArray: [pin])
        
        // Create FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: DataController.shared.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        // Start FetchedResultsController
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("\(#function) Error performing initial fetch: \(error)")
        }
    }
    
    private func showOnTheMap(_ pin: Pin) {
        let lat = Double(pin.latitude!)!
        let lon = Double(pin.longitude!)!
        let locCoord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locCoord
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
        mapView.setCenter(locCoord, animated: true)
    }
    
    private func fetchPhotosFromAPI(_ pin: Pin) {
        let lat = Double(pin.latitude!)!
        let lon = Double(pin.longitude!)!
        
        Network.shared().searchBy(latitude: lat, longitude: lon, totalPages: totalPages) { (photosParsed, error) in
            if let photosParsed = photosParsed {
                self.totalPages = photosParsed.photos.pages
                let totalPhotos = photosParsed.photos.photo.count
                print("\(#function) Downloading \(totalPhotos) photos.")
                self.performUIUpdatesOnMain {
                    self.storePhotos(photosParsed.photos.photo, forPin: pin)
                    self.refreshImageSet()
                    self.collectionView.reloadData()
                }
            } else if let error = error {
                print("\(#function) error:\(error)")
                self.showInfo(withTitle: "Error", withMessage: error.localizedDescription)
            }
        }
    }
    
    private func storePhotos(_ photos: [PhotoParser], forPin: Pin) {
        for photo in photos {
            if let url = photo.url {
                _ = Photo(title: photo.title, imageUrl: url, forPin: forPin, context: DataController.shared.context)
                self.save()
            }
        }
    }
    
    @IBAction func newCollection(_ sender: Any) {
        for photo in album {
            // Remove existing images
            DataController.shared.context.delete(photo)
        }
        save()
        fetchPhotosFromAPI(pin!)
    }
    
}
