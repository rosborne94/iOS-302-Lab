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
        
        nameLabel.text = conversation.recipientName ?? ""
        dateLabel.text = Utils.outputDate(conversation.lastMessage)
        
        if let image = Utils.imageFromString(conversation.avatar) {
            avatar.image = image
        } else {
            avatar.image = Images.Avatar.image()
        }
    }
}
