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
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell", for: indexPath)

        cell.textLabel!.text = people[indexPath.row].username ?? ""

        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! ConversationTableViewController
        let indexPath = tableView.indexPathForSelectedRow
        destVC.selectedPerson = people[indexPath?.row ?? 0]
    }
}
