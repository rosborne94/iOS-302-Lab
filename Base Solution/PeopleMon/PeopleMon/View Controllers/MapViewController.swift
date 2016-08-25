//
//  MapViewController.swift
//  PeopleMon
//
//  Created by Brett Keck on 8/17/16.
//  Copyright © 2016 Eleven Fifty. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, SegueHandlerType {
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    let latitudeDelta = 0.2
    let longitudeDelta = 0.2
    
    var annotations: [MapPin] = []
    var overlay: MKOverlay?
    var firstLocation = true
    
    var timer: NSTimer?
    
    enum SegueIdentifier: String {
        case PresentLoginNoAnimation
        case PresentLogin
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        
        UserStore.shared.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(animated: Bool) {
        if !WebServices.shared.userAuthTokenExists() || WebServices.shared.userAuthTokenExpired() {
            performSegueWithIdentifier(.PresentLoginNoAnimation, sender: self)
        } else {
            let infoUser = User()
            WebServices.shared.getObject(infoUser, completion: { (user, error) in
                if let user = user {
                    UserStore.shared.user = user
                }
            })
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        stopTimer()
    }
    
    func loadMap() {
        let nearby = Person(radius: 50)
        WebServices.shared.getObjects(nearby) { (objects, error) in
            if let objects = objects {
                self.mapView.removeAnnotations(self.annotations)
                self.annotations = []
                for person in objects {
                    let pin = MapPin(person: person)
                    self.annotations.append(pin)
                }
                self.mapView.addAnnotations(self.annotations)
            }
        }
    }
    
    func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(loadMap), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    
    // MARK: - IBActions
    @IBAction func checkIn(sender: AnyObject) {
        if let coordinate = locationManager.location?.coordinate {
            let checkIn = Person(coordinate: coordinate)
            WebServices.shared.postObject(checkIn, completion: { (object, error) in
                
            })
        }
    }
    
    @IBAction func logout(sender: AnyObject) {
        UserStore.shared.logout { 
            self.performSegueWithIdentifier(.PresentLogin, sender: self)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(latitudeDelta, longitudeDelta))
        
        self.mapView.setRegion(region, animated: true)
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.animatesDrop = false
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        self.overlay = overlay
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blueColor()
        renderer.lineWidth = 5.0
        renderer.lineCap = CGLineCap.Round
        return renderer
    }
}

// MARK: - UserStoreDelegate
extension MapViewController: UserStoreDelegate {
    func userLoggedIn() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(stopTimer), name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(startTimer), name: UIApplicationDidBecomeActiveNotification, object: nil)
        stopTimer()
        startTimer()
    }
}