//
//  User.swift
//  PeopleMon
//
//  Created by Brett Keck on 8/17/16.
//  Copyright © 2016 Eleven Fifty. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class User: NetworkModel {
    var email: String?
    var fullName: String?
    var avatar: String?
    var password: String?
    var apiKey: String?
    
    var hasRegistered = false
    var loginProvider: String?
    var latitude: Double?
    var longitude: Double?
    
    var token: String?
    var expirationDate: String?
    
    var requestType: RequestType = .Login
    
    enum RequestType {
        case Login
        case Register
        case Logout
        case UserInfo
    }
    
    init() {}
    
    required init(json: JSON) {
        token = json[Constants.User.token].string
        expirationDate = json[Constants.User.expirationDate].string
        
        email = json[Constants.User.email].string
        hasRegistered = json[Constants.User.hasRegistered].boolValue
        loginProvider = json[Constants.User.loginProvider].string
        fullName = json[Constants.User.fullName].string
        avatar = json[Constants.User.avatarBase64].string
        latitude = json[Constants.User.latitude].double
        longitude = json[Constants.User.longitude].double
    }
    
    init(email: String, password: String) {
        self.email = email
        self.password = password
        requestType = .Login
    }
    
    init(email: String, password: String, fullName: String, profilePhotoUrl: String) {
        self.email = email
        self.password = password
        self.fullName = fullName
        self.avatar = profilePhotoUrl
        self.apiKey = NSUUID().UUIDString
        requestType = .Register
    }
    
    func method() -> Alamofire.Method {
        switch requestType {
        case .UserInfo:
            return .GET
        default:
            return .POST
        }
    }
    
    func path() -> String {
        switch requestType {
        case .Login:
            return "/token"
        case .Register:
            return "/api/Account/Register"
        case .Logout:
            return "/api/Account/Logout"
        case .UserInfo:
            return "/api/Account/UserInfo"
        }
    }
    
    func toDictionary() -> [String: AnyObject]? {
        var params: [String: AnyObject] = [:]
        
        switch requestType {
        case .Register:
            params[Constants.User.email] = email
            params[Constants.User.fullName] = fullName
            params[Constants.User.profileImage] = avatar
            params[Constants.User.apiKey] = self.apiKey
            params[Constants.User.password] = password
        case .Login:
            params[Constants.User.username] = email
            params["password"] = password
            params[Constants.User.grantType] = "password"
        default:
            break
        }
        
        return params
    }
}