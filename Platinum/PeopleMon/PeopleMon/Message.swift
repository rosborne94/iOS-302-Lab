//
//  Message.swift
//  PeopleMon
//
//  Created by Brett Keck on 8/26/16.
//  Copyright © 2016 Eleven Fifty. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class Message: NetworkModel {
    var recipientId: String?
    var message: String?
    
    var messageId: Int?
    var created: String?
    var recipientUserId: String?
    var senderUserId: String?
    
    init() {}
    
    required init(json: JSON) {
        messageId = json[Constants.Message.messageId].int
        message = json[Constants.Message.message].string
        created = json[Constants.Message.created].string
        recipientUserId = json[Constants.Message.recipientUserId].string
        senderUserId = json[Constants.Message.senderUserId].string
    }
    
    init(recipientId: String?, message: String) {
        self.recipientId = recipientId
        self.message = message
    }
    
    func method() -> Alamofire.Method {
        return .POST
    }
    
    func path() -> String {
        return "/v1/User/Conversation"
    }
    
    func toDictionary() -> [String: AnyObject]? {
        var params: [String: AnyObject] = [:]
        
        params[Constants.Message.recipientId] = recipientId
        params[Constants.Message.message] = message
        
        return params
    }
}