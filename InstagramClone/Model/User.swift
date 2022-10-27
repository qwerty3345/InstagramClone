//
//  User.swift
//  InstagramClone
//
//  Created by Mason Kim on 2022/10/26.
//

import Foundation
import FirebaseAuth

struct User {
    let email: String
    let fullname: String
    let profileImageUrl: String
    let username: String
    let uid: String
    
    var isFollwed: Bool = false
    
    var stats: UserStats!
    
    // 해당 user 객체가 로그인한 유저 정보인지 판별
    var isCurrentUser: Bool { return Auth.auth().currentUser?.uid == uid }
    
    /// 딕셔너리 형태의 데이터를 통해 User 객체를 생성하는 생성자 정의
    init(dictionary: [String: Any]) {
        self.email = dictionary["email"] as? String ?? ""
        self.fullname = dictionary["fullname"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        
        self.stats = UserStats(followers: 0, following: 0)
    }
}

struct UserStats {
    var followers: Int
    var following: Int
//    let posts: Int
}
