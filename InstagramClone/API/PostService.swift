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
        print("### fetch post1")
        
        COLLECTION_POSTS.order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            print("### fetch post2")
            guard let documents = snapshot?.documents else { return }
            
            
            
            let posts = documents.map{ Post(postId: $0.documentID, dictionary: $0.data()) }
            print("### fetch post3")
            completion(posts)
        }
    }
}
