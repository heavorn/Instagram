//
//  HomeController.swift
//  Instagram
//
//  Created by Sovorn on 10/2/18.
//  Copyright © 2018 Sovorn. All rights reserved.
//

import UIKit
import Firebase

class HomeController: UICollectionViewController, UICollectionViewDelegateFlowLayout, HomePostCellDelegate {
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: SharePhoto.updateFeedNotificationName, object: nil)
        collectionView?.backgroundColor = UIColor(white: 1, alpha: 0.95)
        collectionView.register(HomePostCell.self, forCellWithReuseIdentifier: cellId)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "camera")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleCamera))
        
        setupNavigationItems()
        fetchPosts()
        fetchFollowingUserIds()
    }
    
    @objc func handleCamera(){
        let controller = CameraController()
        present(controller, animated: true)
    }
    
    @objc func handleUpdateFeed() {
        handleRefresh()
    }
    
    @objc func handleRefresh(){
        print("refresh")
        posts.removeAll()
        self.fetchFollowingUserIds()
        self.fetchPosts()
    }
    
    func setupNavigationItems(){
        navigationItem.titleView = UIImageView(image: UIImage(named: "logo2"))
    }
    
    var posts = [Posts]()
    
    private func fetchPosts(){
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Error uid")
            return
            
        }
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.fetchPostWithUser(user: user)
        }
    }
    
    private func fetchFollowingUserIds(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child("following").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let userIdsDic = snapshot.value as? [String: Any]{
                userIdsDic.forEach({ (key, value) in
                    Database.fetchUserWithUID(uid: key, completion: { (user) in
                        self.fetchPostWithUser(user: user)
                    })
                })
            }
        }, withCancel: nil)
    }
    
    func fetchPostWithUser(user: User){
        let ref = Database.database().reference()
        ref.child("posts").child(user.uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            self.collectionView?.refreshControl?.endRefreshing()
            guard let dictionary = snapshot.value as? [String: Any] else {return}
            dictionary.forEach({ (key, value) in
                if let dic = value as? [String: Any] {
                    let post = Posts(user: user, dictionary: dic)
                    post.id = key
                    guard let uid = Auth.auth().currentUser?.uid else {return}
                    Database.database().reference().child("likes").child(key).child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let value = snapshot.value as? Int, value == 1 {
                            post.has_likeed = true
                        } else {
                            post.has_likeed = false
                        }
                        self.posts.append(post)
                        self.posts.sort(by: { (p1, p2) -> Bool in
                            return p1.date?.compare(p2.date!) == .orderedDescending
                        })
                        self.collectionView?.reloadData()
                    }, withCancel: nil)
                }
            })
        }, withCancel: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HomePostCell
        cell.post = self.posts[indexPath.item]
        cell.delegae = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 40 + 8 + 8 + 50 + 55
        height += view.frame.width
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func didTapComment(post: Posts) {
        let commentController = CommentController(collectionViewLayout: UICollectionViewFlowLayout())
        commentController.post = post
        navigationController?.pushViewController(commentController, animated: true)
    }
    
    func didLike(for cell: HomePostCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else {return}
        let post = self.posts[indexPath.item]
        if let postId = post.id {
            guard let uid = Auth.auth().currentUser?.uid else {return}
            let value = [uid: post.has_likeed == true ? 0 : 1]
            Database.database().reference().child("likes").child(postId).updateChildValues(value) { (err, ref) in
                if (err != nil){
                    print("Failed update like", err!)
                    return
                }
                print("Successfully like post")
                post.has_likeed = !post.has_likeed
                self.posts[indexPath.item] = post
                self.collectionView?.reloadItems(at: [indexPath])
            }
        }
        
//        cell.likeButtom.setImage(UIImage(named: "like_selected"), for: .normal)
    }
}
