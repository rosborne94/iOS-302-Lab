//
//  WebservicesExtension.swift
//  PeopleMon
//
//  Created by Brett Keck on 5/17/16.
//  Copyright © 2016 Eleven Fifty Academy. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

extension WebServices {
    // MARK: - Generic REST functions
    func getObject<T: NetworkModel>(model: T, completion: (object: T?, error: String?) -> Void) {
        request(AuthRouter.RESTRequest(model)).response { (request, response, data, error) in
            WebServices.parseResponseObject(response, data: data, error: error, completion: completion)
        }
    }
    
    // Step 6: Create generic functions for creating an object as well as getting back an array of objects
    func postObject<T: NetworkModel>(model: T, completion: (object: T?, error: String?) -> Void) {
        request(AuthRouter.RESTRequest(model)).response { (request, response, data, error) in
            WebServices.parseResponseObject(response, data: data, error: error, completion: completion)
        }
    }
    
    func getObjects<T: NetworkModel>(model: T, completion: (objects: [T]?, error: String?) -> Void) {
        request(AuthRouter.RESTRequest(model)).response { (request, response, data, error) in
            WebServices.parseResponseObjects(response, data: data, error: error, completion: completion)
        }
    }
    
    
    // MARK: - Response parsing functions
    class func parseResponseObject<T: NetworkModel>(response: NSHTTPURLResponse?, data: NSData?, error: NSError?, completion: (object: T?, error: String?) -> Void) {
        var errorString: String?
        var object: T?
        if let status = response?.statusCode {
            switch status {
            case 200:
                if let data = data {
                    let json = JSON(data: data)
                    object = T(json: json)
                } else {
                    errorString = Constants.JSON.unknownError
                }
            case 201:
                if let data = data {
                    let json = JSON(data: data)
                    object = T(json: json)
                } else {
                    errorString = Constants.JSON.unknownError
                }
            case 400:
                errorString = Constants.JSON.badRequest
            case 402:
                errorString = Constants.JSON.badUsernamePassword
            case 403:
                errorString = Constants.JSON.unauthorized
            case 404:
                errorString = Constants.JSON.objectNotFound
            case 500:
                errorString = Constants.JSON.internalError
            default:
                errorString = Constants.JSON.unknownError
            }
        } else {
            errorString = Constants.JSON.unknownError
        }
        
        completion(object: object, error: errorString)
    }
    
    class func parseResponseObjects<T: NetworkModel>(response: NSHTTPURLResponse?, data: NSData?, error: NSError?, completion: (objects: [T]?, error: String?) -> Void) {
        var errorString: String?
        var objects: [T]?
        if let status = response?.statusCode {
            switch status {
            case 200:
                if let data = data {
                    let jsonArray = JSON(data: data)
                    if let array = jsonArray.array {
                        objects = []
                        for json in array {
                            objects?.append(T(json: json))
                        }
                    } else {
                        errorString = Constants.JSON.unknownError
                    }
                } else {
                    errorString = Constants.JSON.unknownError
                }
            case 201:
                if let data = data {
                    let jsonArray = JSON(data: data)
                    if let array = jsonArray.array {
                        objects = []
                        for json in array {
                            objects?.append(T(json: json))
                        }
                    } else {
                        errorString = Constants.JSON.unknownError
                    }
                } else {
                    errorString = Constants.JSON.unknownError
                }
            case 400:
                errorString = Constants.JSON.badRequest
            case 402:
                errorString = Constants.JSON.badUsernamePassword
            case 403:
                errorString = Constants.JSON.unauthorized
            case 404:
                errorString = Constants.JSON.objectNotFound
            case 500:
                errorString = Constants.JSON.internalError
            default:
                errorString = Constants.JSON.unknownError
            }
        } else {
            errorString = Constants.JSON.unknownError
        }
        
        completion(objects: objects, error: errorString)
    }
    
    func authUser<T: NetworkModel>(user: T, completion:(user: T?, error: String?) -> ()) {
        request(user.method(), WebServices.shared.baseURL + user.path(), parameters: user.toDictionary(), encoding: .URL)
            .response { (request, response, data, error) in
                WebServices.parseResponseObject(response, data: data, error: error, completion: completion)
        }
    }
    
    func registerUser<T: NetworkModel>(user: T, completion:(user: T?, error: String?) -> ()) {
        request(user.method(), WebServices.shared.baseURL + user.path(), parameters: user.toDictionary(), encoding: .URL)
            .response { (request, response, data, error) in
                WebServices.parseResponseObject(response, data: data, error: error, completion: completion)
        }
    }
}