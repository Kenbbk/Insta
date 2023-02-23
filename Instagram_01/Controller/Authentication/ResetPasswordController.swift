//
//  ResetPasswordController.swift
//  Instagram_01
//
//  Created by Woojun Lee on 2023/02/06.
//

import UIKit

protocol ResetPasswordControllerDelegate: AnyObject {
    func controllerDidSendResetPassword(_ controller: ReSetPasswordController)
}

class ReSetPasswordController: UIViewController {
    //MARK: - Properties
    
    private let emailTextField = CustomTextField(placeholder: "Email")
    private var viewModel = ResetPasswordViewModel()
    
    weak var delegate: ResetPasswordControllerDelegate?
    
    var email: String?
    
    private let iconImage: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "Instagram_logo_white"))
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    
    private lazy var resetPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset Password", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hue: 279/360, saturation: 44/100, brightness: 95/100, alpha: 0.4)
        button.layer.cornerRadius = 5
        button.setHeight(50)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleResetPassword), for: .touchUpInside)
        return button
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.addTarget(self, action: #selector(handleDissmissal), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: - Actions
    @objc func textDidChange(sender: UITextField) {
        
        if sender == emailTextField {
            viewModel.email = sender.text
        }
        
        updateForm()
    }
    
    @objc func handleResetPassword() {
        guard let email = emailTextField.text else { return }
        
        showLoader(true)
        AuthService.resetPassword(withEmail: email) { error in
            if let error = error {
                self.showMessage(withTitle: "Error", message: error.localizedDescription)
                print("DEBUG: Failed to reset password with error \(error.localizedDescription)")
                self.showLoader(false)
                return
            }
            
            self.delegate?.controllerDidSendResetPassword(self)
            
        }
    }
    
    @objc func handleDissmissal() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Helpers
    
    func configureUI() {
        configureGrandientLayer()
        
//        if let email = email {
//            emailTextField.text
//        }
        emailTextField.text = email
        viewModel.email = email
        view.addSubview(backButton)
        backButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 16, paddingLeft: 16)
        
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        view.addSubview(iconImage)
        iconImage.centerX(inView: view)
        iconImage.setDimensions(height: 80, width: 120)
        iconImage.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        
        let stack = UIStackView(arrangedSubviews: [emailTextField, resetPasswordButton])
        stack.axis = .vertical
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.anchor(top: iconImage.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
    }
}

extension ReSetPasswordController: FormViewModel {
    func updateForm() {
        resetPasswordButton.backgroundColor = viewModel.buttonBackgroundColor
        resetPasswordButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
        resetPasswordButton.isEnabled = viewModel.formIsValid
    }
}


