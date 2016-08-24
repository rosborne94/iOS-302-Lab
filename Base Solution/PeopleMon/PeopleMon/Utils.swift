//
//  Utils.swift
//  PeopleMon
//
//  Created by Brett Keck on 5/18/16.
//  Copyright © 2016 Eleven Fifty Academy. All rights reserved.
//

import UIKit

class Utils {
    class func createAlert(title: String = "Error", message: String, dismissButtonTitle: String = "Dismiss") -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: dismissButtonTitle, style: .Default, handler: nil))
        return alert
    }
    
    class func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = "[A-Za-z0-9-_.]+[@]{1}[A-Za-z0-9-]+[.]*[A-Za-z0-9-]+[.]{1}[A-Za-z]+"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    class func resizeImage(image: UIImage) -> UIImage {
        let maxSize: CGFloat = 128
        let newSize: CGSize!
        if image.size.width > image.size.height {
            newSize = CGSize(width: maxSize, height: maxSize * (image.size.height / image.size.width))
        } else {
            newSize = CGSize(width: maxSize * (image.size.width / image.size.height), height: maxSize)
        }
        
        let newRect = CGRectIntegral(CGRectMake(0,0, newSize.width, newSize.height))
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetInterpolationQuality(context, .High)
        let flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height)
        CGContextConcatCTM(context, flipVertical)
        CGContextDrawImage(context, newRect, image.CGImage)
        let newImage = UIImage(CGImage: CGBitmapContextCreateImage(context)!)
        UIGraphicsEndImageContext()
        return newImage
    }
    
    class func imageFromString(imageString: String?) -> UIImage? {
        if let imageString = imageString, imageData = NSData(base64EncodedString: imageString, options: .IgnoreUnknownCharacters) {
            return UIImage(data: imageData)
        }
        return Images.Avatar.image()
    }
    
    class func stringFromImage(image: UIImage?) -> String {
        if let image = image, imageData = UIImagePNGRepresentation(image) {
            return imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
        }
        return ""
    }
}