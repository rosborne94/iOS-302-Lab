//
//  Constants.swift
//  PeopleMon
//
//  Created by Brett Keck on 8/17/16.
//  Copyright © 2016 Eleven Fifty. All rights reserved.
//

import UIKit

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
        static let email = "Email"
        static let fullName = "FullName"
        static let password = "Password"
        static let apiKey = "ApiKey"
        static let profileImage = "ProfileBase64Image"
        static let username = "username"
        static let grantType = "grant_type"
        static let token = "token"
        static let expirationDate = "expiration"
        static let hasRegistered = "HasRegistered"
        static let loginProvider = "LoginProvider"
        static let avatarBase64 = "AvatarBase64"
        static let latitude = "LastCheckInLatitude"
        static let longitude = "LastCheckInLongitude"
    }
    
    struct Person {
        static let userId = "UserId"
        static let userName = "UserName"
        static let latitude = "Latitude"
        static let longitude = "Longitude"
        static let created = "Created"
        static let radius = "RadiusInMeters"
        static let caughtUserId = "CaughtUserId"
    }
}

enum Images : String {
    case Avatar
    
    func image() -> UIImage {
        return UIImage(named: self.rawValue)!
    }
}