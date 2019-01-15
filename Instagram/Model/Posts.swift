//
//  Posts.swift
//  Instagram
//
//  Created by Sovorn on 9/30/18.
//  Copyright © 2018 Sovorn. All rights reserved.
//

import UIKit

class Posts {
    
    var id: String?
    let imageUrl: String?
    let user: User?
    let caption: String?
    let date: Date?
    var has_likeed = false
    
    init(user: User, dictionary: [String : Any]) {
        self.user = user
        self.imageUrl = dictionary["imageUrl"] as? String
        self.caption = dictionary["caption"] as? String
        
        let seconds = dictionary["date"] as? Double
        self.date = NSDate(timeIntervalSince1970: seconds!) as Date
    }
    
    init(dictionary: [String : Any]) {
        self.user = nil
        self.imageUrl = dictionary["imageUrl"] as? String
        self.caption = dictionary["caption"] as? String
        
        let seconds = dictionary["date"] as? Double
        self.date = NSDate(timeIntervalSince1970: seconds!) as Date
    }
    
}
