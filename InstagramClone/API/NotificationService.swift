//
//  NotificationService.swift
//  InstagramClone
//
//  Created by Mason Kim on 2022/11/05.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

struct NotificationService {
    /// Notification DB 업로드 (Firestore)
    static func uploadNotification(fromUser: User, toUid uid: String, type: NotificationType, post: Post? = nil) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        // 내가 나한테 알림을 보내지 않게 (ex. 내 게시글을 내가 좋아요...)
        guard currentUid != uid else { return }
        
        // 업로드 하는 document의 id 값을 알아내서 해당 document의 data 에 추가하기 위해...
        let docRef = COLLECTION_NOTIFICATION.document(uid).collection("user-notifications").document()
        
        var data: [String: Any] = [
            "timestamp": Timestamp(date: Date()),
            "type": type.rawValue,
            "uid": fromUser.uid,
            "id": docRef.documentID,
            "userProfileImageUrl": fromUser.profileImageUrl,
            "username": fromUser.username
        ]
        
        // post 가 nil 이 아닐 때만 data 에 해당 정보 삽입
        if let post = post {
            data["postId"] = post.postId
            data["postImageUrl"] = post.imageUrl
        }
        
        docRef.setData(data)
    }
    
    /// Notifications DB에서 가져오기 (Firestore)
    static func fetchNotifications(completion: @escaping ([Notification]) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return}
        
        COLLECTION_NOTIFICATION.document(currentUid).collection("user-notifications").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            
            let notifications = documents
                .map { Notification(dictionary: $0.data()) }
                .sorted { $0.timestamp.dateValue() > $1.timestamp.dateValue() }
            
            completion(notifications)
        }
    }
}
 

