//
//  UserService.swift
//  InstagramClone
//
//  Created by Mason Kim on 2022/10/26.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

typealias FireStoreCompletion = (Error?) -> Void

struct UserService {
    // Firebase에서 현재 유저 불러오기
    static func fetchUser(completion: @escaping (User) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_USERS.document(uid).getDocument { snapshot, error in
            guard let dict = snapshot?.data() else { return }
            
            // 불러온 snapshot 데이터로 user 객체 생성
            let user = User(dictionary: dict)
            
            // 콜백 함수 실행
            completion(user)
        }
    }
    
    // Firebase에서 uid를 바탕으로 유저 불러오기
    static func fetchUser(uid: String, completion: @escaping (User) -> Void) {
        COLLECTION_USERS.document(uid).getDocument { snapshot, error in
            guard let dict = snapshot?.data() else { return }
            
            // 불러온 snapshot 데이터로 user 객체 생성
            let user = User(dictionary: dict)
            
            // 콜백 함수 실행
            completion(user)
        }
    }
    
    // Firebase에서 다른 유저들 정보를 배열로 가져오기 (SearchController에서 호출)
    static func fetchUsers(completion: @escaping([User]) -> Void) {
        COLLECTION_USERS.getDocuments { snapshot, error in
            guard let snapshot = snapshot else { return }
            
            // snapshot.documents.data() 는 user 하나를 생성할 수 있는 dictionary 데이터임.
            let users = snapshot.documents.map { User(dictionary: $0.data()) }
            
            completion(users)
        }
    }
    
    static func follow(uid: String, completion: @escaping(FireStoreCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).setData([:]) { error in
            COLLECTION_FOLLOWERS.document(uid).collection("user-follower").document(currentUid).setData([:], completion: completion)
        }
        
    }
    
    static func unfollow(uid: String, completion: @escaping(FireStoreCompletion)) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).delete() { error in
            COLLECTION_FOLLOWERS.document(uid).collection("user-follower").document(currentUid).delete(completion: completion)
        }
    }
    
    static func checkIfUserIsFollowed(uid: String, completion: @escaping(Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        COLLECTION_FOLLOWING.document(currentUid).collection("user-following").document(uid).getDocument { snapshot, error in
            guard let isFollowed = snapshot?.exists else { return }
            completion(isFollowed)
        }
    }
    
    static func fetchUserStats(uid: String, completion: @escaping(UserStats) -> Void) {
        COLLECTION_FOLLOWING.document(uid).collection("user-following").getDocuments { snapshot, error in
            let following = snapshot?.documents.count ?? 0
            COLLECTION_FOLLOWERS.document(uid).collection("user-follower").getDocuments { snapshot, error in
                let followes = snapshot?.documents.count ?? 0
                
                COLLECTION_POSTS.whereField("ownerUid", isEqualTo: uid).getDocuments { snapshot, error in
                    
                    let posts = snapshot?.documents.count ?? 0
                    let userStats = UserStats(followers: followes, following: following, posts: posts)
                    completion(userStats)
                }
                
            }
        }
    }
    
}
