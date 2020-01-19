//
//  Location.swift
//  ToiletMaps
//
//  Created by Pieter Paelinck on 27/12/2019.
//  Copyright © 2019 Pieter Paelinck. All rights reserved.
//

import Foundation
import MapKit
import RealmSwift
import GLKit
import Darwin

class Location : Object {
    //All realm code/info is from https://realm.io/docs/swift/latest/ or the Realm forums
    @objc dynamic var locationID = UUID().uuidString
    @objc dynamic var name : String = ""
    @objc dynamic var locationDescription : String?
    @objc dynamic var longitude : Double = 0
    @objc dynamic var latitude : Double = 0
    @objc dynamic var free : Bool = true
    let babyChangePossible = RealmOptional<Bool>()
    //  @objc dynamic var genderAllowed : [Gender] = []
    // let genderOptional = RealmOptional<Gender>()

    
    override static func primaryKey() -> String? {
      return "locationID"
    }
    
    init(name : String, locationDescription : String?, coordinates : CLLocationCoordinate2D,free : Bool,babyChangePossible : Bool?) {
        self.name = name
        self.locationDescription = locationDescription
        self.longitude = coordinates.longitude
        self.latitude = coordinates.latitude
        self.free = free
        //self.genderAllowed = genderAllowed
        self.babyChangePossible.value = babyChangePossible
    }
    init(name : String, coordinates : CLLocationCoordinate2D, free : Bool) {
        self.name = name
        self.longitude = coordinates.longitude
        self.latitude = coordinates.latitude
        self.free = free
    }
    
    required init() {}
    
    func getDistanceToSource(source : CLLocation) -> Float {
        //Formula from https://www.movable-type.co.uk/scripts/latlong.html
        let R : Float = 6371e3
        let phi1 = GLKMathDegreesToRadians(Float(latitude))
        let phi2 = GLKMathDegreesToRadians(Float(source.coordinate.latitude))
        let deltaPhi = GLKMathDegreesToRadians(Float(source.coordinate.latitude - latitude))
        let deltaLambda = GLKMathDegreesToRadians(Float(source.coordinate.longitude - longitude))
        
        let a = (sin(deltaPhi/2) * sin(deltaPhi/2)) + (cos(phi1) * cos(phi2)) * (sin(deltaLambda/2) * sin(deltaLambda/2))
        
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        return (R * c)
    }

    
    
}

@objc enum Gender : Int,RealmEnum {
    case Men = 1
    case Women = 0
}
