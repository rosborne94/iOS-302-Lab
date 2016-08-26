//
//  CircleImage.swift
//  PeopleMon
//
//  Created by Brett Keck on 8/24/16.
//  Copyright © 2016 Eleven Fifty. All rights reserved.
//

import UIKit

class CircleImage: UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    override func awakeFromNib() {
        self.setupView()
    }
    
    private func setupView() {
        let height = self.frame.height / 2.0
        let width = self.frame.width / 2.0
        self.layer.cornerRadius = min(height,width)
        self.clipsToBounds = true
    }
}
