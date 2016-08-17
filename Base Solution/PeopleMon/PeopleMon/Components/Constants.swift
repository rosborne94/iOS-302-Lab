//
//  Constants.swift
//  PeopleMon
//
//  Created by Brett Keck on 8/17/16.
//  Copyright © 2016 Eleven Fifty. All rights reserved.
//

import Foundation

struct Constants {
    struct JSON {
        static let badRequest = "Bad Request"
        static let unknownError = "An Unknown Error Has Occurred"
        static let badUsernamePassword = "Invalid Username or Password"
        static let unauthorized = "Unauthorized"
        static let objectNotFound = "Object Not Found"
        static let internalError = "An Internal Server Error Occurred"
    }
    
    struct User {
        static let id = "id"
        static let email = "email"
        static let username = "username"
        static let password = "password"
        static let token = "token"
        static let expirationDate = "expiration"
    }
}