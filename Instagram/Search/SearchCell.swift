//
//  SearchCell.swift
//  Instagram
//
//  Created by Sovorn on 10/2/18.
//  Copyright © 2018 Sovorn. All rights reserved.
//

import UIKit

class SearchCell: UICollectionViewCell {
    
    var user: User? {
        didSet {
            usernameLabel.text = user?.name
            if let urlString = user?.profileUrl {
                profileImageView.loadImage(urlString: urlString)
            }
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 50 / 2
        iv.clipsToBounds = true
        
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Username"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(profileImageView)
        addSubview(usernameLabel)
        
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        usernameLabel.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        let separateView = UIView()
        separateView.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        addSubview(separateView)
        separateView.anchor(top: nil, left: usernameLabel.leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
