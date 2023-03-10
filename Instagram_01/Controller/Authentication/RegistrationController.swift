//
//  RegistrationController.swift
//  Instagram_01
//
//  Created by Woojun Lee on 2023/01/20.
//

import UIKit

class RegistrationController: UIViewController {
    
    //MARK: - properties
    private var viewModel = RegistrationViewModel()
    
    private var profileImage: UIImage?
    
    weak var delegate: AuthenticationDelegate?
    
    private lazy var plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(handleProfilePhotoSelect), for: .touchUpInside)
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
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hue: 279/360, saturation: 44/100, brightness: 95/100, alpha: 0.4)
        button.layer.cornerRadius = 5
        button.setHeight(50)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        return button
    }()
    
    private lazy var alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.attributedTitle(firstPart: "Already have an account?", secondPart: "Sign up")
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return button
        
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureNotificationObservers()
    }
    
    //MARK: - Actions
    
    @objc func handleSignUp() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordlTextField.text else { return }
        guard let fullname = fullNameTextField.text else { return }
        guard let username = userNameTextField.text?.lowercased() else { return }
        guard let profileImage = self.profileImage else { return }
        
        let credentials = AuthCrendentials(email: email, password: password, fullname: fullname, username: username, profileImage: profileImage)
        
        AuthService.registerUser(withCredential: credentials) { error in
            if let error = error {
                print("DEBUG: Failed to register user \(error.localizedDescription)")
                return
            }
            
            self.delegate?.authenticationDidComplete()
        }
    }
    
    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func textDidChange(sender: UITextField) {
        
        switch sender {
        case emailTextField:
            viewModel.email = sender.text
        case passwordlTextField:
            viewModel.password = sender.text
        case fullNameTextField:
            viewModel.fullname = sender.text
        case userNameTextField:
            viewModel.username = sender.text
        default:
            print("DEBUG: UNKNOWN")
        }
        
        updateForm()
        
    }
    
    @objc func handleProfilePhotoSelect() {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        picker.allowsEditing = true
        
        
        
        present(picker, animated: true, completion: nil)
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
    
    func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordlTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        fullNameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        userNameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
}

extension RegistrationController: FormViewModel {
    func updateForm() {
        signUpButton.backgroundColor = viewModel.buttonBackgroundColor
        signUpButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
        signUpButton.isEnabled = viewModel.formIsValid
    }
    
    
}

//MARK: - UIImagePickerControllerDelegate

extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        profileImage = selectedImage
        
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
//        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.clipsToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.white.cgColor
        plusPhotoButton.layer.borderWidth = 2
        plusPhotoButton.setImage(selectedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        self.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("DEBUG: I am canceled")
        dismiss(animated: true)
    }
}
