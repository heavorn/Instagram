//
//  User.swift
//  Instagram
//
//  Created by Sovorn on 9/28/18.
//  Copyright © 2018 Sovorn. All rights reserved.
//

import UIKit

class User {
    let uid: String?
    let name: String?
    let profileUrl: String?
    
    init(uid: String, dictionary: [String : Any]) {
        self.uid = uid
        self.name = dictionary["name"] as? String
        self.profileUrl = dictionary["profileUrl"] as? String
    }
}
