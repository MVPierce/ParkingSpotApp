//
//  APIManager.swift
//  ParkingSpotApp
//
//  Created by Pierce on 2/7/17.
//  Copyright © 2017 Pierce. All rights reserved.
//

import Foundation

typealias response = ([NSMutableDictionary], Error?) -> ()

class APIManager {
    
    let apiURL = "http://ridecellparking.herokuapp.com/api/v1/parkinglocations"
    
    weak var delegate: APIManagerDelegate?
    
    func makeGETRequest(path: String, onCompletion: @escaping response) {
        let request = NSMutableURLRequest(url: NSURL(string: path)! as URL) as URLRequest
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            // Handle error
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    self.delegate?.errorWithGETRequest()
                }
                return
            }
           
            
            let jsonObject:[NSMutableDictionary]? = (try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)) as! [NSMutableDictionary]?
            
            if let jsonObject = jsonObject {
                onCompletion(jsonObject, error)
            }
        })
        
        task.resume()
    }
    
    func getParkingLocations() {
        getJSONData { locations in
            DispatchQueue.main.async {
                self.delegate?.parkingSpotsRetrieved(spots: self.parseLocations(locations))
            }
        }
    }
    
    func getJSONData(onCompletion: @escaping ([NSMutableDictionary]) -> Void) {
        
        makeGETRequest(path: apiURL, onCompletion: { json, error in
            if error == nil {
               
                onCompletion(json)
            } else {
                
                DispatchQueue.main.async {
                    
                    self.delegate?.errorWithGETRequest()
                    
                }
            }
        })
        
    }
    
    func parseLocations(_ spotsFromAPIRequest: [NSMutableDictionary]) -> [ParkingSpot] {
        
        var parkingSpots:[ParkingSpot] = []
        
        for location in spotsFromAPIRequest {
            
            // Create a new Parking Spot object
            let spot = ParkingSpot()
            
            spot.name = location["name"] as! String
            spot.id = location["id"] as! Int
            spot.isReserved = location["is_reserved"] as! Bool
            spot.latitude = (location["lat"] as! NSString).doubleValue
            spot.longitude = (location["lng"] as! NSString).doubleValue
            spot.maxReserveTimeMins = location["max_reserve_time_mins"] as! Int
            spot.minReserveTimeMins = location["min_reserve_time_mins"] as! Int
            spot.reservedUntil = stringToDate(location["reserved_until"] as? String)
            
            // Append spot
            parkingSpots.append(spot)
        }
        
        return parkingSpots
    }

    let stringToDate = { (date: String?) -> Date? in
        // Check if it's nil (JSON objects will pass <null> as nil)
        guard let date = date, date != "<null>" else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.date(from: date)
    }
}

protocol APIManagerDelegate: class {
    func errorWithGETRequest()
    func parkingSpotsRetrieved(spots: [ParkingSpot])
}
