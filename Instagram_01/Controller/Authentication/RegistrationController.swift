//
//  RegistrationController.swift
//  Instagram_01
//
//  Created by Woojun Lee on 2023/01/20.
//

import UIKit

class RegistrationController: UIViewController {
    
    //MARK: - properties
    
    private let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo"), for: .normal)
        button.tintColor = .white
        return button
    }()
    
    private let emailTextField: UITextField = {
       let tf = CustomTextField(placeholder: "Email")
        tf.keyboardType = .emailAddress
        
        return tf
    }()
    
    private let passwordlTextField: UITextField = {
       let tf = CustomTextField(placeholder: "Password")
        
        
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let fullNameTextField = CustomTextField(placeholder: "Fullname")
    
    private let userNameTextField = CustomTextField(placeholder: "Username")
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.5216, green: 0, blue: 0.749, alpha: 1.0)
        button.layer.cornerRadius = 5
        button.setHeight(50)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        return button
    }()
    
    private let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.attributedTitle(firstPart: "Already have an account?", secondPart: "Sign up")
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return button
        
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    //MARK: - Actions
    
    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Helpers
    
    func configureUI() {
        configureGrandientLayer()
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.centerX(inView: view)
        plusPhotoButton.setDimensions(height: 140, width: 140)
        plusPhotoButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        let stack = UIStackView(arrangedSubviews: [emailTextField, passwordlTextField, fullNameTextField, userNameTextField, signUpButton])
        stack.axis = .vertical
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.centerX(inView: view)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
    }
}
