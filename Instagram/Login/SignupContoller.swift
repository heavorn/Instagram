//
//  ViewController.swift
//  Instagram
//
//  Created by Sovorn on 9/27/18.
//  Copyright © 2018 Sovorn. All rights reserved.
//

import UIKit
import Firebase

class SignupController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        
        return button
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return tf
    }()
    
    let userNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        
        return tf
    }()

    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(("Sign Un"), for: .normal)
        button.backgroundColor = .blue
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleSigup), for: .touchUpInside)
        button.isEnabled = false
        
        return button
    }()
    
    let signinButton: UIButton = {
        let button = UIButton(type: .system)
        let attributeTitle = NSMutableAttributedString(string: "Alreadt have an account? ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributeTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.rgb(red: 8, green: 121, blue: 173)]))
        button.setAttributedTitle(attributeTitle, for: .normal)
                button.addTarget(self, action: #selector(handleAlreadyHaveAccount), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(plusPhotoButton)
        view.backgroundColor = .white
        self.hideKeyboardWhenTappedAround()
        
        plusPhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        setupInputFields()
        
        view.addSubview(signinButton)
        signinButton.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    }
    
    func setupInputFields(){
    
        let stackView = UIStackView(arrangedSubviews: [userNameTextField, emailTextField, passwordTextField, signUpButton])
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 200)
        
    }
    
    @objc func handleSigup(){
        
        guard let email = emailTextField.text, email.count > 0 else { return }
        guard let password = passwordTextField.text, password.count > 0 else { return }
        guard let name = userNameTextField.text, name.count > 0 else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (User, error) in
            if (error != nil) {
                print("Error create email and password", error!)
                return
            }
            let imageName = NSUUID().uuidString
            guard let uid = Auth.auth().currentUser?.uid else { return }
            guard let image = self.plusPhotoButton.imageView?.image else {return}
            guard let uploadData = image.jpegData(compressionQuality: 0.3) else {return}
            let storage = Storage.storage().reference().child("profile_image").child("\(imageName).jpg")
            
            storage.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if (error != nil){
                    print(error!)
                    return
                }
                
                storage.downloadURL(completion: { (url, error) in
                    if (error != nil){
                        print(error!)
                        return
                    }
                    if let profileUrl = url?.absoluteString {
                        let values = ["name": name, "email": email, "profileUrl": profileUrl]
                        self.registerUserIntoDatabase(id: uid, values: values as [String : AnyObject])
                    }
                })
                
            })
        }
    }
    
    private func registerUserIntoDatabase(id: String, values: [String : AnyObject]){
        
        Database.database().reference().child("users").child(id).updateChildValues(values, withCompletionBlock: { (error, ref) in
            if (error != nil){
                print(error!)
                return
            }
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else {return}
            mainTabBarController.setupViewController()
            
            self.dismiss(animated: true, completion: nil)   
        })
    }
    
    @objc func handleTextInputChange(){
        let isFormValid = (emailTextField.text?.count)! > 0 && (userNameTextField.text?.count)! > 0 && (passwordTextField.text?.count)! > 0
        
        
        if isFormValid {
            signUpButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
            signUpButton.isEnabled = true
        } else {
            signUpButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
            signUpButton.isEnabled = false
        }
    }
    
    @objc func handlePlusPhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true)
    }
    
    @objc func handleAlreadyHaveAccount(){
        navigationController?.popViewController(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        if let editImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            plusPhotoButton.setImage(editImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let origialImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            plusPhotoButton.setImage(origialImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
        plusPhotoButton.layer.masksToBounds = true
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    
}



























// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
