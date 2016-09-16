//
//  Conversation.swift
//  PeopleMon
//
//  Created by Brett Keck on 8/26/16.
//  Copyright © 2016 Eleven Fifty. All rights reserved.
//

import Foundation
import Alamofire
import Freddy

class Conversation: NetworkModel {
    var conversationId: Int?
    var recipientId: String?
    var senderId: String?
    var recipientName: String?
    var senderName: String?
    var lastMessage: String?
    var created: String?
    var messageCount: Int?
    var recipientAvatar: String?
    var senderAvatar: String?
    var pageSize: Int?
    var pageNumber: Int?
    
    required init() {}
    
    required init(json: JSON) throws {
        conversationId = try? json.getInt(at: Constants.Conversation.conversationId)
        recipientId = try? json.getString(at: Constants.Conversation.recipientId)
        senderId = try? json.getString(at: Constants.Conversation.senderId)
        recipientName = try? json.getString(at: Constants.Conversation.recipientName)
        senderName = try? json.getString(at: Constants.Conversation.senderName)
        lastMessage = try? json.getString(at: Constants.Conversation.lastMessage)
        created = try? json.getString(at: Constants.Conversation.created)
        messageCount = try? json.getInt(at: Constants.Conversation.messageCount)
        recipientAvatar = try? json.getString(at: Constants.Conversation.recipientAvatar)
        senderAvatar = try? json.getString(at: Constants.Conversation.senderAvatar)
    }
    
    init(pageSize: Int, pageNumber: Int) {
        self.pageSize = pageSize
        self.pageNumber = pageNumber
    }
    
    func method() -> Alamofire.HTTPMethod {
        return .get
    }
    
    func path() -> String {
        return "/v1/User/Conversations"
    }
    
    func toDictionary() -> [String: AnyObject]? {
        var params: [String: AnyObject] = [:]
        
        params[Constants.Conversation.pageSize] = pageSize as AnyObject?
        params[Constants.Conversation.pageNumber] = pageNumber as AnyObject?
        
        return params
    }
}
