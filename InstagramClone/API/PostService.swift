//
//  PostService.swift
//  InstagramClone
//
//  Created by Mason Kim on 2022/10/28.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

struct PostService {
    
    static func uploadPost(caption: String, image: UIImage, user: User,
                           completion: @escaping FireStoreCompletion) {
        ImageUploader.uploadImage(image: image) { imageUrl in
            let data = ["caption": caption,
                        "timestamp": Timestamp(date: Date()),
                        "likes": 0,
                        "imageUrl": imageUrl,
                        "ownerUid": user.uid,
                        "ownerUsername": user.username,
                        "ownerImageUrl": user.profileImageUrl]
            
            COLLECTION_POSTS.addDocument(data: data, completion: completion)
        }
    }
    
    static func fetchPosts(completion: @escaping ([Post]) -> Void) {
        
        COLLECTION_POSTS.order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            
            let posts = documents.map{ Post(postId: $0.documentID, dictionary: $0.data()) }
            
            completion(posts)
        }
    }
    
    static func fetchPosts(forUser uid: String, completion: @escaping ([Post]) -> Void) {
        let query = COLLECTION_POSTS
            .whereField("ownerUid", isEqualTo: uid)
            .order(by: "timestamp", descending: true)
            // where 필드와 order 필드를 함께 사용하기 위해, FirebaseFireStore에서 색인을 추가 해 줬음. (안해줬을 때 DEBUG에 뜨는 LOG의 링크 따라가면 설정 가능)
        
        
        query.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            
            let posts = documents.map{ Post(postId: $0.documentID, dictionary: $0.data()) }
            print("### fetch posts: \(posts.count)")
            completion(posts)
        }
    }
    
    /// 좋아요 FireStore DB 업로드  (post 컬렉션에 좋아요한 유저 정보 저장, user 컬렉션에 좋아요한 post 정보 저장)
    static func likePost(forPost post: Post, completion: @escaping FireStoreCompletion) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // post의 좋아요 +1
        COLLECTION_POSTS.document(post.postId).updateData(["likes": post.likes + 1])
        
        // post 컬렉션에 좋아요한 유저의 uid 정보 저장
        COLLECTION_POSTS.document(post.postId).collection("post-likes").document(uid).setData([:]) { _ in
            // user 컬렉션에 좋아요한 post 정보 저장
            COLLECTION_USERS.document(uid).collection("user-likes").document(post.postId).setData([:], completion: completion)
        }
    }
    
    /// 좋아요 취소
    static func unLikePost(forPost post: Post, completion: @escaping FireStoreCompletion) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard post.likes > 0 else { return }
        
        // post의 좋아요 -1
        COLLECTION_POSTS.document(post.postId).updateData(["likes": post.likes - 1])
        
        // post 컬렉션에 좋아요한 유저의 uid 정보 삭제
        COLLECTION_POSTS.document(post.postId).collection("post-likes").document(uid).delete { _ in
            // user 컬렉션에 좋아요한 post 정보 삭제
            COLLECTION_USERS.document(uid).collection("user-likes").document(post.postId).delete(completion: completion)
        }
    }
    
    // 게시물이 좋아요 상태인지 확인
    static func checkIfUserLikedPost(post: Post, completion: @escaping(Bool) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        COLLECTION_USERS.document(uid).collection("user-likes").document(post.postId).getDocument { snapshot, error in
            guard let didLike = snapshot?.exists else { return }
            completion(didLike)
        }
        
        // 이렇게 해도 동일 (user, post 컬렉션 두 곳에 다 구현했기 때문에)
//        COLLECTION_POSTS.document(post.postId).collection("post-likes").document(uid).getDocument { snapshot, error in
//            guard let didLike = snapshot?.exists else { return }
//            completion(didLike)
//        }
        
    }
}

