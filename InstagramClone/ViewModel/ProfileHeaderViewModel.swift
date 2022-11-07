//
//  ProfileHeaderViewModel.swift
//  InstagramClone
//
//  Created by Mason Kim on 2022/10/26.
//

import UIKit

struct ProfileHeaderViewModel {
    let user: User
    
    var fullname: String {
        return user.fullname
    }
    
    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)
    }
    
    var followButtonText: String {
        if user.isCurrentUser { return "프로필 수정" }
        return user.isFollwed ? "팔로잉" : "팔로우"
    }
    
    var followButtonBackgroundColor: UIColor {
        if user.isCurrentUser { return .white }
        return user.isFollwed ? .white : .systemBlue
    }
    
    var followButtonTextColor: UIColor {
        if user.isCurrentUser { return .black }
        return user.isFollwed ? .black : .white
    }
    
    var numberOfFollowing: NSAttributedString {
        return attributedStateText(value: user.stats.following, label: "팔로잉")
    }
    
    var numberOfFollowers: NSAttributedString {
        return attributedStateText(value: user.stats.followers, label: "팔로워")
    }
    
    var numberOfPosts: NSAttributedString {
        return attributedStateText(value: user.stats.posts, label: "포스트")
    }
    
    init(user: User) {
        self.user = user
    }
    
    // 수와, 해당 수에 대한 텍스트 두 줄로 들어가는 attributed 스트링 반환
    func attributedStateText(value: Int, label: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: "\(value)\n", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedString.append(NSAttributedString(string: label, attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        return attributedString
    }
}
