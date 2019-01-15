//
//  UserProfileController.swift
//  Instagram
//
//  Created by Sovorn on 9/28/18.
//  Copyright © 2018 Sovorn. All rights reserved.
//

import UIKit
import Firebase

class UserProfileController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileDelegate {
    
    var user: User?
    var userID: String?
    let cellId = "cellId"
    let homeProfileCellId = "homeProfileCellId"
    
    var isGridView = true
    
    func didChangeToList() {
        isGridView = false
        collectionView?.reloadData()
    }
    
    func didChangeToGrid() {
        isGridView = true
        collectionView?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUser()
        collectionView?.backgroundColor = .white
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
        collectionView?.register(UserProfilePhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(HomePostCell.self, forCellWithReuseIdentifier: homeProfileCellId)
        collectionView?.alwaysBounceVertical = true
        
        setupLogout()
    }
    
    var isFinishPaging = false
    var posts = [Posts]()
    
    private func fetchUser(){
//        guard let uid = Auth.auth().currentUser?.uid else {return}
        let uid = userID ?? (Auth.auth().currentUser?.uid)!
        Database.fetchUserWithUID(uid: uid) { (user) in
            self.user = user
            self.navigationItem.title = self.user?.name
            self.collectionView?.reloadData()
//            self.fetchPosts()
            self.paginatePosts()
        }
    }

    private func paginatePosts(){
        guard let uid = self.user?.uid else {return}
        let ref = Database.database().reference().child("posts").child(uid)
//        var query = ref.queryOrderedByKey()
        var query = ref.queryOrdered(byChild: "date")
        if self.posts.count > 0 {
            let value = posts.last?.date?.timeIntervalSince1970
//            let value = posts.last?.id
            query = query.queryEnding(atValue: value)
        }

        query.queryLimited(toLast: 4).observeSingleEvent(of: .value, with: { (snapshot) in
            guard var allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
            guard let user = self.user else {return}
            allObjects.reverse()
            if allObjects.count < 4 {
                self.isFinishPaging = true
            }
            if self.posts.count > 0 && allObjects.count > 0 {
                allObjects.removeFirst()
            }
            allObjects.forEach({ (snapshot) in
                if let dic = snapshot.value as? [String: Any] {
                    let post = Posts(user: user, dictionary: dic)
                    post.id = snapshot.key
                    self.posts.append(post)
                }
            })
            self.collectionView.reloadData()

        }, withCancel: nil)
    }

//    private func fetchPosts(){
//        guard let uid = self.user?.uid else {return}
//        let ref = Database.database().reference().child("posts").child(uid)
//        ref.observe(.childAdded, with: { (snapshot) in
//            ref.child(snapshot.key).queryOrdered(byChild: "date").observeSingleEvent(of: .value, with: { (shapshot) in
//                if let dic = snapshot.value as? [String : Any] {
//                    guard let user = self.user else {return}
//                    let post = Posts(user: user, dictionary: dic)
//                    self.posts.insert(post, at: 0)
//                }
//                self.collectionView?.reloadData()
//            }, withCancel: nil)
//        }, withCancel: nil)
//    }
    
    func setupLogout(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogout))
    }
    
    @objc func handleLogout(){
        let ac = UIAlertController()
        ac.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do {
                try Auth.auth().signOut()
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true)
            } catch let singOut {
                print("Error sign out", singOut)
            }
        }))

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        ac.view.tintColor = .black
        present(ac, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 180)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! UserProfileHeader
        header.user = self.user
        header.delegate = self
        
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isGridView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! UserProfilePhotoCell
            cell.post = posts[indexPath.item]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeProfileCellId, for: indexPath) as! HomePostCell
            cell.post = posts[indexPath.item]
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //how to fire off paginate call
        if indexPath.item == self.posts.count - 1 && !isFinishPaging {
            paginatePosts()
        }
        
        if isGridView {
            let width = (view.frame.width - 2) / 3
            
            return CGSize(width: width, height: width)
        } else {
            var height: CGFloat = 40 + 8 + 8 + 50 + 55
            height += view.frame.width
            
            return CGSize(width: view.frame.width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
}















