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
    var newUsers: [Person] = []
    var selectedPerson: Person?
    
    enum SegueIdentifier: String {
        case OpenConversation
        case NewConversation
        case SelectUser
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let getConversations = Conversation(pageSize: 100, pageNumber: 0)
        WebServices.shared.getObjects(getConversations) { (objects, error) in
            if let objects = objects {
                self.conversations = objects
                self.tableView.reloadData()
                
                let person = Person()
                WebServices.shared.getObjects(person) { (people, error) in
                    if let people = people {
                        self.newUsers = people.filter({ (person) -> Bool in
                            let matches = self.conversations.filter({ (conversation) -> Bool in
                                return conversation.senderId == person.userId || conversation.recipientId == person.userId
                            })
                            return matches.count == 0
                        })
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch  segueIdentifierForSegue(segue: segue) {
        case .OpenConversation:
            let destVC = segue.destination as! ConversationViewController
            let cell = sender as! ConversationCell
            destVC.conversation = cell.conversation
            destVC.senderId = UserStore.shared.user!.id!
            destVC.senderDisplayName = ""
        case .NewConversation:
            let destVC = segue.destination as! ConversationViewController
            let conversation = Conversation()
            conversation.recipientId = selectedPerson?.userId
            conversation.senderId = UserStore.shared.user!.id!
            destVC.conversation = conversation
            destVC.senderId = UserStore.shared.user!.id!
            destVC.senderDisplayName = ""
        case .SelectUser:
            let destVC = segue.destination as! SelectUserViewController
            destVC.people = newUsers
        }
    }
    

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ConversationCell.self)) as! ConversationCell
        
        let conversation = conversations[indexPath.row]
        cell.setupCell(conversation: conversation)
        
        return cell
    }
    
    // MARK: - IBActions
    @IBAction func setNewConversationUser(segue: UIStoryboardSegue) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.performSegueWithIdentifier(segueIdentifier: .NewConversation, sender: self)
        }
    }
}

extension ConversationTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return newUsers.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return newUsers[row].username
    }
}
