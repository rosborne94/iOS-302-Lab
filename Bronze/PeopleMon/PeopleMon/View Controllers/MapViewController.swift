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
    
    var timer: Timer?
    
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
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        
        UserStore.shared.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(_ animated: Bool) {
        if !WebServices.shared.userAuthTokenExists() || WebServices.shared.userAuthTokenExpired() {
            performSegueWithIdentifier(segueIdentifier: .PresentLoginNoAnimation, sender: self)
        } else {
            let infoUser = User()
            WebServices.shared.getObject(infoUser, completion: { (user, error) in
                if let user = user {
                    UserStore.shared.user = user
                }
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
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
        timer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(loadMap), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    
    // MARK: - IBActions
    @IBAction func logout(sender: AnyObject) {
        UserStore.shared.logout { 
            self.performSegueWithIdentifier(segueIdentifier: .PresentLogin, sender: self)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(latitudeDelta, longitudeDelta))
        
        self.mapView.setRegion(region, animated: true)
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            let userPin = "userLocation"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: userPin)
            if pinView == nil {
                pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: userPin)
                pinView?.canShowCallout = false
            } else {
                pinView?.annotation = annotation
            }
            if let image = Utils.imageFromString(imageString: UserStore.shared.user?.avatar) {
                let resizedImage = Utils.resizeImage(image: image, maxSize: Constants.pinImageSize)
                pinView?.image = resizedImage
                pinView?.layer.cornerRadius = 16
                pinView?.contentMode = .scaleAspectFill
                pinView?.clipsToBounds = true
                pinView?.layer.borderWidth = 2
                pinView?.layer.borderColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1).cgColor
            } else {
                pinView?.image = Images.Avatar.image()
            }
            return pinView
        }
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if pinView == nil {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = false
        } else {
            pinView?.annotation = annotation
        }
        
        if let mapPin = annotation as? MapPin {
            if let image = Utils.imageFromString(imageString: mapPin.person?.avatar) {
                let resizedImage = Utils.resizeImage(image: image, maxSize: Constants.pinImageSize)
                pinView?.image = resizedImage
                pinView?.layer.cornerRadius = Constants.pinImageSize / 2.0
                pinView?.contentMode = .scaleAspectFill
                pinView?.clipsToBounds = true
            } else {
                pinView?.image = Images.Avatar.image()
            }
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let mapPin = view.annotation as? MapPin, let person = mapPin.person, let name = person.username, let userId = person.userId {
            let alert = UIAlertController(title: "Catch User", message: "Catch \(name)?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Catch", style: .default, handler: { (action) in
                let catchPerson = Person(userId: userId, radius: Constants.radius)
                WebServices.shared.postObject(catchPerson, completion: { (object, error) in
                    if let error = error {
                        self.present(Utils.createAlert(message: error), animated: true, completion: nil)
                    } else {
                        self.present(Utils.createAlert(title: "Catch", message: "User Caught", dismissButtonTitle: "OK"), animated: true, completion: nil)
                    }
                })
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        self.overlay = overlay
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        renderer.lineCap = CGLineCap.round
        return renderer
    }
}

// MARK: - UserStoreDelegate
extension MapViewController: UserStoreDelegate {
    func userLoggedIn() {
        NotificationCenter.default.addObserver(self, selector: #selector(stopTimer), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startTimer), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        stopTimer()
        startTimer()
    }
}
