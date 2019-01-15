//
//  CommentCell.swift
//  Instagram
//
//  Created by Sovorn on 10/12/18.
//  Copyright © 2018 Sovorn. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell {
    
    var comment: Comment? {
        didSet {
            
            guard let profileUrl = comment?.user.profileUrl, let username = comment?.user.name, let comment = comment?.text else {return}
            
            let attributeText = NSMutableAttributedString(string: username, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
            attributeText.append(NSAttributedString(string: " \(comment)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13)]))
            self.textView.attributedText = attributeText
            
            
            
            self.profileImageView.loadImage(urlString: profileUrl)
        }
    }
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        tv.isScrollEnabled = false
        
        return tv
    }()
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 40 / 2
        iv.backgroundColor = .lightGray
        
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        
        addSubview(textView)
        textView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 4, paddingRight: 4, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
