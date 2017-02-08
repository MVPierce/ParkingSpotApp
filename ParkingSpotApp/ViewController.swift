//
//  ViewController.swift
//  ParkingSpotApp
//
//  Created by Pierce on 2/7/17.
//  Copyright © 2017 Pierce. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {

    var mapView: MKMapView!
    
    var apiManager: APIManager!
    
    var parkingSpots: [ParkingSpot]!
    
    let locationManager = CLLocationManager()
    
    var currentLocation = MKMapItem()
    
    // Screen size
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        width = view.bounds.width
        height = view.bounds.height
        
        apiManager = APIManager()
        apiManager.delegate = self
        apiManager.getParkingLocations()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.requestLocation()
        }
        
        setupMap()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupMap() {
        mapView = MKMapView()
        mapView.delegate = self
        view.addSubview(mapView)
        mapView.frame = CGRect(x: 0, y: 20, width: width, height: height-20)
    }


}

// MARK: - MapViewDelegate
extension ViewController: MKMapViewDelegate {
    
}

// MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CLGeocoder().reverseGeocodeLocation(locations.last!, completionHandler: {(placemarks:[CLPlacemark]?, error:Error?) in
            if let placemarks = placemarks {
                if let placemark = placemarks.first {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = (placemark.location?.coordinate)!
                    
                    self.currentLocation = MKMapItem(placemark: MKPlacemark(coordinate: placemark.location!.coordinate, addressDictionary: placemark.addressDictionary as! [String:AnyObject]?))
                    
                    self.mapView.addAnnotation(annotation)
                    
                    
                }
            }
        })
        
    }

}

// MARK: - APIManagerDelegate
extension ViewController: APIManagerDelegate {
    func errorWithGETRequest() {
        
    }
    func parkingSpotsRetrieved(spots: [ParkingSpot]) {
        parkingSpots = spots
    }
}
