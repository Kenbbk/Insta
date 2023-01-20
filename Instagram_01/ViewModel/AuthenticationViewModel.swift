//
//  AuthenticationViewModel.swift
//  Instagram_01
//
//  Created by Woojun Lee on 2023/01/20.
//

import Foundation

struct LoginViewModel {
    var email: String?
    var password: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false && password?.isEmpty == false
    }
}

struct RegistrationViewModel {
    
}
