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
    var recipientName: String?
    var lastMessage: String?
    var created: String?
    var messageCount: Int?
    var avatar: String?
    var pageSize: Int?
    var pageNumber: Int?
    
    init() {}
    
    required init(json: JSON) {
        conversationId = json[Constants.Conversation.conversationId].int
        recipientId = json[Constants.Conversation.recipientId].string
        recipientName = json[Constants.Conversation.recipientName].string
        lastMessage = json[Constants.Conversation.lastMessage].string
        created = json[Constants.Conversation.created].string
        messageCount = json[Constants.Conversation.messageCount].int
        avatar = json[Constants.Conversation.avatar].string
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