//
//  UserProfileHeader.swift
//  Instagram
//
//  Created by Sovorn on 9/28/18.
//  Copyright © 2018 Sovorn. All rights reserved.
//

import UIKit
import Firebase

protocol UserProfileDelegate {
    func didChangeToList()
    func didChangeToGrid()
}

class UserProfileHeader: UICollectionViewCell {
    
    var delegate: UserProfileDelegate?
    
    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.layer.cornerRadius = 80 / 2
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    lazy var gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        button.addTarget(self, action: #selector(handleGrid), for: .touchUpInside)
        
        return button
    }()
    
    lazy var listButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.3)
        button.addTarget(self, action: #selector(handleList), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handleList(){
        listButton.tintColor = .mainBlue()
        gridButton.tintColor = UIColor(white: 0, alpha: 0.3)
        delegate?.didChangeToList()
    }
    
    @objc func handleGrid(){
        gridButton.tintColor = .mainBlue()
        listButton.tintColor = UIColor(white: 0, alpha: 0.3)
        delegate?.didChangeToGrid()
    }
    
    let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.3)
        
        return button
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        
        return label
    }()
    
    let postsLabel: UILabel = {
        let label = UILabel()
        let atttributeText = NSMutableAttributedString(string: "11\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        atttributeText.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = atttributeText
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }()
    
    let followersLabel: UILabel = {
        let label = UILabel()
        let atttributeText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        atttributeText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = atttributeText
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }()
    
    let followingLabel: UILabel = {
        let label = UILabel()
        let atttributeText = NSMutableAttributedString(string: "0\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        atttributeText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = atttributeText
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }()
    
    lazy var editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(handleEditProfileFollow), for: .touchUpInside)
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        
        setupBottomToolBar()
        
        addSubview(self.usernameLabel)
        usernameLabel.anchor(top: self.profileImageView.bottomAnchor, left: self.leftAnchor, bottom: self.gridButton.topAnchor, right: nil, paddingTop: 4, paddingLeft: 25, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        setupUserStatsView()
        
        addSubview(editProfileButton)
        editProfileButton.anchor(top: postsLabel.bottomAnchor, left: postsLabel.leftAnchor, bottom: nil, right: followingLabel.rightAnchor, paddingTop: 2, paddingLeft: 10, paddingBottom: 0, paddingRight: 0, width: 0, height: 30)
    }
    
    var user: User? {
        didSet{
            if let imageUrl = user?.profileUrl, let name = user?.name {
                self.usernameLabel.text = name
                self.profileImageView.loadImage(urlString: imageUrl)
            }
            
            setupEditFollowButton()
        }
    }
    
    private func setupEditFollowButton(){
        
        guard let currentUid = Auth.auth().currentUser?.uid, let userId = user?.uid else {return}
        if currentUid == userId {
            editProfileButton.setTitle("Edit", for: .normal)
        } else {
            Database.database().reference().child("following").child(currentUid).child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                if let isFollowing = snapshot.value as? Int, isFollowing == 1 {
                    self.editProfileButton.setTitle("Unfollow", for: .normal)
                } else {
                    self.setupFollowSystel()
                }
            }, withCancel: nil)w
        }
    }
    
    @objc func handleEditProfileFollow(){
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        guard let userId = user?.uid else {return}
        
        if editProfileButton.titleLabel?.text == "Unfollow" {
            Database.database().reference().child("following").child(currentUid).child(userId).removeValue { (error, ref) in
                if (error != nil){
                    print(error!)
                    return
                }
                self.setupFollowSystel()
                print("Successfully unfollow")
            }
        } else {
            let ref = Database.database().reference().child("following").child(currentUid)
            let value = [userId: 1]
            ref.updateChildValues(value) { (error, ref) in
                if (error != nil){
                    print("Failed to follow user:", error!)
                    return
                }
                self.editProfileButton.setTitle("Unfollow", for: .normal)
                self.editProfileButton.backgroundColor = .white
                self.editProfileButton.setTitleColor(.black, for: .normal)
                print("Successfully follow")
            }
        }
    }
    
    private func setupFollowSystel(){
        self.editProfileButton.setTitle("Follow", for: .normal)
        self.editProfileButton.backgroundColor = .mainBlue()
        self.editProfileButton.setTitleColor(.white, for: .normal)
        self.editProfileButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
    }
    
    private func setupBottomToolBar(){
        
        let toplineBreak = UIView()
        toplineBreak.backgroundColor = UIColor(white: 0, alpha: 0.1)
        
        let bottomlineBreak = UIView()
        bottomlineBreak.backgroundColor = UIColor(white: 0, alpha: 0.1)
        
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(toplineBreak)
        addSubview(bottomlineBreak)
        stackView.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 40)
        toplineBreak.anchor(top: stackView.topAnchor, left: stackView.leftAnchor, bottom: nil, right: stackView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        bottomlineBreak.anchor(top: stackView.bottomAnchor, left: stackView.leftAnchor, bottom: nil, right: stackView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    private func setupUserStatsView(){
        let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        stackView.distribution = .fillEqually
        addSubview(stackView)
        
        stackView.anchor(top: self.topAnchor, left: self.profileImageView.rightAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 40)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}






