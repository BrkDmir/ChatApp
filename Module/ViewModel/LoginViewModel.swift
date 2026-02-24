//
//  LoginViewModel.swift
//  ChatApp
//
//  Created by Berkay DEMİR on 5.01.2026.
//

import Foundation
import UIKit

protocol AuthLoginModel {
    
    var formIsValid: Bool {get}
    var backgroundColor: UIColor {get}
    var buttonTitleColor: UIColor {get}
    
}

// MARK: - LoginViewModel

struct LoginViewModel: AuthLoginModel {
    
    var email: String?
    var password: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false && password?.isEmpty == false
    }
    
    var backgroundColor: UIColor {
        return formIsValid ? (UIColor.black) : (UIColor.black.withAlphaComponent(0.5))
    }
    
    var buttonTitleColor: UIColor {
        return formIsValid ? (UIColor.white): (UIColor(white: 1, alpha: 0.7))
    }
}

// MARK: - RegisterViewModel

struct RegisterViewModel: AuthLoginModel {
    
    var email: String?
    var password: String?
    var fullname: String?
    var username: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false && password?.isEmpty == false && fullname?.isEmpty == false && username?.isEmpty == false
    }
    
    var backgroundColor: UIColor {
        return formIsValid ? (UIColor.black) : (UIColor.black.withAlphaComponent(0.5))
    }
    
    var buttonTitleColor: UIColor {
        return formIsValid ? (UIColor.white) : (UIColor(white: 1, alpha: 0.7))
    }
}
