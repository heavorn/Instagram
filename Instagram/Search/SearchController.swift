//
//  SearchController.swift
//  Instagram
//
//  Created by Sovorn on 10/2/18.
//  Copyright © 2018 Sovorn. All rights reserved.
//

import UIKit
import Firebase

class SearchController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    let cellId = "cellId"
    
    lazy var searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.delegate = self
        sb.placeholder = "Enter username"
        
        return sb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView?.register(SearchCell.self, forCellWithReuseIdentifier: cellId)
        navigationController?.navigationBar.addSubview(searchBar)
        collectionView?.keyboardDismissMode = .onDrag
        searchBar.changeSearchBarColor(color: UIColor.rgb(red: 240, green: 240, blue: 240))
        let navBar = navigationController?.navigationBar
        
        searchBar.anchor(top: navBar?.topAnchor, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        fetchUser()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filterUser = users
        } else {
            filterUser = self.users.filter { (user) -> Bool in
                return (user.name?.lowercased().contains(searchText.lowercased()))!
            }
        }
        self.collectionView.reloadData()
    }
    
    var filterUser = [User]()
    var users = [User]()
    
    private func fetchUser(){
        let ref = Database.database().reference().child("users")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dic = snapshot.value as? [String: Any] {
                dic.forEach({ (key, value) in
                    if key == Auth.auth().currentUser!.uid {return}
                    guard let userDic = value as? [String: Any] else {return}
                    let user = User(uid: key, dictionary: userDic)
                    self.users.append(user)
                })
            }
            self.users.sort(by: { (u1, u2) -> Bool in
                return u1.name?.compare(u2.name!) == .orderedAscending
            })
            
            self.filterUser = self.users
            self.collectionView.reloadData()
        }, withCancel: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = filterUser[indexPath.item]
        
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        let userProfileControler = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileControler.userID = user.uid
        navigationController?.pushViewController(userProfileControler, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterUser.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchCell
        cell.user = self.filterUser[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 66)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        searchBar.isHidden = false
    }
}
