//
//  LocationController.swift
//  ToiletMaps
//
//  Created by Pieter Paelinck on 27/12/2019.
//  Copyright © 2019 Pieter Paelinck. All rights reserved.
//

import Foundation
import MapKit



struct LocationController {
    
    
    static func getListLocations() -> [Location]{
        var locations : [Location] = []
        
        //Currently inserts dummy data
        locations.append(Location(name: "Toilet 1", coordinates: CLLocationCoordinate2D(latitude: -33.875, longitude: 151.214), free: true))
        locations.append(Location(name: "Toilet 2", coordinates: CLLocationCoordinate2D(latitude: -33.86, longitude: 151.21), free: true))
        locations.append(Location(name: "Toilet 3", locationDescription: "Always out of toilet paper", coordinates: CLLocationCoordinate2D(latitude: -33.85, longitude: 151.20), free: true, babyChangePossible: nil))
        locations.append(Location(name: "Toilet 4", locationDescription: "Closed on weekends", coordinates: CLLocationCoordinate2D(latitude: -33.87, longitude: 151.21), free: false, babyChangePossible: nil))
        locations.append(Location(name: "Toilet 5", locationDescription: "Closed on weekends", coordinates: CLLocationCoordinate2D(latitude: -33.878, longitude: 151.219), free: false, babyChangePossible: nil))
        locations.append(Location(name: "Toilet 6", locationDescription: "Closed on weekends", coordinates: CLLocationCoordinate2D(latitude: -33.870, longitude: 151.216), free: false, babyChangePossible: nil))
        locations.append(Location(name: "Toilet 7", locationDescription: "Closed on weekends", coordinates: CLLocationCoordinate2D(latitude: -33.876, longitude: 151.213), free: true, babyChangePossible: nil))
        
        return locations
    }
    
    static func getLocationFromName(_ name : String) -> Location? {
        let locations = getListLocations()
        var loc : Location?
        for l in locations {
            if l.name.lowercased() == name.lowercased() {
                loc = l
            }
        }
        return loc
    }
    
    //Reverse geocoding for detail page, uses external LocationIQ API because it's free
    static func getAddressForLocation(location : CLLocationCoordinate2D, completion : @escaping (String) -> Void) {
        let APIKey = "4f005bc2e10b73"
        let requestUrl =
            URL(string:"https://eu1.locationiq.com/v1/reverse.php?key=\(APIKey)&lat=\(location.latitude)&lon=\(location.longitude)&format=json")
        
        let addressTask = URLSession.shared.dataTask(with: requestUrl!) {data,response,error  in
            guard let addressJSON = data else {return}
            do {
                let jsonDecoder = JSONDecoder()
                let address = try? jsonDecoder.decode(Address.self, from: addressJSON)
                let addressString = address?.address ?? "Address not found"
                completion(addressString)
            }
        }
        addressTask.resume()
        
    }
}

