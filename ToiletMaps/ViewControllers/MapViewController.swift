//
//  ViewController.swift
//  ToiletMaps
//
//  Created by Pieter Paelinck on 27/12/2019.
//  Copyright © 2019 Pieter Paelinck. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import RealmSwift

class MapViewController: UIViewController, GMSMapViewDelegate,CLLocationManagerDelegate {
    
    var locationManager : CLLocationManager!
    var lastLocation : CLLocation?
    var mapView : GMSMapView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //provide API keys for GM
        GMSServices.provideAPIKey("AIzaSyC8EGL9zamP8agZHXUA6FEF0YIXxP7G4MM")
        GMSPlacesClient.provideAPIKey("AIzaSyC8EGL9zamP8agZHXUA6FEF0YIXxP7G4MM")
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestLocation()
        
        // Map init source https://developers.google.com/maps/documentation/ios-sdk/start
        let camera : GMSCameraPosition
        if let lastLocation = lastLocation {
            camera = GMSCameraPosition.camera(withLatitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude, zoom: 15.0)
        } else {
            camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 15.0)
        }
        
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView!.delegate = self
        loadMapSettings(mapView!)
        loadClosestMarkers(mapView!)
        self.view = mapView
        
        
    }
    
    func reloadMarkers(_ mapView : GMSMapView) {
        loadClosestMarkers(mapView)
        self.view = mapView
    }
    
    func loadMapSettings(_ mapView : GMSMapView) {
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.zoomGestures = true
        mapView.settings.compassButton = true
    }
    
    func loadClosestMarkers(_ mapView : GMSMapView) {
        let realm = try! Realm()
        let locs = realm.objects(Location.self)
        for l in locs {
            let m = GMSMarker()
            m.position = CLLocationCoordinate2D(latitude: l.latitude, longitude: l.longitude)
            m.title = l.name
            m.snippet = "Click for more info"
            m.map = mapView
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        self.mapView?.clear()
        loadClosestMarkers(mapView!)
        self.view = mapView
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        performSegue(withIdentifier: "showLocationDetailSegue", sender: marker)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let sender = sender as? GMSMarker else {return}
        
        let detailVC = segue.destination as? LocationDetailViewController
        detailVC?.marker = sender
        detailVC?.originViewController = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {return}
        lastLocation = location
        mapView!.animate(toLocation: CLLocationCoordinate2D(latitude: lastLocation!.coordinate.latitude, longitude: lastLocation!.coordinate.longitude))
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}

