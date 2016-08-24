//
//  UserStore.swift
//  PeopleMon
//
//  Created by Brett Keck on 5/18/16.
//  Copyright © 2016 Eleven Fifty Academy. All rights reserved.
//

import Foundation

class UserStore {
    static let shared = UserStore()
    
    var user: User?
    
    func login(loginUser: User, completion:(success: Bool, error: String?) -> Void) {
        WebServices.shared.authUser(loginUser) { (user, error) -> () in
            if let user = user {
                WebServices.shared.setAuthToken(user.token, expiration: user.expirationDate)
                completion(success: true, error: nil)
            } else {
                completion(success: false, error: error)
            }
        }
    }
    
    func register(registerUser: User, completion:(success: Bool, error: String?) -> Void) {
        WebServices.shared.registerUser(registerUser) { (user, error) -> () in
            if let user = user {
                WebServices.shared.setAuthToken(user.token, expiration: user.expirationDate)
                completion(success: true, error: nil)
            } else {
                completion(success: false, error: error)
            }
        }
    }
    
    func logout(completion:() -> Void) {
        WebServices.shared.clearUserAuthToken()
        completion()
    }
}