//
//  LocationTableViewController.swift
//  ToiletMaps
//
//  Created by Pieter Paelinck on 17/01/2020.
//  Copyright © 2020 Pieter Paelinck. All rights reserved.
//

import UIKit
import RealmSwift
import CoreLocation

class LocationTableViewController: UITableViewController, CLLocationManagerDelegate {

    var paid : [Location:Float] = [:]
    var free : [Location:Float] = [:]
    var freeDistanceArray : [Float] = []
    var paidDistanceArray : [Float] = []
    var locationManager : CLLocationManager!
    var lastLocation : CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.cellLayoutMarginsFollowReadableWidth = true
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestLocation()
        
    }

    // MARK: - Table view data source
    
    override func viewWillAppear(_ animated: Bool) {
        prepareLocations()
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Free toilets"
        } else {
            return "Paid toilets"
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        prepareLocations()
        if section == 0 {
            return free.count
        } else {
            return paid.count
        }
    }

    func prepareLocations() {
        //Get locations from Realm
        let realm = try! Realm()
        let locationsResults = realm.objects(Location.self)
        
        free.removeAll()
        paid.removeAll()
        
        let currentLocation = lastLocation
        //Divide into free/paid toilets
        for l in locationsResults {
            if l.free {
                free[l] = l.getDistanceToSource(source: currentLocation ?? CLLocation(latitude: -33.89, longitude: 151.20))
            } else {
                paid[l] = l.getDistanceToSource(source: currentLocation ?? CLLocation(latitude: -33.87, longitude: 151.1))
            }
        }
        freeDistanceArray = Array(free.values).sorted().reversed()
        paidDistanceArray = Array(paid.values).sorted().reversed()
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)

        
        var loc : Location
        let dist : Float
        
        if indexPath.section == 0 {
            dist = freeDistanceArray.popLast()!
            if let i = free.firstIndex(where: {$1 == dist}) {
                loc = free[i].key
            } else {
                loc = Location()
            }
        } else {
            dist = paidDistanceArray.popLast()!
            if let i = paid.firstIndex(where: {$1 == dist}) {
                loc = paid[i].key
            } else {
                loc = Location()
            }
        }
        
        cell.textLabel?.text = loc.name
        cell.detailTextLabel?.text = Int(dist).description + " meter"
        cell.imageView?.image = loc.free ? UIImage(systemName: "dollarsign.circle") : UIImage(systemName: "dollarsign.circle.fill")
        
        return cell
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        lastLocation = location
        tableView.reloadData()
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let locName = tableView.cellForRow(at: indexPath)?.textLabel?.text
        let locationForSegue = LocationController.getLocationFromName(locName!)
        performSegue(withIdentifier: "showLocationDetail", sender: locationForSegue)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sender = sender as? Location {
            let detailVC = segue.destination as? LocationDetailViewController
            detailVC?.locationFromClosest = sender
            detailVC?.originViewController = self
        }
    }
    
    

}
