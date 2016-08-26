//
//  ConversationList.swift
//  PeopleMon
//
//  Created by Brett Keck on 8/26/16.
//  Copyright © 2016 Eleven Fifty. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ConversationList: NetworkModel {
    var count: Int?
    var recipientName: String?
    var senderName: String?
    var messages: [Message]?
    
    var id: Int?
    var pageSize: Int?
    var pageNumber: Int?
    
    init() {}
    
    required init(json: JSON) {
        count = json[Constants.ConversationList.count].int
        recipientName = json[Constants.ConversationList.recipientName].string
        senderName = json[Constants.ConversationList.senderName].string
        let messagesJson = json[Constants.ConversationList.messages].array
        if let messagesJson = messagesJson {
            messages = []
            for message in messagesJson {
                messages?.append(Message(json: message))
            }
        }
        
    }
    
    init(id: Int, pageSize: Int, pageNumber: Int) {
        self.id = id
        self.pageSize = pageSize
        self.pageNumber = pageNumber
    }
    
    func method() -> Alamofire.Method {
        return .GET
    }
    
    func path() -> String {
        return "/v1/User/Conversation"
    }
    
    func toDictionary() -> [String: AnyObject]? {
        var params: [String: AnyObject] = [:]
        
        params[Constants.ConversationList.id] = id
        params[Constants.ConversationList.pageSize] = pageSize
        params[Constants.ConversationList.pageNumber] = pageNumber
        
        return params
    }
}
