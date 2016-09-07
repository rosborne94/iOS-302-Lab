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
    
    var timer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBubbles()
        
        // No avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getMessages()
        timer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(getMessages), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
    }
    
    func getMessages() {
        if let conversation = conversation, conversationId = conversation.conversationId {
            let conversationList = ConversationList(id: conversationId, pageSize: 100, pageNumber: 0)
            WebServices.shared.getObject(conversationList) { (object, error) in
                if let object = object, serverMessages = object.messages {
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
        outgoingBubbleImageView = bubbleImageFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = bubbleImageFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        if text == "" {
            presentViewController(Utils.createAlert(message: "You must provide a message text"), animated: true, completion: nil)
            return
        }
        
        let recipientId = conversation?.senderId == senderId ? conversation?.recipientId : conversation?.senderId
        let message = Message(recipientId: recipientId, message: text)
        WebServices.shared.postObject(message) { (object, error) in
            if let error = error {
                self.presentViewController(Utils.createAlert(message: error), animated: true, completion: nil)
            } else {
                if let object = object {
                    self.conversation?.conversationId = object.conversationId
                }
                self.messages.append(JSQMessage(senderId: senderId, displayName: UserStore.shared.user?.fullName ?? "", text: message.message ?? ""))
                self.finishSendingMessage()
            }
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == senderId {
            cell.textView!.textColor = UIColor.whiteColor()
        } else {
            cell.textView!.textColor = UIColor.blackColor()
        }
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
}
