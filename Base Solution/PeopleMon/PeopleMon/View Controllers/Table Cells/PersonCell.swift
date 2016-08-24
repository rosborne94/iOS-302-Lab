//
//  PersonCell.swift
//  PeopleMon
//
//  Created by Brett Keck on 8/24/16.
//  Copyright © 2016 Eleven Fifty. All rights reserved.
//

import UIKit

class PersonCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var caughtLabel: UILabel!
    
    var person: Person!
    
    func setupCell(person: Person) {
        self.person = person
        
        nameLabel.text = person.username
        
    }
}