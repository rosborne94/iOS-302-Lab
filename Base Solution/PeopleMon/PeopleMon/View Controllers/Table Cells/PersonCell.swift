//
//  PersonCell.swift
//  PeopleMon
//
//  Created by Brett Keck on 8/24/16.
//  Copyright © 2016 Eleven Fifty. All rights reserved.
//

import UIKit
import AFDateHelper

class PersonCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var person: Person!
    
    func setupCell(person: Person) {
        self.person = person
        
        nameLabel.text = person.username
        if let createdDate = person.created {
            let date = NSDate(fromString: createdDate, format: .ISO8601(nil))
            dateLabel.text = date.toString(format: .Custom("M/d/yyyy h:m:s a"))
        }
    }
}