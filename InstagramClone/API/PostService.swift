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
        // TODO: 시간 순으로 정렬하기
        
        
        query.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            
            let posts = documents.map{ Post(postId: $0.documentID, dictionary: $0.data()) }
            print("### fetch posts: \(posts.count)")
            completion(posts)
        }
        
    }
}

