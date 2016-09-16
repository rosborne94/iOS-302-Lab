//
//  ConversationList.swift
//  PeopleMon
//
//  Created by Brett Keck on 8/26/16.
//  Copyright © 2016 Eleven Fifty. All rights reserved.
//

import UIKit
import Alamofire
import Freddy

class ConversationList: NetworkModel {
    var count: Int?
    var recipientName: String?
    var senderName: String?
    var messages: [Message]?
    
    var id: Int?
    var pageSize: Int?
    var pageNumber: Int?
    
    init() {}
    
    required init(json: JSON) throws {
        count = try? json.getInt(at: Constants.ConversationList.count)
        recipientName = try? json.getString(at: Constants.ConversationList.recipientName)
        senderName = try? json.getString(at: Constants.ConversationList.senderName)
        messages = try? json.getArray(at: Constants.ConversationList.messages).map(Message.init)
    }
    
    init(id: Int, pageSize: Int, pageNumber: Int) {
        self.id = id
        self.pageSize = pageSize
        self.pageNumber = pageNumber
    }
    
    func method() -> Alamofire.HTTPMethod {
        return .get
    }
    
    func path() -> String {
        return "/v1/User/Conversation"
    }
    
    func toDictionary() -> [String: AnyObject]? {
        var params: [String: AnyObject] = [:]
        
        params[Constants.ConversationList.id] = id as AnyObject?
        params[Constants.ConversationList.pageSize] = pageSize as AnyObject?
        params[Constants.ConversationList.pageNumber] = pageNumber as AnyObject?
        
        return params
    }
}
