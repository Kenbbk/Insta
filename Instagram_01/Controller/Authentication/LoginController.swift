//
//  LoginController.swift
//  Instagram_01
//
//  Created by Woojun Lee on 2023/01/20.
//

import UIKit

protocol AuthenticationDelegate: AnyObject {
    func authenticationDidComplete()
}

class LoginController: UIViewController {
    
    //MARK: - properties
    
    private var viewModel = LoginViewModel()
    
    weak var delegate: AuthenticationDelegate?
    private let iconImage: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "Instagram_logo_white"))
        iv.contentMode = .scaleAspectFill
        return iv
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
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log in", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hue: 279/360, saturation: 44/100, brightness: 95/100, alpha: 0.4)
        button.layer.cornerRadius = 5
        button.setHeight(50)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    private lazy var forgotAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedTitle(firstPart: "Forgot your password?", secondPart: "Get help signing in")
        button.addTarget(self, action: #selector(handleShowResetPassword), for: .touchUpInside)
        return button
        
    }()
    
    private lazy var dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.attributedTitle(firstPart: "Don't have an account?", secondPart: "Sign up")
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
        
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNotificationObservers()
        
        
    }
    
    //MARK: - Actions
    
    @objc func handleShowResetPassword() {
        let controller = ReSetPasswordController()
        controller.delegate = self
        controller.email = emailTextField.text
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleLogin() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordlTextField.text else { return }
        AuthService.logUserIn(email: email, password: password) { result, error in
            if let error = error {
                print("DEBUG: Failed to log user in \(error.localizedDescription)")
                return
            }
            
            self.dismiss(animated: true)
            self.delegate?.authenticationDidComplete()
            
            
        }
    }
    
    @objc func handleShowSignUp() {
        let controller = RegistrationController()
        controller.delegate = delegate
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func textDidChange(sender: UITextField) {
        
        if sender == emailTextField {
            viewModel.email = sender.text
        } else {
            viewModel.password = sender.text
        }
        
        updateForm()
    }
    
    //MARK: - Helpers
    
    func configureUI() {
        configureGrandientLayer()
        //        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black // 뒤에 글자 색을 바꿔줌
        navigationController?.navigationBar.isHidden = true
        
        
        view.addSubview(iconImage)
        iconImage.centerX(inView: view)
        iconImage.setDimensions(height: 80, width: 120)
        iconImage.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        let stack = UIStackView(arrangedSubviews: [emailTextField, passwordlTextField, loginButton, forgotAccountButton])
        stack.axis = .vertical
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.anchor(top: iconImage.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.centerX(inView: view)
        dontHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
    }
    
    
    func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordlTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
}
//MARK: - FormViewModel

extension LoginController: FormViewModel {
    func updateForm() {
        loginButton.backgroundColor = viewModel.buttonBackgroundColor
        loginButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
        loginButton.isEnabled = viewModel.formIsValid
    }
}
//MARK: - ResetPasswordControllerDelegate
extension LoginController: ResetPasswordControllerDelegate {
    func controllerDidSendResetPassword(_ controller: ReSetPasswordController) {
        navigationController?.popViewController(animated: true)
        showMessage(withTitle: "Success", message: "We sent a link to reset your password")
        
    }
    
    
}
