//
//  ConversationTableViewController.swift
//  PeopleMon
//
//  Created by Brett Keck on 8/26/16.
//  Copyright © 2016 Eleven Fifty. All rights reserved.
//

import UIKit

class ConversationTableViewController: UITableViewController, SegueHandlerType {
    var conversations: [Conversation] = []
    
    enum SegueIdentifier: String {
        case OpenConversation
        case NewConversation
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let getConversations = Conversation(pageSize: 100, pageNumber: 0)
        WebServices.shared.getObjects(getConversations) { (objects, error) in
            if let objects = objects {
                self.conversations = objects
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destVC = segue.destinationViewController as! ConversationViewController
        switch  segueIdentifierForSegue(segue) {
        case .OpenConversation:
            let cell = sender as! ConversationCell
            destVC.conversation = cell.conversation
        default:
            break
        }
        destVC.senderId = UserStore.shared.user!.id!
        destVC.senderDisplayName = ""
    }
    

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(String(ConversationCell)) as! ConversationCell
        
        let conversation = conversations[indexPath.row]
        cell.setupCell(conversation)
        
        return cell
    }
}
