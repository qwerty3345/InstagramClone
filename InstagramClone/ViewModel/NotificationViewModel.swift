//
//  NotificationViewModel.swift
//  InstagramClone
//
//  Created by Mason Kim on 2022/11/06.
//

import UIKit
import FirebaseFirestore

struct NotificationViewModel {
    var notification: Notification
    
    init(notification: Notification) {
        self.notification = notification
    }
    
    var postImageUrl: URL? { return URL(string: notification.postImageUrl ?? "") }
    
    var profileImageUrl: URL? { return URL(string: notification.userProfileImageUrl) }
    
    var notificationMessage: NSAttributedString {
        let username = notification.username
        let message = notification.type.notificationMessage
        
        let attributedText = NSMutableAttributedString(string: username, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSMutableAttributedString(string: message, attributes: [.font: UIFont.systemFont(ofSize: 14)]))
        
        // 몇 일/시간/분 전에 온 알람인지 값 구하기
        let timeString = getTimePassedString(notification.timestamp.dateValue(), and: Date())
        
        attributedText.append(NSMutableAttributedString(string: " \(timeString) 전", attributes: [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.lightGray]))
        
        return attributedText
        
    }
    
    var postImageIsHidden: Bool { return notification.type == .follow }
    var followButtonIsHidden: Bool { return notification.type != .follow }
    
    var followButtonText: String {
        return notification.userIsFollowed ? "팔로잉" : "팔로우"
    }
    
    var followButtonColor: UIColor {
        return notification.userIsFollowed ? .white : .systemBlue
    }
    
    var followButtonTextColor: UIColor {
        return notification.userIsFollowed ? .black : .white
    }
}
