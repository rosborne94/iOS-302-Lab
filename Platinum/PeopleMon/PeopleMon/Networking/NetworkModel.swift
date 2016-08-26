//
//  NetworkModel.swift
//  PeopleMon
//
//  Created by Brett Keck on 5/17/16.
//  Copyright © 2016 Eleven Fifty Academy. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol NetworkModel {
    init(json: JSON)
    
    func method() -> Alamofire.Method
    func path() -> String
    func toDictionary() -> [String: AnyObject]?
}