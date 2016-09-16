//
//  ConversationViewController.swift
//  PeopleMon
//
//  Created by Brett Keck on 8/26/16.
//  Copyright © 2016 Eleven Fifty. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ConversationViewController: JSQMessagesViewController {
    var conversation: Conversation?
    var messages: [JSQMessage] = []

    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBubbles()
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getMessages()
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(getMessages), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
    }
    
    func getMessages() {
        if let conversation = conversation, let conversationId = conversation.conversationId {
            let conversationList = ConversationList(id: conversationId, pageSize: 100, pageNumber: 0)
            WebServices.shared.getObject(conversationList) { (object, error) in
                if let object = object, let serverMessages = object.messages {
                    self.messages = []
                    for message in serverMessages {
                        self.messages.append(JSQMessage(senderId: message.senderUserId!, displayName: "", text: message.message!))
                    }
                    self.finishReceivingMessage()
                }
            }
        }
    }
    
    private func setupBubbles() {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = bubbleImageFactory?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
        incomingBubbleImageView = bubbleImageFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if text == "" {
            present(Utils.createAlert(message: "You must provide a message text"), animated: true, completion: nil)
            return
        }
        
        let recipientId = conversation?.senderId == senderId ? conversation?.recipientId : conversation?.senderId
        let message = Message(recipientId: recipientId, message: text)
        WebServices.shared.postObject(message) { (object, error) in
            if let error = error {
                self.present(Utils.createAlert(message: error), animated: true, completion: nil)
            } else {
                if let object = object {
                    self.conversation?.conversationId = object.conversationId
                }
                self.messages.append(JSQMessage(senderId: senderId, displayName: UserStore.shared.user?.fullName ?? "", text: message.message ?? ""))
                self.finishSendingMessage()
            }
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView!.textColor = UIColor.white
        } else {
            cell.textView!.textColor = UIColor.black
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
}
