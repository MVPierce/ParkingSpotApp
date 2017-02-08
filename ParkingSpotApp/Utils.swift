//
//  Utils.swift
//  ParkingSpotApp
//
//  Created by Pierce on 2/7/17.
//  Copyright © 2017 Pierce. All rights reserved.
//

import Foundation
import CoreLocation

func getLocationsWithinRadius(from: ParkingSpot, locationSet: [ParkingSpot], radius: Double, withinDate: Date?)  {
    DispatchQueue.global(qos: .background).async {
        let nearbySpots = locationSet.filter { from.distance(to: $0) <= radius && ($0.isReserved == false || ( $0.isReserved == true && (withinDate != nil && ($0.reservedUntil! < withinDate!))))} // Find parking spot location within radius that isn't reserved OR isn't reseved during the requested time frame
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "FoundNearbySpots"), object: nil, userInfo:["":nearbySpots])
        }
    }
}

func getLocationsWithinRadius(from: CLLocation, locationSet: [ParkingSpot], radius: Double, withinDate: Date?){
    DispatchQueue.global(qos: .background).async {
        let nearbySpots = locationSet.filter { from.distance(to: $0) <= radius && ($0.isReserved == false || ( $0.isReserved == true && (withinDate != nil && ($0.reservedUntil! < withinDate!))))}
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "FoundNearbySpots"), object: nil, userInfo:["":nearbySpots])
        }
    }
}

func haversineFormulaForDistance(lat1: Double, lon1: Double, lat2: Double, lon2:Double) -> Double {
    
    let R = 6371e3 // Meters 
    let theta1 = lat1.degreesToRadians
    let theta2 = lat2.degreesToRadians
    let deltaTheta = (lat2-lat1).degreesToRadians
    let deltaLambda = (lon2-lon1).degreesToRadians
    let a = sin(deltaTheta/2) * sin(deltaTheta/2) + cos(theta1) * cos(theta2) * sin(deltaLambda/2) * sin(deltaLambda/2)
    let c = 2 * atan2(sqrt(a), sqrt(1-a))
    
    let d = R * c;
    
    return d
}

extension ParkingSpot {
    func distance(to: ParkingSpot) -> Double {
        return haversineFormulaForDistance(lat1: self.latitude, lon1: self.longitude, lat2: to.latitude, lon2: to.longitude)
    }
}

extension CLLocation {
    func distance(to: ParkingSpot) -> Double {
        return haversineFormulaForDistance(lat1: self.coordinate.latitude, lon1: self.coordinate.longitude, lat2: to.latitude, lon2: to.longitude)
    }
}

extension CLLocationCoordinate2D {
    func isApproximated(to: CLLocationCoordinate2D, discretion: Double) -> Bool {
        // ∑ is margin for error in checking coordinates
        let E:Double = 0.0003 - (discretion * 0.0001)
        return (fabs(self.latitude - to.latitude) <= E && (fabs(self.longitude - to.longitude) <= E))
    }
}


extension Double {
    var degreesToRadians: Double { return self * .pi / 180 }
    var radiansToDegrees: Double { return self * 180 / .pi }
    var metersToMilesReadable: Double {
        return self/1609.34
    }
}
