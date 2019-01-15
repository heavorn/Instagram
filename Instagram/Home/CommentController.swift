//
//  CommentController.swift
//  Instagram
//
//  Created by Sovorn on 10/3/18.
//  Copyright © 2018 Sovorn. All rights reserved.
//

import UIKit
import Firebase

class CommentController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    var post: Posts?
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        collectionView?.keyboardDismissMode = .interactive
        collectionView?.alwaysBounceVertical = true
        navigationItem.title = "Comments"
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: cellId)
        fetchComment()
    }
    
    var comments = [Comment]()
    
    private func fetchComment(){
        guard let postId = self.post?.id else {return}
        let ref = Database.database().reference().child("comments").child(postId)
        ref.observe(.childAdded, with: { (snapshot) in
            if let dic = snapshot.value as? [String: Any] {
                guard let uid = dic["uid"] as? String else {return}
                Database.fetchUserWithUID(uid: uid, completion: { (user) in
                    let comment = Comment(user: user, dictionary: dic)
                    self.comments.append(comment)
                    self.collectionView.reloadData()
                })
            }
        }, withCancel: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CommentCell
        cell.comment = self.comments[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimateSize = dummyCell.systemLayoutSizeFitting(targetSize)
        let height = max(40 + 8 + 8, estimateSize.height)
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    lazy var textField: UITextField = {
        let text = UITextField()
        text.placeholder = "Enter comment..."
        text.translatesAutoresizingMaskIntoConstraints = false
        text.delegate = self
        
        return text
    }()
    
    var _inputAccessoryView: UIView!
    
    override var inputAccessoryView: UIView?{
        
        if _inputAccessoryView == nil {
            
            let sendButton: UIButton = {
                let button = UIButton()
                button.setTitle("send", for: .normal)
                button.setTitleColor(.black, for: .normal)
                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
                button.translatesAutoresizingMaskIntoConstraints = false
                button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
                
                return button
            }()
            
            let lineBreak: UIView = {
                let line = UIView()
                line.translatesAutoresizingMaskIntoConstraints = false
                line.backgroundColor = UIColor(red: 191/255, green: 191/255, blue: 191/255, alpha: 1.0)
                
                return line
            }()
            
            _inputAccessoryView = CustomView()
            _inputAccessoryView.backgroundColor = .white
            _inputAccessoryView.autoresizingMask = .flexibleHeight
            
            _inputAccessoryView.addSubview(self.textField)
            _inputAccessoryView.addSubview(sendButton)
            _inputAccessoryView.addSubview(lineBreak)
            
            self.textField.anchor(top: _inputAccessoryView.topAnchor, left: _inputAccessoryView.leftAnchor, bottom: _inputAccessoryView.layoutMarginsGuide.bottomAnchor, right: sendButton.leftAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 4, paddingRight: 0, width: 0, height: 0)
            
            sendButton.anchor(top: _inputAccessoryView.topAnchor, left: nil, bottom: _inputAccessoryView.layoutMarginsGuide.bottomAnchor, right: _inputAccessoryView.rightAnchor, paddingTop: 4, paddingLeft: 0, paddingBottom: 4, paddingRight: -4, width: 80, height: 0)
            lineBreak.anchor(top: nil, left: _inputAccessoryView.leftAnchor, bottom: _inputAccessoryView.topAnchor, right: _inputAccessoryView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 1)
        }
        
        return _inputAccessoryView
    }
    
    @objc func handleSend(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let postId = post?.id
        let values = ["text": self.textField.text!, "date": Date().timeIntervalSince1970, "uid": uid] as [String: Any]
        Database.database().reference().child("comments").child(postId!).childByAutoId().updateChildValues(values) { (error, ref) in
            if (error != nil){
                print("Failed to insert commment:", error!)
            }
            self.textField.text = ""
            print("Successfully insert comment")
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        tabBarController?.tabBar.isHidden = false
    }
}

class CustomView: UIView {
    
    // this is needed so that the inputAccesoryView is properly sized from the auto layout constraints
    // actual value is not important
    
    override var intrinsicContentSize: CGSize {
        return CGSize.zero
    }
}
