//
//  ParkingSpot.swift
//  ParkingSpotApp
//
//  Created by Pierce on 2/7/17.
//  Copyright © 2017 Pierce. All rights reserved.
//

import UIKit

class ParkingSpot: NSObject {

    // Set up all the properties for a ParkingSpot object
    var id: Int = 0
    var costPerMinute:Double = 0.0
    var isReserved: Bool = false
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var maxReserveTimeMins: Int = 0
    var minReserveTimeMins: Int = 0
    var name: String = ""
    var reservedUntil: Date?
    
}
