//
//  SharePhoto.swift
//  Instagram
//
//  Created by Sovorn on 9/29/18.
//  Copyright © 2018 Sovorn. All rights reserved.
//

import UIKit
import Firebase

class SharePhoto: UIViewController {
    
    var selectedImage: UIImage? {
        didSet {
            self.imageView.image = selectedImage
        }
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .red
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        
        return iv
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 14)
        
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(handleShare))
        setupImageAndTextView()
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    private func setupImageAndTextView(){
        let containerView = UIView()
        containerView.backgroundColor = .white
        
        view.addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(textView)
        
        containerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 100)
        
        imageView.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 0, width: 84, height: 0)
        
        textView.anchor(top: containerView.topAnchor, left: imageView.rightAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 6, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    @objc func handleShare(){
        
        guard let caption = textView.text, caption.count > 0 else {return}
        guard let image = selectedImage else {return}
        let fileName = NSUUID().uuidString
        let uploadData = image.jpegData(compressionQuality: 0.5)
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        let storageFile = Storage.storage().reference().child("upload_photo").child("\(fileName).jpg")
        storageFile.putData(uploadData!, metadata: nil) { (metadata, error) in
            if (error != nil){
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                print(error!)
                return
            }
            
            storageFile.downloadURL(completion: { (url, error) in
                if (error != nil){
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    print(error!)
                    return
                }
                
                if let imageUrl = url?.absoluteString {
                    self.saveToDatabaseWithImageUrl(imageUrl: imageUrl)
                }
            })
        }
    }
    
    static let updateFeedNotificationName = NSNotification.Name(rawValue: "UpdateFeed")
    
    func saveToDatabaseWithImageUrl(imageUrl: String){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let postImage = selectedImage else {return}
        guard let caption = textView.text else {return}
        let userPostRef = Database.database().reference().child("posts").child(uid)
        let ref = userPostRef.childByAutoId()
        let values = ["imageUrl": imageUrl, "caption": caption, "width": postImage.size.width, "height": postImage.size.height, "date": Date().timeIntervalSince1970] as [String : Any]
        ref.updateChildValues(values) { (error, ref) in
            if (error != nil){
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                print(error!)
                return
            }
            print("Successfully save to DB")
            self.dismiss(animated: true, completion: nil)
            
            NotificationCenter.default.post(name: SharePhoto.updateFeedNotificationName, object: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        UIApplication.shared.isStatusBarHidden = false
    }
    
}
