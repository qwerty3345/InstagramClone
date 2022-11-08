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
        attributedText.append(NSMutableAttributedString(string: " 2분전", attributes: [.font: UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.lightGray]))
        
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
    
    /// 알림이 몇일전/몇시간전에 온 알람인지 계산.
    func getNotificationTime() {
        // TODO: 알림이 온지 시간이 얼마나 지났는지를 알려주는 로직 구현 (timestamp 에서 지금 Date 가 얼마나 차이나는지를 계산)
        print(notification.timestamp.dateValue())
        
    }
}
