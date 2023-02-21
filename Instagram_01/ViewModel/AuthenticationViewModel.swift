//
//  AuthenticationViewModel.swift
//  Instagram_01
//
//  Created by Woojun Lee on 2023/01/20.
//

import UIKit

protocol FormViewModel {
    func updateForm() 
}

protocol AuthenticationViewModel {
    var formIsValid: Bool { get }
    var buttonBackgroundColor: UIColor { get }
    var buttonTitleColor: UIColor { get }
}

struct LoginViewModel: AuthenticationViewModel {
    var email: String?
    var password: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false && password?.isEmpty == false
    }
    
    var buttonBackgroundColor: UIColor {
        return formIsValid ? UIColor(red: 0.5216, green: 0, blue: 0.749, alpha: 1.0) : UIColor(hue: 279/360, saturation: 44/100, brightness: 95/100, alpha: 0.4)
    }
    
    var buttonTitleColor: UIColor {
        return formIsValid ? .white : UIColor(white: 1, alpha: 0.67)
    }
}

struct RegistrationViewModel: AuthenticationViewModel {
    
    
    var email: String?
    var password: String?
    var fullname: String?
    var username: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false && password?.isEmpty == false && fullname?.isEmpty == false && username?.isEmpty == false
    }
    
    var buttonBackgroundColor: UIColor {
        
        return formIsValid ? UIColor(red: 0.5216, green: 0, blue: 0.749, alpha: 1.0) : UIColor(hue: 279/360, saturation: 44/100, brightness: 95/100, alpha: 0.4)
    }
    
    var buttonTitleColor: UIColor {
        
        return formIsValid ? .white : UIColor(white: 1, alpha: 0.67)
    }
    
    
}

struct ResetPasswordViewModel: AuthenticationViewModel {
    
    var email: String?
    
    var formIsValid: Bool { return email?.isEmpty == false }
    
    var buttonBackgroundColor: UIColor {
        return formIsValid ? UIColor(red: 0.5216, green: 0, blue: 0.749, alpha: 1.0) : UIColor(hue: 279/360, saturation: 44/100, brightness: 95/100, alpha: 0.4)
    }
    
    var buttonTitleColor: UIColor {
        return formIsValid ? .white : UIColor(white: 1, alpha: 0.67)
    }
    
    
}


