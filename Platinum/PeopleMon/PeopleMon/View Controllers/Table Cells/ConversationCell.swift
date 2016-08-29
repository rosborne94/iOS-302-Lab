//
//  ConversationCell.swift
//  PeopleMon
//
//  Created by Brett Keck on 8/26/16.
//  Copyright © 2016 Eleven Fifty. All rights reserved.
//

import UIKit

class ConversationCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var conversation: Conversation!
    
    func setupCell(conversation: Conversation) {
        self.conversation = conversation
        
        dateLabel.text = Utils.outputDate(conversation.lastMessage)
        if conversation.senderId == UserStore.shared.user?.id {
            nameLabel.text = conversation.recipientName ?? ""
            
            if let image = Utils.imageFromString(conversation.recipientAvatar) {
                avatar.image = image
            } else {
                avatar.image = Images.Avatar.image()
            }
        } else {
            nameLabel.text = conversation.senderName ?? ""
            
            if let image = Utils.imageFromString(conversation.senderAvatar) {
                avatar.image = image
            } else {
                avatar.image = Images.Avatar.image()
            }
        }
    }
}
