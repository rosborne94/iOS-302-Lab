//
//  Person.swift
//  PeopleMon
//
//  Created by Brett Keck on 8/24/16.
//  Copyright © 2016 Eleven Fifty. All rights reserved.
//

import UIKit
import Alamofire
import Freddy
import MapKit

class Person: NetworkModel {
    var userId: String?
    var username: String?
    var avatar: String?
    var latitude: Double?
    var longitude: Double?
    var created: String?
    var radius: Double?
    
    var requestType: RequestType = .Nearby
    
    enum RequestType {
        case Nearby
        case CheckIn
        case Catch
        case Caught
    }
    
    init() {
        requestType = .Caught
    }
    
    required init(json: JSON) {
        self.userId = try? json.getString(at: Constants.Person.userId)
        self.username = try? json.getString(at: Constants.Person.userName)
        self.avatar = try? json.getString(at: Constants.Person.avatar)
        self.latitude = try? json.getDouble(at: Constants.Person.latitude)
        self.longitude = try? json.getDouble(at: Constants.Person.longitude)
        self.created = try? json.getString(at: Constants.Person.created)
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
    
    init(userId: String, radius: Double) {
        self.requestType = .Catch
        self.userId = userId
        self.radius = radius
    }
    
    func method() -> Alamofire.HTTPMethod {
        switch requestType {
        case .Nearby, .Caught:
            return .get
        default:
            return .post
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
            params[Constants.Person.radius] = radius as AnyObject?
        case .CheckIn:
            params[Constants.Person.latitude] = latitude as AnyObject?
            params[Constants.Person.longitude] = longitude as AnyObject?
        case .Catch:
            params[Constants.Person.caughtUserId] = userId as AnyObject?
            params[Constants.Person.radius] = radius as AnyObject?
        case .Caught:
            break
        }
        
        return params
    }
}
