//
//  CircleImage.swift
//  PeopleMon
//
//  Created by Brett Keck on 8/24/16.
//  Copyright © 2016 Eleven Fifty. All rights reserved.
//

import UIKit

class CircleImage: UIImageView {
    func setupView(size: CGFloat) {
        let height = size / 2.0
        let width = size / 2.0
        self.layer.cornerRadius = min(height,width)
        self.clipsToBounds = true
    }
}
