//
//  SelectUserViewController.swift
//  PeopleMon
//
//  Created by Brett Keck on 9/7/16.
//  Copyright © 2016 Eleven Fifty. All rights reserved.
//

import UIKit

class SelectUserViewController: UITableViewController {
    var people: [Person] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PersonCell", forIndexPath: indexPath)

        cell.textLabel!.text = people[indexPath.row].username ?? ""

        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destVC = segue.destinationViewController as! ConversationTableViewController
        let indexPath = tableView.indexPathForSelectedRow
        destVC.selectedPerson = people[indexPath?.row ?? 0]
    }
}
