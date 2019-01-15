//
//  LoginController.swift
//  Instagram
//
//  Created by Sovorn on 9/28/18.
//  Copyright © 2018 Sovorn. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    let logoContainerView: UIView = {
        let view = UIView()
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_white"))
        logoImageView.contentMode = .scaleAspectFill
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(logoImageView)
        logoImageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.backgroundColor = UIColor.rgb(red: 8, green: 121, blue: 173, alpha: 0.8)
        
        return view
    }()
    
    let sigupButton: UIButton = {
        let button = UIButton(type: .system)
        let attributeTitle = NSMutableAttributedString(string: "Don't have an account? ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributeTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.rgb(red: 8, green: 121, blue: 173)]))
        button.setAttributedTitle(attributeTitle, for: .normal)
        button.addTarget(self, action: #selector(handleDontHaveAccount), for: .touchUpInside)
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
    
    let signinButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(("Log In"), for: .normal)
        button.backgroundColor = .blue
        button.backgroundColor = UIColor.rgb(red: 8, green: 121, blue: 173, alpha: 0.5)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.isEnabled = false
        
        return button
    }()
    
    func setupInputFields(){
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, signinButton])
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(stackView)
        
        stackView.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 150)
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        view.addSubview(sigupButton)
        view.addSubview(logoContainerView)
        self.hideKeyboardWhenTappedAround()
        logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 200)
        sigupButton.anchor(top: nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        setupInputFields()
        
    }
    
    @objc func handleDontHaveAccount(){
        let signupController = SignupController()
        navigationController?.pushViewController(signupController, animated: true)
    }
    
    @objc func handleTextInputChange(){
        let isFormValid = (emailTextField.text?.count)! > 0 && (passwordTextField.text?.count)! > 0
        
        
        if isFormValid {
            signinButton.backgroundColor = UIColor.rgb(red: 8, green: 121, blue: 173, alpha: 0.8)
            signinButton.isEnabled = true
        } else {
            signinButton.backgroundColor = UIColor.rgb(red: 8, green: 121, blue: 173, alpha: 0.5)
            signinButton.isEnabled = false
        }
    }
    
    @objc func handleLogin(){
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { (User, error) in
            if (error != nil) {
                print(error!)
                return
            }
            guard let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else {return}
            mainTabBarController.setupViewController()
            self.dismiss(animated: true, completion: nil)
            
        }
    }

}









