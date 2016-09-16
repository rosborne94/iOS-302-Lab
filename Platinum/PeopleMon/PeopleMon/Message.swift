//
//  Message.swift
//  PeopleMon
//
//  Created by Brett Keck on 8/26/16.
//  Copyright © 2016 Eleven Fifty. All rights reserved.
//

import Foundation
import Alamofire
import Freddy

class Message: NetworkModel {
    var recipientId: String?
    var message: String?
    
    var messageId: Int?
    var created: String?
    var recipientUserId: String?
    var senderUserId: String?
    
    var conversationId: Int?
    init() {}
    
    required init(json: JSON) throws {
        messageId = try? json.getInt(at: Constants.Message.messageId)
        message = try? json.getString(at: Constants.Message.message)
        created = try? json.getString(at: Constants.Message.created)
        recipientUserId = try? json.getString(at: Constants.Message.recipientUserId)
        senderUserId = try? json.getString(at: Constants.Message.senderUserId)
        
        conversationId = try? json.getInt(at: Constants.Message.conversationId)
    }
    
    init(recipientId: String?, message: String) {
        self.recipientId = recipientId
        self.message = message
    }
    
    func method() -> Alamofire.HTTPMethod {
        return .post
    }
    
    func path() -> String {
        return "/v1/User/Conversation"
    }
    
    func toDictionary() -> [String: AnyObject]? {
        var params: [String: AnyObject] = [:]
        
        params[Constants.Message.recipientId] = recipientId as AnyObject?
        params[Constants.Message.message] = message as AnyObject?
        
        return params
    }
}
