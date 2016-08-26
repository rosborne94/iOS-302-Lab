//
//  WebServices.swift
//  PeopleMon
//
//  Created by Brett Keck on 5/17/16.
//  Copyright © 2016 Eleven Fifty Academy. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftKeychainWrapper
import AFDateHelper

class WebServices: NSObject {
    static let shared = WebServices()
    
    private var _baseURL = ""
    var baseURL : String {
        get {
            return _baseURL
        }
        set {
            _baseURL = newValue
        }
    }
    
    private var authToken: String? {
        get {
            if let authTokenString:String = KeychainWrapper.defaultKeychainWrapper().stringForKey("authToken") {
                return authTokenString
            } else {
                return nil
            }
        }
        set {
            if newValue != nil {
                KeychainWrapper.defaultKeychainWrapper().setString(newValue!, forKey: "authToken")
            } else {
                KeychainWrapper.defaultKeychainWrapper().removeObjectForKey("authToken")
            }
        }
    }
    
    private var authTokenExpireDate: String? {
        get {
            if let authExpireDate:String = KeychainWrapper.defaultKeychainWrapper().stringForKey("authTokenExpireDate") {
                return authExpireDate
            } else {
                return nil
            }
        } set {
            if newValue != nil {
                KeychainWrapper.defaultKeychainWrapper().setString(newValue!, forKey: "authTokenExpireDate")
            }
            else {
                KeychainWrapper.defaultKeychainWrapper().removeObjectForKey("authTokenExpireDate")
            }
        }
    }
    
    func setAuthToken(token: String?, expiration: String?) {
        authToken = token
        authTokenExpireDate = expiration
    }
    
    func userAuthTokenExists() -> Bool {
        if self.authToken != nil {
            return true
        }
        else {
            return false
        }
    }
    
    func userAuthTokenExpired() -> Bool {
        if let expireDateString = self.authTokenExpireDate {
            
            let expireDate = NSDate(fromString: expireDateString, format: .Custom("EEE, dd MMM yyyy HH:mm:ss Z"))
            
            let hourFromNow = NSDate().dateByAddingTimeInterval(3600)
            
            if expireDate.compare(hourFromNow) == NSComparisonResult.OrderedAscending {
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }
    
    func clearUserAuthToken() {
        if self.userAuthTokenExists() {
            self.authToken = nil
        }
    }
    
    enum AuthRouter: URLRequestConvertible {
        static var baseURLString = WebServices.shared._baseURL
        static var OAuthToken: String?
        
        case RESTRequest(NetworkModel)
        
        var URLRequest: NSMutableURLRequest {
            switch self {
            case .RESTRequest(let model):
                let URL = NSURL(string: AuthRouter.baseURLString)!
                let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(model.path()))
                
                mutableURLRequest.HTTPMethod = model.method().rawValue
                
                if let token = WebServices.shared.authToken {
                    mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                }
                
                if let params = model.toDictionary() {
                    if model.method() == .GET {
                        return ParameterEncoding.URL.encode(mutableURLRequest, parameters: params).0
                    } else {
                        return ParameterEncoding.JSON.encode(mutableURLRequest, parameters: params).0
                    }
                }
                
                return mutableURLRequest
            }
        }
    }
}