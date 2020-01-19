//
//  LocationDetailViewController.swift
//  ToiletMaps
//
//  Created by Pieter Paelinck on 28/12/2019.
//  Copyright © 2019 Pieter Paelinck. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import RealmSwift

class LocationDetailViewController: UIViewController, CLLocationManagerDelegate {
    
    var marker : GMSMarker?
    var locationFromClosest : Location?
    @IBOutlet var entranceImage: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionTextField: UITextField!
    @IBOutlet var addressTextField: UITextField!
    @IBOutlet var freeSwitch: UISwitch!
    @IBOutlet var babyChangeSwitch: UISwitch!
    var locationManager : CLLocationManager!
    var lastLocation : CLLocation?
    var originViewController : UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Source : https://developer.apple.com/documentation/corelocation/cllocationmanager
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestLocation()
        
        if let locationFromClosest = locationFromClosest {
            marker = GMSMarker(position: CLLocationCoordinate2D(latitude: locationFromClosest.latitude, longitude: locationFromClosest.longitude))
            marker!.title = locationFromClosest.name
        }
        
        titleLabel.text = marker?.title
        descriptionTextField.text = "No description found"
        LocationController.getAddressForLocation(location: marker!.position) { (address) in
            DispatchQueue.main.async {
                self.addressTextField.text = address
            }
        }
        let realm = try! Realm()
        let long = marker?.position.longitude.description ?? "None found"
        let lat = marker?.position.latitude.description ?? "None found"
        
        let location = realm.objects(Location.self).filter("longitude = \(long) AND latitude = \(lat)").first
        if let location = location {
            descriptionTextField.text = location.locationDescription ?? "No description available."
            locationFromClosest = location
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        //Alert code source https://developer.apple.com/documentation/uikit/windows_and_screens/getting_the_user_s_attention_with_alerts_and_action_sheets
        
        
        let deleteAlert = UIAlertController(title: "Please confirm", message: "Are you sure you want to delete this location?", preferredStyle: .alert)
        deleteAlert.addAction(UIAlertAction(title: "Delete", style: .destructive) { (action) in
            let realm = try! Realm()
            try! realm.write {
                realm.delete(self.locationFromClosest!)
            }
            self.dismiss(animated: true, completion: {
                if let originViewController = self.originViewController as? MapViewController {
                    originViewController.viewDidAppear(true)
                }
                if let originViewController = self.originViewController as? LocationTableViewController {
                    originViewController.viewWillAppear(true)
                }
            })
        })
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("Canceled")
        })
        self.present(deleteAlert, animated: true) {}
    }
    
    @IBAction func startRouteTapped(_ sender: Any) {
        let pathUrl : URL?
        
        if let lastLocation = lastLocation {
            pathUrl = URL(string: "https://www.google.com/maps/dir/?api=1&&destination=\(marker!.position.latitude.description),\(marker!.position.longitude.description)&origin=\(lastLocation.coordinate.latitude),\(lastLocation.coordinate.longitude)&travelmode=walking")
        } else {
            pathUrl = URL(string: "https://www.google.com/maps/dir/?api=1&&destination=\(marker!.position.latitude.description),\(marker!.position.longitude.description)&travelmode=walking")
        }
        UIApplication.shared.open(pathUrl!, options: [:], completionHandler: nil)
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        lastLocation = location
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
