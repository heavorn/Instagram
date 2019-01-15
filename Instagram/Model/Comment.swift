//
//  Comment.swift
//  Instagram
//
//  Created by Sovorn on 10/12/18.
//  Copyright © 2018 Sovorn. All rights reserved.
//

import UIKit

struct Comment {
    let text: String
    let uid: String
    var user: User
    
    init(user: User, dictionary: [String: Any]) {
        self.user = user
        self.text = dictionary["text"] as! String
        self.uid = dictionary["uid"] as! String
    }
}
