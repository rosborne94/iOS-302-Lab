//
//  MapPin.swift
//  PeopleMon
//
//  Created by Brett Keck on 8/24/16.
//  Copyright © 2016 Eleven Fifty. All rights reserved.
//

import UIKit
import MapKit

class MapPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var person: Person?
    
    init(person: Person) {
        self.person = person
        if let lat = person.latitude, let long = person.longitude {
            self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        } else {
            self.coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
    }
}
