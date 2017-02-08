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
    
    var loadingView: UIView?
    
    // Screen size
    var width: CGFloat = 0.0
    var height: CGFloat = 0.0
    
    var spotsLoaded: Bool = false
    
    let radius: Double = 172
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        width = view.bounds.width
        height = view.bounds.height
        
        NotificationCenter.default.addObserver(self, selector: #selector(foundNearbySpots(_:)), name: NSNotification.Name(rawValue: "FoundNearbySpots"), object: nil)
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        if !spotsLoaded {
            showLoadingLocations()
            self.view.layoutIfNeeded()
            if let loadingView = loadingView {
                UIView.animate(withDuration: 0.5, animations: {
                    loadingView.alpha = 1.0
                })
            }
        }
    }
    
    func setupMap() {
        mapView = MKMapView()
        mapView.delegate = self
        view.addSubview(mapView)
        mapView.frame = CGRect(x: 0, y: 20, width: width, height: height-20)
    }

    
    func centerMapOnLocation(_ location: CLLocation) {
        let regionRadius: CLLocationDistance = 150
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func showLoadingLocations() {
        
        let loadingContainer = UIView()
        view.addSubview(loadingContainer)
        loadingContainer.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        let contentWidth: CGFloat = 225
        let loadingContent = UIView()
        loadingContainer.addSubview(loadingContent)
        loadingContent.backgroundColor = UIColor.black
        loadingContent.layer.cornerRadius = 12
        loadingContent.layer.masksToBounds = true
        loadingContent.frame = CGRect(x: (width - contentWidth)/2, y: (height - contentWidth)/2, width: contentWidth, height: contentWidth)
        
        let headerLabel = UILabel()
        loadingContent.addSubview(headerLabel)
        headerLabel.text = "Loading Parking Spots"
        headerLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 15.0)
        headerLabel.textColor = UIColor.white
        headerLabel.numberOfLines = 1
        headerLabel.adjustsFontSizeToFitWidth = false
        let headerSize = headerLabel.attributedText!.size()
        headerLabel.frame = CGRect(x: (contentWidth - headerSize.width)/2, y: 7.5, width: headerSize.width, height: headerSize.height)
        
        let activity = UIActivityIndicatorView()
        loadingContent.addSubview(activity)
        activity.activityIndicatorViewStyle = .white
        activity.startAnimating()
        activity.frame = CGRect(x: (contentWidth - activity.bounds.width)/2, y: (contentWidth - activity.bounds.height)/2, width: activity.bounds.width, height: activity.bounds.height)
        
        loadingContainer.alpha = 0
        loadingView = loadingContainer
    }
    
    func dismissLoadingView() {
        guard let loadingView = loadingView else { return }
        UIView.animate(withDuration: 0.5, animations: {
            loadingView.alpha = 0
        }, completion: {action in
        
            for subview in loadingView.subviews {
                subview.removeFromSuperview()
            }
            loadingView.removeFromSuperview()
            self.loadingView = nil
            
            let targetDate = Date(timeIntervalSinceNow: 3600)
            getLocationsWithinRadius(from: self.currentLocation.placemark.location!, locationSet: self.parkingSpots, radius: self.radius, withinDate: targetDate)
            
        })
    }
    
    func showNearbyCoordinatesOnMap(_ spots: [ParkingSpot]) {
        
        for spot in spots {
            let location = CLLocation(latitude: spot.latitude, longitude: spot.longitude)
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {placemarks, error in
                
                if let placemarks = placemarks {
                    if let placemark = placemarks.first {
                        let annotation = MKPointAnnotation()
                        
                        annotation.coordinate = (placemark.location?.coordinate)!
                        
                        self.mapView.addAnnotation(annotation)
                        
                    }
                }
                
            })
        }
    }
    
    func foundNearbySpots(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            for (_, spots) in userInfo {
                let nearby = spots as! [ParkingSpot]
                showNearbyCoordinatesOnMap(nearby)
            }
        }
    }
    
}

// MARK: - MapViewDelegate
extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        
    }
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
                    
                    self.centerMapOnLocation(placemark.location!)
                    
                }
            }
        })
        
    }

    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}

// MARK: - APIManagerDelegate
extension ViewController: APIManagerDelegate {
    func errorWithGETRequest() {
        
    }
    func parkingSpotsRetrieved(spots: [ParkingSpot]) {
        spotsLoaded = true
        parkingSpots = spots
        dismissLoadingView()
    }
}
