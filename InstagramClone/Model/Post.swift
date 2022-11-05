//
//  Post.swift
//  InstagramClone
//
//  Created by Mason Kim on 2022/10/28.
//

import Foundation
import FirebaseFirestore

struct Post {
    let caption: String
    let timestamp: Timestamp
    var likes: Int
    let imageUrl: String
    let postId: String
    let ownerUid: String
    let ownerUsername: String
    let ownerImageUrl: String
    var didLike = false
    
    /// 딕셔너리 형태의 데이터를 통해 User 객체를 생성하는 생성자 정의
    init(postId: String, dictionary: [String: Any]) {
        self.caption = dictionary["caption"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.likes = dictionary["likes"] as? Int ?? 0
        self.imageUrl = dictionary["imageUrl"] as? String ?? ""
        self.ownerUid = dictionary["ownerUid"] as? String ?? ""
        self.ownerImageUrl = dictionary["ownerImageUrl"] as? String ?? ""
        self.ownerUsername = dictionary["ownerUsername"] as? String ?? ""
        self.postId = postId
    }
}
