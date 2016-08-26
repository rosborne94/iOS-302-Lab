//
//  Constants.swift
//  PeopleMon
//
//  Created by Brett Keck on 8/17/16.
//  Copyright © 2016 Eleven Fifty. All rights reserved.
//

import UIKit

struct Constants {
    static let apiKey = "ios301november2016"
    static let radius = 100.0
    static let serverImageSize: CGFloat = 80
    static let pinImageSize: CGFloat = 16
    
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
        static let password = "password"
        static let apiKey = "ApiKey"
        static let profileImage = "ProfileBase64Image"
        static let username = "username"
        static let grantType = "grant_type"
        static let token = "access_token"
        static let expirationDate = ".expires"
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
        static let radius = "radiusInMeters"
        static let caughtUserId = "CaughtUserId"
        static let avatar = "AvatarBase64"
    }
    
    struct Conversation {
        static let conversationId = "ConversationId"
        static let recipientId = "RecipientId"
        static let recipientName = "RecipientName"
        static let lastMessage = "LastMessage"
        static let created = "Created"
        static let messageCount = "MessageCount"
        static let avatar = "AvatarBase64"
        static let pageSize = "pageSize"
        static let pageNumber = "pageNumber"
    }
    
    struct ConversationList {
        static let count = "Count"
        static let recipientName = "RecipientName"
        static let senderName = "SenderName"
        static let messages = "Messages"
        static let id = "id"
        static let pageSize = "pageSize"
        static let pageNumber = "pageNumber"
    }
    
    struct Message {
        static let recipientId = "RecipientId"
        static let message = "Message"
        static let messageId = "MessageId"
        static let created = "Created"
        static let recipientUserId = "RecipientUserId"
        static let senderUserId = "SenderUserId"
    }
}

enum Images : String {
    case Avatar
    
    func image() -> UIImage {
        return UIImage(named: self.rawValue)!
    }
}