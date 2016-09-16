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
    
    var distance: Double?
    
    var requestType: RequestType = .nearby
    
    enum RequestType {
        case nearby
        case checkIn
        case catchPerson
        case caught
    }
    
    init() {
        requestType = .caught
    }
    
    required init(json: JSON) throws {
        self.userId = try? json.getString(at: Constants.Person.userId)
        self.username = try? json.getString(at: Constants.Person.userName)
        self.avatar = try? json.getString(at: Constants.Person.avatar)
        self.latitude = try? json.getDouble(at: Constants.Person.latitude)
        self.longitude = try? json.getDouble(at: Constants.Person.longitude)
        self.created = try? json.getString(at: Constants.Person.created)
    }
    
    init(radius: Double) {
        self.requestType = .nearby
        self.radius = radius
    }
    
    init(coordinate: CLLocationCoordinate2D) {
        self.requestType = .checkIn
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    init(userId: String, radius: Double) {
        self.requestType = .catchPerson
        self.userId = userId
        self.radius = radius
    }
    
    func method() -> Alamofire.HTTPMethod {
        switch requestType {
        case .nearby, .caught:
            return .get
        default:
            return .post
        }
    }
    
    func path() -> String {
        switch requestType {
        case .nearby:
            return "/v1/User/Nearby"
        case .checkIn:
            return "/v1/User/CheckIn"
        case .catchPerson:
            return "/v1/User/Catch"
        case .caught:
            return "/v1/User/Caught"
        }
    }
    
    func toDictionary() -> [String: AnyObject]? {
        var params: [String: AnyObject] = [:]
        
        switch requestType {
        case .nearby:
            params[Constants.Person.radius] = radius as AnyObject?
        case .checkIn:
            params[Constants.Person.latitude] = latitude as AnyObject?
            params[Constants.Person.longitude] = longitude as AnyObject?
        case .catchPerson:
            params[Constants.Person.caughtUserId] = userId as AnyObject?
            params[Constants.Person.radius] = radius as AnyObject?
        case .caught:
            break
        }
        
        return params
    }
}
