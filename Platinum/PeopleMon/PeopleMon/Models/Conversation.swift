//
//  Conversation.swift
//  PeopleMon
//
//  Created by Brett Keck on 8/26/16.
//  Copyright © 2016 Eleven Fifty. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

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
    
    init() {}
    
    required init(json: JSON) {
        conversationId = json[Constants.Conversation.conversationId].int
        recipientId = json[Constants.Conversation.recipientId].string
        senderId = json[Constants.Conversation.senderId].string
        recipientName = json[Constants.Conversation.recipientName].string
        senderName = json[Constants.Conversation.senderName].string
        lastMessage = json[Constants.Conversation.lastMessage].string
        created = json[Constants.Conversation.created].string
        messageCount = json[Constants.Conversation.messageCount].int
        recipientAvatar = json[Constants.Conversation.recipientAvatar].string
        senderAvatar = json[Constants.Conversation.senderAvatar].string
    }
    
    init(pageSize: Int, pageNumber: Int) {
        self.pageSize = pageSize
        self.pageNumber = pageNumber
    }
    
    func method() -> Alamofire.Method {
        return .GET
    }
    
    func path() -> String {
        return "/v1/User/Conversations"
    }
    
    func toDictionary() -> [String: AnyObject]? {
        var params: [String: AnyObject] = [:]
        
        params[Constants.Conversation.pageSize] = pageSize
        params[Constants.Conversation.pageNumber] = pageNumber
        
        return params
    }
}