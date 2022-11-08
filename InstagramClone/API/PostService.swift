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

    static func uploadPost(caption: String, image: UIImage, user: User, completion: @escaping FireStoreCompletion) {
        ImageUploader.uploadImage(image: image) { imageUrl in
            let data = ["caption": caption,
                "timestamp": Timestamp(date: Date()),
                "likes": 0,
                "imageUrl": imageUrl,
                "ownerUid": user.uid,
                "ownerUsername": user.username,
                "ownerImageUrl": user.profileImageUrl]

            // 그냥 실행해도 되지만, return 값의 DocumentReference 값을 이용해 postId 값을 쓰기 위해 docRef 에 넣어줬음.
            let docRef = COLLECTION_POSTS.addDocument(data: data, completion: completion)
//            COLLECTION_POSTS.addDocument(data: data, completion: completion)
            
            // 피드 정보 업데이트
            self.updateUserFeedAfterPost(postId: docRef.documentID)
        }
    }

    static func fetchPosts(completion: @escaping ([Post]) -> Void) {

        COLLECTION_POSTS.order(by: "timestamp", descending: true).getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }

            let posts = documents.map { Post(postId: $0.documentID, dictionary: $0.data()) }

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

            let posts = documents.map { Post(postId: $0.documentID, dictionary: $0.data()) }
            print("### fetch posts: \(posts.count)")
            completion(posts)
        }
    }

    /// 게시물 id 값을 바탕으로 게시물 가져오기
    static func fetchPost(withPostId postId: String, completion: @escaping (Post) -> Void) {
        COLLECTION_POSTS.document(postId).getDocument { snapshot, _ in
            guard let dict = snapshot?.data() else { return }
            let post = Post(postId: postId, dictionary: dict)
            completion(post)
        }
    }

    /// 로그인 한 유저의 메인 피드 게시물 정보를 가져옴.
    static func fetchFeedPosts(completion: @escaping ([Post]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        var posts = [Post]()

        COLLECTION_USERS.document(uid).collection("user-feed").getDocuments { snapshot, _ in
            snapshot?.documents.forEach {
                fetchPost(withPostId: $0.documentID) { post in
                    // TODO: 동작 로직에 대해, completion이 forEach 내부에서 매번 실행되는데, 어떻게 하면 모든 fetchPost 를 마치고 한 번만 실행할 수 있을까?
                    // TODO: DispatchQueue 내부에서 배열에 담으니 컴플리션이 먼저 동작하는 현상이 발생하는데, 어떻게 해결할 수 있을까?
//                    DispatchQueue(label: "serial").async {
                    posts.append(post)

//                    }
                    print("completion")
                    completion(posts)
                }
            }
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

        // 이렇게 해도 동일하게 동작 (user, post 컬렉션 두 곳에 다 구현했기 때문에)
//        COLLECTION_POSTS.document(post.postId).collection("post-likes").document(uid).getDocument { snapshot, error in
//            guard let didLike = snapshot?.exists else { return }
//            completion(didLike)
//        }
    }

    /// 유저 팔로우, 언팔로우 이후, 피드의 게시물 정보를 DB에 업데이트 (팔로우 한 유저의 게시물들을 메인 피드로 가져오기 위해)
    static func updateUserFeedAfterFollowing(user: User, didFollow: Bool) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let query = COLLECTION_POSTS.whereField("ownerUid", isEqualTo: user.uid)

        query.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }

            let docIDs = documents.map { $0.documentID }
            print("document IDs: \(docIDs)")

            docIDs.forEach { id in
                if didFollow {
                    // 팔로우 시, user-feed DB에 게시물 id 추가
                    COLLECTION_USERS.document(currentUid).collection("user-feed").document(id).setData([:])
                } else {
                    // 언팔로우 시, user-feed DB에 게시물 id 삭제
                    COLLECTION_USERS.document(currentUid).collection("user-feed").document(id).delete()
                }
            }
        }
    }

    /// 유저가 게시글을 포스팅 한 이후 게시물 정보를 팔로워들의 피드에 뜨도록 DB 업데이트
    static func updateUserFeedAfterPost(postId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        // 현재 접속한 사용자(게시물을 올리는 사람)의 팔로워 목록을 가져옴 _ 이 사람들의 유저 피드에 게시물id 를 추가 해 줄 것.
        COLLECTION_FOLLOWERS.document(uid).collection("user-followers").getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }

            let followers = documents.map { User(dictionary: $0.data()) }

            // 각각의 팔로워들의 user-feed DB에 게시물id 추가.
            followers.forEach { follower in
                COLLECTION_USERS.document(follower.uid).collection("user-feed").document(postId).setData([:])
            }
            
            // 내 피드 정보에도 추가
            COLLECTION_USERS.document(uid).collection("user-feed").document(postId).setData([:])
        }
    }


}

