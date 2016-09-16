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
    @IBOutlet weak var avatar: CircleImage!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var person: Person!
    
    func setupCell(person: Person) {
        self.person = person
        
        nameLabel.text = person.username
        if let createdDate = person.created {
            let date = Date(fromString: createdDate, format: .iso8601(nil))
            dateLabel.text = date.toString(.custom("M/d/yyyy h:m:s a"))
        }
        if let image = Utils.imageFromString(imageString: person.avatar) {
            avatar.image = image
        } else {
            avatar.image = Images.Avatar.image()
        }
        avatar.setupView(size: 60)
    }
}
