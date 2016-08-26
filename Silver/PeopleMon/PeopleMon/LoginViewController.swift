//
//  LoginViewController.swift
//  PeopleMon
//
//  Created by Brett Keck on 5/18/16.
//  Copyright © 2016 Eleven Fifty Academy. All rights reserved.
//

import UIKit
import MBProgressHUD

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func loginTapped(sender: AnyObject) {
        guard let email = emailTextField.text where email != "" else {
            presentViewController(Utils.createAlert("Login Error", message: "Please provide your email"), animated: true, completion: nil)
            return
        }
        
        guard let password = passwordTextField.text where password != "" else {
            presentViewController(Utils.createAlert("Login Error", message: "Please provide a password"), animated: true, completion: nil)
            return
        }
        
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        let user = User(email: email, password: password)
        UserStore.shared.login(user) { (success, error) in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            if success {
                self.dismissViewControllerAnimated(true, completion: nil)
            } else if let error = error {
                self.presentViewController(Utils.createAlert(message: error), animated: true, completion: nil)
            } else {
                self.presentViewController(Utils.createAlert(message: Constants.JSON.unknownError), animated: true, completion: nil)
            }
        }
    }
}
