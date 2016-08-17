//
//  RegisterViewController.swift
//  PeopleMon
//
//  Created by Brett Keck on 5/18/16.
//  Copyright © 2016 Eleven Fifty Academy. All rights reserved.
//

import UIKit
import MBProgressHUD

class RegisterViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func registerTapped(sender: AnyObject) {
        guard let username = usernameTextField.text where username != "" else {
            presentViewController(Utils.createAlert("Login Error", message: "Please provide a username"), animated: true, completion: nil)
            return
        }
        
        guard let email = emailTextField.text where email != "" && Utils.isValidEmail(email) else {
            presentViewController(Utils.createAlert("Login Error", message: "Please provide a valid email address"), animated: true, completion: nil)
            return
        }
        
        guard let password = passwordTextField.text where password != "" else {
            presentViewController(Utils.createAlert("Login Error", message: "Please provide a password"), animated: true, completion: nil)
            return
        }
        
        guard let confirm = confirmTextField.text where password == confirm else {
            presentViewController(Utils.createAlert("Login Error", message: "Passwords do not match"), animated: true, completion: nil)
            return
        }
        
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        let user = User(username: username, password: password, email: email)
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