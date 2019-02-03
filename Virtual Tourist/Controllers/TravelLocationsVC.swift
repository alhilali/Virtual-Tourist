//
//  TravelLocationsVC.swift
//  Virtual Tourist
//
//  Created by Saud Alhelali on 02/02/2019.
//  Copyright © 2019 Saud Alhelali. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsVC: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var pinAnnotation: MKPointAnnotation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let pins = loadAllPins() {
            showPins(pins)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is PhotoAlbumVC {
            guard let pin = sender as? Pin else {
                return
            }
            let controller = segue.destination as! PhotoAlbumVC
            controller.pin = pin
        }
    }
    
    // MARK: - Helpers
    private func loadAllPins() -> [Pin]? {
        var pins: [Pin]?
        do {
            try pins = DataController.shared.fetchAllPins(entityName: Pin.name)
        } catch {
            print("\(#function) error:\(error)")
            showInfo(withTitle: "Error", withMessage: "Error while fetching locations: \(error)")
        }
        return pins
    }
    
    private func loadPin(latitude: String, longitude: String) -> Pin? {
        let predicate = NSPredicate(format: "latitude == %@ AND longitude == %@", latitude, longitude)
        var pin: Pin?
        do {
            try pin = DataController.shared.fetchPin(predicate, entityName: Pin.name)
        } catch {
            print("\(#function) error:\(error)")
            showInfo(withTitle: "Error", withMessage: "Error while fetching location: \(error)")
        }
        return pin
    }
    
    private func showPins(_ pins: [Pin]) {
        for pin in pins where pin.latitude != nil && pin.longitude != nil {
            let annotation = MKPointAnnotation()
            let lat = Double(pin.latitude!)!
            let lon = Double(pin.longitude!)!
            annotation.coordinate = CLLocationCoordinate2DMake(lat, lon)
            mapView.addAnnotation(annotation)
        }
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    // MARK: - Actions
    @IBAction func addPinGesture(_ sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        if sender.state == .began {
            pinAnnotation = MKPointAnnotation()
            pinAnnotation!.coordinate = coordinate
            
            print("\(#function) Coordinate: \(coordinate.latitude),\(coordinate.longitude)")
            
            mapView.addAnnotation(pinAnnotation!)
        } else if sender.state == .changed {
            pinAnnotation!.coordinate = coordinate
        } else if sender.state == .ended {
            let pin = Pin(context: DataController.shared.context)
            pin.latitude = String(pinAnnotation!.coordinate.latitude)
            pin.longitude = String(pinAnnotation!.coordinate.longitude)
            try? DataController.shared.context.save()
            
        }
    }
    
}

extension TravelLocationsVC {
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
            pinView!.animatesDrop = true
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            self.showInfo(withMessage: "No url.")
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation else {
            return
        }
        
        mapView.deselectAnnotation(annotation, animated: true)
        print("\(#function) lat \(annotation.coordinate.latitude) lon \(annotation.coordinate.longitude)")
        let lat = String(annotation.coordinate.latitude)
        let lon = String(annotation.coordinate.longitude)
        if let pin = loadPin(latitude: lat, longitude: lon) {
            if isEditing {
                mapView.removeAnnotation(annotation)
                DataController.shared.context.delete(pin)
                save()
                return
            }
            performSegue(withIdentifier: "showPhotos", sender: pin)
        }
    }
}
