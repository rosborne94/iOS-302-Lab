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
    
    var nearbyView: UIView!
    var nearbyCollectionView: UICollectionView!
    var nearbyPeople: [Person] = []
    var userOverlay: MKOverlay?
    
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
        
        setupNearbyView()
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
    
    func setupNearbyView() {
        let bounds = UIScreen.mainScreen().bounds
        let width: CGFloat = 196
        let height: CGFloat = 240
        
        let closeButton = UIButton(frame: CGRect(x: 8, y: 196, width: 180, height: 44))
        closeButton.addTarget(self, action: #selector(closeNearbyView(_:)), forControlEvents: .TouchUpInside)
        closeButton.setTitle("Close", forState: .Normal)
        closeButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        closeButton.titleLabel?.font = UIFont.boldSystemFontOfSize(14)
        nearbyView = UIView(frame: CGRect(x: (bounds.width - width) / 2.0, y: (bounds.height - height) / 2.0, width: width, height: height))
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        nearbyCollectionView = UICollectionView(frame: CGRect(x: 8, y: 8, width: 180, height: 180), collectionViewLayout: layout)
        nearbyCollectionView.dataSource = self
        nearbyCollectionView.delegate = self
        nearbyCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        nearbyCollectionView.scrollEnabled = false
        nearbyView.addSubview(nearbyCollectionView)
        nearbyView.addSubview(closeButton)
        nearbyView.backgroundColor = UIColor.whiteColor()
        nearbyCollectionView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(nearbyView)
        
        let translateTransform = CGAffineTransformMakeTranslation(0, bounds.height)
        nearbyView.transform = translateTransform
    }
    
    
    // MARK: - IBActions
    @IBAction func logout(sender: AnyObject) {
        UserStore.shared.logout { 
            self.performSegueWithIdentifier(.PresentLogin, sender: self)
        }
    }
    
    @IBAction func openNearbyView(sender: AnyObject) {
        let person = Person(radius: Constants.nearbyRadius)
        WebServices.shared.getObjects(person) { (objects, error) in
            if let objects = objects {
                self.nearbyPeople = objects
                for person in objects {
                    if let lat = person.latitude, long = person.longitude {
                        person.distance = self.locationManager.location?.distanceFromLocation(CLLocation(latitude: lat, longitude: long))
                    }
                }
                self.nearbyPeople = objects.sort({ (person1, person2) -> Bool in
                    person1.distance < person2.distance
                })
                self.nearbyCollectionView.reloadData()
            }
        }
        UIView.animateWithDuration(0.8, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: [], animations: { 
            self.nearbyView.transform = CGAffineTransformMakeTranslation(0, 0)
            }, completion: nil)
    }
    
    @IBAction func closeNearbyView(sender: AnyObject) {
        UIView.animateWithDuration(0.8, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: [], animations: {
            self.nearbyView.transform = CGAffineTransformMakeTranslation(0, UIScreen.mainScreen().bounds.height)
            }, completion: nil)
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(latitudeDelta, longitudeDelta))
        
        self.mapView.setRegion(region, animated: true)
        
        if let userOverlay = userOverlay {
            mapView.removeOverlay(userOverlay)
        }
        userOverlay = MKCircle(centerCoordinate: center, radius: Constants.radius)
        mapView.addOverlay(userOverlay!)
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
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let circleOverlay = MKCircleRenderer(overlay: overlay)
        circleOverlay.lineWidth = 1
        circleOverlay.strokeColor = UIColor.lightGrayColor()
        circleOverlay.fillColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5)
        return circleOverlay
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


// MARK: - CollectionView
extension MapViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(nearbyPeople.count, 9)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
        
        let person = nearbyPeople[indexPath.row];
        print("row: \(indexPath.row), distance: \(person.distance)")
        let imageView = CircleImage(frame: CGRect(x: 5, y: 5, width: 50, height: 50))
        imageView.contentMode = .ScaleAspectFill
        imageView.image = Utils.imageFromString(person.avatar)
        cell.addSubview(imageView)
        
        return cell
    }
}