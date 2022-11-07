//
//  Notification.swift
//  InstagramClone
//
//  Created by Mason Kim on 2022/11/05.
//

import Foundation
import FirebaseFirestore

enum NotificationType: Int {
    case like
    case follow
    case comment
    
    var notificationMessage: String {
        switch self {
        case .like: return "님이 게시물을 좋아합니다."
        case .follow: return "님이 팔로우 했습니다."
        case .comment: return "님이 게시물에 댓글을 달았습니다."
        }
    }
}

struct Notification {
    let uid: String
    let postImageUrl: String?
    let postId: String?
    let timestamp: Timestamp
    let type: NotificationType
    let id: String
    let userProfileImageUrl: String
    let username: String
    var userIsFollowed = false
    
    init(dictionary: [String: Any]) {
        self.uid = dictionary["uid"] as? String ?? ""
        self.postImageUrl = dictionary["postImageUrl"] as? String ?? ""
        self.postId = dictionary["postId"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.type = NotificationType(rawValue: dictionary["type"] as? Int ?? 0) ?? .like
        self.id = dictionary["id"] as? String ?? ""
        self.userProfileImageUrl = dictionary["userProfileImageUrl"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
    }
}
