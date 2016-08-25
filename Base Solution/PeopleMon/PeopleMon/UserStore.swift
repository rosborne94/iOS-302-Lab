//
//  UserStore.swift
//  PeopleMon
//
//  Created by Brett Keck on 5/18/16.
//  Copyright © 2016 Eleven Fifty Academy. All rights reserved.
//

import Foundation

protocol UserStoreDelegate: class {
    func userLoggedIn()
}

class UserStore {
    static let shared = UserStore()
    
    var user: User? {
        didSet {
            if let _ = user {
                delegate?.userLoggedIn()
            }
        }
    }
    weak var delegate: UserStoreDelegate?
    
    func login(loginUser: User, completion:(success: Bool, error: String?) -> Void) {
        WebServices.shared.authUser(loginUser) { (user, error) -> () in
            if let user = user {
                WebServices.shared.setAuthToken(user.token, expiration: user.expirationDate)
                self.getUserInfo(loginUser, completion: completion)
            } else {
                completion(success: false, error: error)
            }
        }
    }
    
    func register(registerUser: User, completion:(success: Bool, error: String?) -> Void) {
        WebServices.shared.registerUser(registerUser) { (user, error) -> () in
            if let _ = user {
                registerUser.requestType = User.RequestType.Login
                self.login(registerUser, completion: { (success, error) in
                    completion(success: success, error: error)
                })
            } else {
                completion(success: false, error: error)
            }
        }
    }
    
    func getUserInfo(infoUser: User, completion:(success: Bool, error: String?) -> Void) {
        infoUser.requestType = User.RequestType.UserInfo
        WebServices.shared.getObject(infoUser) { (user, error) in
            if let user = user {
                self.user = user
                completion(success: true, error: nil)
            } else {
                completion(success: false, error: error)
            }
        }
    }
    
    func logout(completion:() -> Void) {
        let logoutUser = User()
        logoutUser.requestType = User.RequestType.Logout
        WebServices.shared.postObject(logoutUser) { (object, error) in
            WebServices.shared.clearUserAuthToken()
            completion()
        }
    }
}