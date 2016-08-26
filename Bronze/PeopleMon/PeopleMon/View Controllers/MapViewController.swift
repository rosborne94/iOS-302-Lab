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
    let latitudeDelta = 0.005
    let longitudeDelta = 0.005
    
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
        mapView.zoomEnabled = false
        mapView.scrollEnabled = false
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
        if let coordinate = locationManager.location?.coordinate {
            let checkIn = Person(coordinate: coordinate)
            WebServices.shared.postObject(checkIn, completion: { (object, error) in
                
            })
        }
        
        let nearby = Person(radius: Constants.radius)
        WebServices.shared.getObjects(nearby) { (objects, error) in
            if let objects = objects {
                let oldAnnotations = self.annotations
                self.annotations = []
                for person in objects {
                    let pin = MapPin(person: person)
                    self.annotations.append(pin)
                }
                self.mapView.addAnnotations(self.annotations)
                self.mapView.removeAnnotations(oldAnnotations)
            }
        }
    }
    
    func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(loadMap), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    
    // MARK: - IBActions
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
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            let userPin = "userLocation"
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(userPin)
            if pinView == nil {
                pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: userPin)
                pinView?.canShowCallout = false
            } else {
                pinView?.annotation = annotation
            }
            if let image = Utils.imageFromString(UserStore.shared.user?.avatar) {
                let resizedImage = Utils.resizeImage(image, maxSize: Constants.pinImageSize)
                pinView?.image = resizedImage
                pinView?.layer.cornerRadius = 16
                pinView?.contentMode = .ScaleAspectFill
                pinView?.clipsToBounds = true
                pinView?.layer.borderWidth = 2
                pinView?.layer.borderColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1).CGColor
            } else {
                pinView?.image = Images.Avatar.image()
            }
            return pinView
        }
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if pinView == nil {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = false
        } else {
            pinView?.annotation = annotation
        }
        
        if let mapPin = annotation as? MapPin {
            if let image = Utils.imageFromString(mapPin.person?.avatar) {
                let resizedImage = Utils.resizeImage(image, maxSize: Constants.pinImageSize)
                pinView?.image = resizedImage
                pinView?.layer.cornerRadius = Constants.pinImageSize / 2.0
                pinView?.contentMode = .ScaleAspectFill
                pinView?.clipsToBounds = true
            } else {
                pinView?.image = Images.Avatar.image()
            }
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if let mapPin = view.annotation as? MapPin, person = mapPin.person, name = person.username, userId = person.userId {
            let alert = UIAlertController(title: "Catch User", message: "Catch \(name)?", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Catch", style: .Default, handler: { (action) in
                let catchPerson = Person(userId: userId, radius: Constants.radius)
                WebServices.shared.postObject(catchPerson, completion: { (object, error) in
                    if let error = error {
                        self.presentViewController(Utils.createAlert(message: error), animated: true, completion: nil)
                    } else {
                        self.presentViewController(Utils.createAlert("Catch", message: "User Caught", dismissButtonTitle: "OK"), animated: true, completion: nil)
                    }
                })
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
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