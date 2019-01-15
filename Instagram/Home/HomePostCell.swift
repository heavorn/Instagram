//
//  HomePostCell.swift
//  Instagram
//
//  Created by Sovorn on 10/2/18.
//  Copyright © 2018 Sovorn. All rights reserved.
//

import UIKit

protocol HomePostCellDelegate {
    func didTapComment(post: Posts)
    func didLike(for cell: HomePostCell)
}

class HomePostCell: UICollectionViewCell {
    
    var delegae: HomePostCellDelegate?
    
    var post: Posts? {
        didSet {
            guard let postImageUrl = post?.imageUrl, let profileUrl = post?.user?.profileUrl, let name = post?.user?.name else {return}
            let likeImageName = post?.has_likeed == true ? "like_selected" : "like_unselected"
            likeButtom.setImage(UIImage(named: likeImageName), for: .normal)
            self.usernameLabel.text = name
            userProfileImageView.loadImage(urlString: profileUrl)
            photoImageView.loadImage(urlString: postImageUrl)
            setupAttributedCaption()
        }
    }
    
    func setupAttributedCaption(){
        guard let post = self.post else {return}
        let attributedText = NSMutableAttributedString(string: (post.user?.name)!, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        let timeAgoDisplay = post.date?.timeAgoDisplay()
        attributedText.append(NSAttributedString(string: "  \(post.caption!)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)]))
        attributedText.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 4)]))
        attributedText.append(NSAttributedString(string: timeAgoDisplay!, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.gray]))
        caption.attributedText = attributedText
    }
    
    let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        
        return v
    }()
    
    let userProfileImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 40 / 2
        iv.clipsToBounds = true
        
        return iv
    }()
    
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        
        return label
    }()
    
    let optionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        return button
    }()
    
    let photoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        
        return iv
    }()
    
    lazy var likeButtom: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "like_unselected")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handleLike(){
        delegae?.didLike(for: self)
    }
    
    lazy var commentButtom: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "comment")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handleComment(){
        guard let post = post else {return}
        delegae?.didTapComment(post: post)
    }
    
    let sendButtom: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "send2")?.withRenderingMode(.alwaysOriginal), for: .normal)
        
        return button
    }()
    
    let bookmarkButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ribbon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        
        return button
    }()
    
    let caption: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(containerView)
        containerView.addSubview(userProfileImageView)
        containerView.addSubview(usernameLabel)
        containerView.addSubview(optionButton)
        containerView.addSubview(photoImageView)
        
        containerView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        userProfileImageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: photoImageView.topAnchor, right: usernameLabel.leftAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 40, height: 40)
        
        usernameLabel.anchor(top: containerView.topAnchor, left: userProfileImageView.rightAnchor, bottom: photoImageView.topAnchor, right: optionButton.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        optionButton.anchor(top: containerView.topAnchor, left: usernameLabel.rightAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        photoImageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 8 + 8 + 40, paddingLeft: 0, paddingBottom: 50, paddingRight: 0, width: 0, height: 0)
        photoImageView.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 1).isActive = true
        setupActionButton()
        containerView.addSubview(caption)
        caption.anchor(top: likeButtom.bottomAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: -10, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
    }
    
    private func setupActionButton(){
        let stackView = UIStackView(arrangedSubviews: [likeButtom, commentButtom, sendButtom])
        stackView.distribution = .fillEqually
        containerView.addSubview(stackView)
        stackView.anchor(top: photoImageView.bottomAnchor, left: containerView.leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 120, height: 50)
        containerView.addSubview(bookmarkButton)
        bookmarkButton.anchor(top: photoImageView.bottomAnchor, left: nil, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 40, height: 50)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}
