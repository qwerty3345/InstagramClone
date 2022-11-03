//
//  CommentService.swift
//  InstagramClone
//
//  Created by Mason Kim on 2022/11/03.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct CommentService {

    /// FireStore 댓글 달기
    static func uploadComment(comment: String, postID: String, user: User,
        completion: @escaping FireStoreCompletion) {
        let data: [String: Any] = [
            "uid": user.uid,
            "comment": comment,
            "timestamp": Timestamp(date: Date()),
            "username": user.username,
            "profileImageUrl": user.profileImageUrl
        ]

        COLLECTION_POSTS.document(postID).collection("comments").addDocument(data: data, completion: completion)
    }

    /// FireStore 댓글 가져오기
    static func fetchComments(forPost postID: String, completion: @escaping([Comment]) -> Void) {
        
        var comments = [Comment]()
        let query = COLLECTION_POSTS.document(postID).collection("comments")
            .order(by: "timestamp", descending: true)
        
        // ⭐️⭐️ Firestore에서 해당 query의 데이터가 변경 될 때 마다 호출되는 snapshotListener 추가
        query.addSnapshotListener { snapshot, error in
            print(snapshot?.documents.count)
            snapshot?.documentChanges.forEach({ change in
                if change.type == .added {
                    let data = change.document.data()
                    let comment = Comment(dictionary: data)
                    comments.append(comment)
                }
            })
            
            print(comments.count)
            
            completion(comments)
        }
    }

}
