//
//  UserCellViewModel.swift
//  InstagramClone
//
//  Created by Mason Kim on 2022/10/27.
//

import Foundation

struct UserCellViewModel {
    private let user: User
    
    init(user: User) {
        self.user = user
    }
    
    var fullname: String {
        return user.fullname
    }
    
    var username: String {
        return user.username
    }
    
    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)
    }
    
    
}
