//
//  Extentions.swift
//  Instagram
//
//  Created by Sovorn on 9/27/18.
//  Copyright © 2018 Sovorn. All rights reserved.
//

import UIKit
import Firebase

extension UISearchBar {
    func changeSearchBarColor(color : UIColor) {
        for subView in self.subviews {
            for subSubView in subView.subviews {
                if let _ = subSubView as? UITextInputTraits {
                    let textField = subSubView as! UITextField
                    textField.backgroundColor = color
                    return
                }
                
            }
        }
    }
}

extension Database {
    static func fetchUserWithUID(uid: String, completion: @escaping (User) ->()){
        let ref = Database.database().reference()
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dic = snapshot.value as? [String: Any] {
                let user = User(uid: uid, dictionary: dic)
                completion(user)
            }
        }, withCancel: nil)
    }
}


extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
    
    static func mainBlue() -> UIColor {
        return UIColor.rgb(red: 17, green: 154, blue: 237)
    }
}

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
    
        if height != 0 {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

extension Date {
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let quotient: Int
        let unit: String
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = "second"
        } else if secondsAgo < hour {
            quotient = secondsAgo / minute
            unit = "min"
        } else if secondsAgo < day {
            quotient = secondsAgo / hour
            unit = "hour"
        } else if secondsAgo < week {
            quotient = secondsAgo / day
            unit = "day"
        } else if secondsAgo < month {
            quotient = secondsAgo / week
            unit = "week"
        } else {
            quotient = secondsAgo / month
            unit = "month"
        }
        
        return "\(quotient) \(unit)\(quotient == 1 ? "" : "s") ago"
        
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

//
//let imageCache = NSCache<NSString, UIImage>()
//
//extension UIImageView {
//
//    func loadImageViewCacheWithUrlString(urlString: String){
//        self.image = nil
//        if let cacheImage = imageCache.object(forKey: urlString as NSString) {
//            self.image = cacheImage
//            return
//        }
//
//        let requestURL = URLRequest(url: URL(string: urlString)!)
//
//        URLSession.shared.dataTask(with: requestURL) { (data, response, error) in
//            if (error != nil) {
//                print("Error to cache image:", error!)
//                return
//            }
//
//            DispatchQueue.main.async {
//                if let downloadImage = UIImage(data: data!) {
//                    imageCache.setObject(downloadImage, forKey: urlString as NSString)
//                    self.image = downloadImage
//                }
//            }
//        }.resume()
//    }
//}
