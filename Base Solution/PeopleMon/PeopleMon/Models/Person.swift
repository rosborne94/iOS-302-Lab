//
//  Person.swift
//  PeopleMon
//
//  Created by Brett Keck on 8/24/16.
//  Copyright © 2016 Eleven Fifty. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MapKit

class Person: NetworkModel {
    var userId: String?
    var username: String?
    var latitude: Double?
    var longitude: Double?
    var created: NSDate?
    var radius: Double?
    
    var requestType: RequestType = .Caught
    
    enum RequestType {
        case Nearby
        case CheckIn
        case Catch
        case Caught
    }
    
    init() {}
    
    required init(json: JSON) {
        
    }
    
    init(radius: Double) {
        self.requestType = .Nearby
        self.radius = radius
    }
    
    init(coordinate: CLLocationCoordinate2D) {
        self.requestType = .CheckIn
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    func method() -> Alamofire.Method {
        switch requestType {
        case .Nearby, .Caught:
            return .GET
        default:
            return .POST
        }
    }
    
    func path() -> String {
        switch requestType {
        case .Nearby:
            return "/v1/User/Nearby"
        case .CheckIn:
            return "/v1/User/CheckIn"
        case .Catch:
            return "/v1/User/Catch"
        case .Caught:
            return "/v1/User/Caught"
        }
    }
    
    func toDictionary() -> [String: AnyObject]? {
        var params: [String: AnyObject] = [:]
        
        switch requestType {
        case .Nearby:
            params[Constants.Person.radius] = radius
        case .CheckIn:
            params[Constants.Person.latitude] = latitude
            params[Constants.Person.longitude] = longitude
        case .Catch:
            params[Constants.Person.caughtUserId] = userId
            params[Constants.Person.radius] = radius
        case .Caught:
            break
        }
        
        return params
    }
}