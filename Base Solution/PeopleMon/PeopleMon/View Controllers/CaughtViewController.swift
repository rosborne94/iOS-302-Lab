//
//  CaughtViewController.swift
//  PeopleMon
//
//  Created by Brett Keck on 8/24/16.
//  Copyright © 2016 Eleven Fifty. All rights reserved.
//

import UIKit

class CaughtViewController: UITableViewController {
    var caught: [Person] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let person = Person()
        WebServices.shared.getObjects(person) { (objects, error) in
            if let objects = objects {
                self.caught = objects
                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return caught.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(String(PersonCell)) as! PersonCell

        let person = caught[indexPath.row]
        cell.setupCell(person)

        return cell
    }
}
