//
//  UserViewModel.swift
//  ChatApp
//
//  Created by Berkay DEMİR on 9.02.2026.
//

import Foundation

struct UserViewModel {
    let user: User
    
    var fullname: String {return user.fullname}
    var username: String {return user.username}
    
    var profileImageView: URL? {
        return URL(string: user.profileImageURL)
    }
    
    init(user: User) {
        self.user = user
    }
}
