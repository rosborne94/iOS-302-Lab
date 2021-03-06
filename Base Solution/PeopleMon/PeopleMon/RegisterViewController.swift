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
    @IBOutlet weak var fullNameTextField: UITextField!
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
        guard let fullName = fullNameTextField.text, fullName != "" else {
            present(Utils.createAlert(title: "Login Error", message: "Please provide your name"), animated: true, completion: nil)
            return
        }
        
        guard let email = emailTextField.text, email != "" && Utils.isValidEmail(testStr: email) else {
            present(Utils.createAlert(title: "Login Error", message: "Please provide a valid email address"), animated: true, completion: nil)
            return
        }
        
        guard let password = passwordTextField.text, password != "" else {
            present(Utils.createAlert(title: "Login Error", message: "Please provide a password"), animated: true, completion: nil)
            return
        }
        
        guard let confirm = confirmTextField.text, password == confirm else {
            present(Utils.createAlert(title: "Login Error", message: "Passwords do not match"), animated: true, completion: nil)
            return
        }
        
        MBProgressHUD.showAdded(to: view, animated: true)
        
        let user = User(email: email, password: password, fullName: fullName)
        UserStore.shared.register(registerUser: user) { (success, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if success {
                self.dismiss(animated: true, completion: nil)
            } else if let error = error {
                self.present(Utils.createAlert(message: error), animated: true, completion: nil)
            } else {
                self.present(Utils.createAlert(message: Constants.JSON.unknownError), animated: true, completion: nil)
            }
        }
    }
}
