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
    
    var nearbyView: UIView!
    var nearbyCollectionView: UICollectionView!
    var nearbyPeople: [Person] = []
    var userOverlay: MKOverlay?
    
    var selectedOverlay: MKOverlay?
    
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
        
        setupNearbyView()
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
    
    func setupNearbyView() {
        let bounds = UIScreen.main.bounds
        let width: CGFloat = 196
        let height: CGFloat = 240
        
        let closeButton = UIButton(frame: CGRect(x: 8, y: 196, width: 180, height: 44))
        closeButton.addTarget(self, action: #selector(closeNearbyView(sender:)), for: .touchUpInside)
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(UIColor.blue, for: .normal)
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        nearbyView = UIView(frame: CGRect(x: (bounds.width - width) / 2.0, y: (bounds.height - height) / 2.0, width: width, height: height))
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        nearbyCollectionView = UICollectionView(frame: CGRect(x: 8, y: 8, width: 180, height: 180), collectionViewLayout: layout)
        nearbyCollectionView.dataSource = self
        nearbyCollectionView.delegate = self
        nearbyCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        nearbyCollectionView.isScrollEnabled = false
        nearbyView.addSubview(nearbyCollectionView)
        nearbyView.addSubview(closeButton)
        nearbyView.backgroundColor = UIColor.white
        nearbyCollectionView.backgroundColor = UIColor.clear
        self.view.addSubview(nearbyView)
        
        let translateTransform = CGAffineTransform(translationX: 0, y: bounds.height)
        nearbyView.transform = translateTransform
    }
    
    func removeSelectedOverlay() {
        if let selectedOverlay = selectedOverlay {
            mapView.remove(selectedOverlay)
            self.selectedOverlay = nil
        }
    }
    
    
    // MARK: - IBActions
    @IBAction func logout(sender: AnyObject) {
        UserStore.shared.logout { 
            self.performSegueWithIdentifier(segueIdentifier: .PresentLogin, sender: self)
        }
    }
    
    @IBAction func openNearbyView(sender: AnyObject) {
        let person = Person(radius: Constants.nearbyRadius)
        WebServices.shared.getObjects(person) { (objects, error) in
            if let objects = objects {
                self.nearbyPeople = objects
                for person in objects {
                    if let lat = person.latitude, let long = person.longitude {
                        person.distance = self.locationManager.location?.distance(from: CLLocation(latitude: lat, longitude: long))
                    }
                }
                self.nearbyPeople = objects.sorted(by: { (person1, person2) -> Bool in
                    switch (person1.distance, person2.distance) {
                    case let (distance1?, distance2?):
                        return distance1 < distance2
                    case (nil, _?):
                        return true
                    default:
                        return false
                    }
                })
                self.nearbyCollectionView.reloadData()
            }
        }
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: [], animations: {
            self.nearbyView.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: nil)
    }
    
    @IBAction func closeNearbyView(sender: AnyObject) {
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: [], animations: {
            self.nearbyView.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
            }, completion: nil)
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(latitudeDelta, longitudeDelta))
        
        self.mapView.setRegion(region, animated: true)
        
        if let userOverlay = userOverlay {
            mapView.remove(userOverlay)
        }
        userOverlay = MKCircle(center: center, radius: Constants.radius)
        mapView.add(userOverlay!)
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
        let circleOverlay = MKCircleRenderer(overlay: overlay)
        if let userOverlay = userOverlay, userOverlay.coordinate.latitude == overlay.coordinate.latitude && userOverlay.coordinate.longitude == overlay.coordinate.longitude {
            circleOverlay.lineWidth = 1
            circleOverlay.strokeColor = UIColor.lightGray
            circleOverlay.fillColor = UIColor.lightGray.withAlphaComponent(0.5)
        } else {
            circleOverlay.lineWidth = 0
            circleOverlay.fillColor = UIColor.lightGray.withAlphaComponent(0.25)
        }
        return circleOverlay
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


// MARK: - CollectionView
extension MapViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    private func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(nearbyPeople.count, 9)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath)
        
        let person = nearbyPeople[indexPath.row];
        let imageView = CircleImage(frame: CGRect(x: 5, y: 5, width: 50, height: 50))
        imageView.contentMode = .scaleAspectFill
        imageView.image = Utils.imageFromString(imageString: person.avatar)
        cell.addSubview(imageView)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = nearbyPeople[indexPath.row]
        if let lat = person.latitude, let long = person.longitude {
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            if let selectedOverlay = selectedOverlay {
                mapView.remove(selectedOverlay)
            }
            selectedOverlay = MKCircle(center: coordinate, radius: Constants.radius / 2.0)
            mapView.add(selectedOverlay!)
            let _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(removeSelectedOverlay), userInfo: nil, repeats: false)
            closeNearbyView(sender: self)
        }
    }
}
