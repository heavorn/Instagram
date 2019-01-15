//
//  MainTabBarController.swift
//  Instagram
//
//  Created by Sovorn on 9/28/18.
//  Copyright © 2018 Sovorn. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController, UITabBarControllerDelegate{
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.index(of: viewController)
        if (index == 2) {
            let photoSelectorController = PhotoSelectorController(collectionViewLayout: UICollectionViewFlowLayout())
            let navController = UINavigationController(rootViewController: photoSelectorController)
            present(navController, animated: true)
            
            return false
        }
        
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        if Auth.auth().currentUser?.uid == nil {
            DispatchQueue.main.async {
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true)
            }
            return
        }
        
        setupViewController()
        
    }
    
    func setupViewController() {
        
        //Home
        let homeNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: HomeController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        //Search
        let searchNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"), rootViewController: SearchController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        //plus
        
        let plusNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"))
        
        //like
        
        let likeNavController = templateNavController(unselectedImage: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"))
        
        //User profile
        let userProfileController = UserProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        let profileNavControlller = UINavigationController(rootViewController: userProfileController)
        profileNavControlller.tabBarItem.image = #imageLiteral(resourceName: "profile_unselected")
        profileNavControlller.tabBarItem.selectedImage = #imageLiteral(resourceName: "profile_selected")
        
        tabBar.tintColor = .black
        
        viewControllers = [homeNavController, searchNavController, plusNavController, likeNavController, profileNavControlller]
        
        tabBar.items?.forEach{
            $0.imageInsets = UIEdgeInsets(top: 4, left: 0, bottom: -4, right: 0)
        }
    }
    
    private func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        
        return navController
    }
}






