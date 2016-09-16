//
//  ProfileViewController.swift
//  PeopleMon
//
//  Created by Brett Keck on 8/24/16.
//  Copyright © 2016 Eleven Fifty. All rights reserved.
//

import UIKit
import MBProgressHUD

class ProfileViewController: UIViewController {
    @IBOutlet weak var avatar: CircleImage!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = UserStore.shared.user {
            nameField.text = user.fullName
            emailLabel.text = user.email
            
            if let image = Utils.imageFromString(imageString: user.avatar) {
                avatar.image = image
            } else {
                avatar.image = Images.Avatar.image()
            }
            avatar.setupView(size: 80)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func getPicture(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func saveProfile(sender: AnyObject) {
        guard let name = nameField.text, name != "" else {
            self.present(Utils.createAlert(message: "You must provide a name"), animated: true, completion: nil)
            return
        }
        
        let resizedImage = Utils.resizeImage(image: avatar.image!, maxSize: Constants.serverImageSize)
        let imageString = Utils.stringFromImage(image: resizedImage)
        let user = User(fullName: name, avatar: imageString)
        
        MBProgressHUD.showAdded(to: view, animated: true)
        WebServices.shared.postObject(user) { (updatedUser, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let error = error {
                self.present(Utils.createAlert(message: error), animated: true, completion: nil)
            } else {
                UserStore.shared.user?.fullName = name
                UserStore.shared.user?.avatar = imageString
            }
        }
    }
}

extension ProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info["UIImagePickerControllerEditedImage"] as? UIImage {
            let resizedImage = Utils.resizeImage(image: image, maxSize: Constants.serverImageSize)
            avatar.image = resizedImage
        }
    }
}
