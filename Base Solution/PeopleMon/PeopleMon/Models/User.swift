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
    var id: Int?
    var username: String?
    var email: String?
    var password: String?
    var token: String?
    var expirationDate: String?
    
    var requestType: RequestType = .Login
    
    enum RequestType {
        case Login
        case Register
    }
    
    init() {}
    
    required init(json: JSON) {
        token = json[Constants.User.token].string
        expirationDate = json[Constants.User.expirationDate].string
    }
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
        requestType = .Login
    }
    
    init(username: String, password: String, email: String) {
        self.username = username
        self.password = password
        self.email = email
        requestType = .Register
    }
    
    init(id: Int) {
        self.id = id
    }
    
    func method() -> Alamofire.Method {
        return .POST
    }
    
    func path() -> String {
        switch requestType {
        case .Login:
            return "/auth"
        case .Register:
            return "/register"
        }
    }
    
    func toDictionary() -> [String: AnyObject]? {
        var params: [String: AnyObject] = [:]
        params[Constants.User.username] = username
        params[Constants.User.password] = password
        
        switch requestType {
        case .Register:
            params[Constants.User.email] = email
        default:
            break
        }
        
        return params
    }
}