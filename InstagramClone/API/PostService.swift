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


    // [case closed] 고민 동작 로직에 대해, completion이 forEach 내부에서 매번 실행되는데, 어떻게 하면 모든 fetchPost 를 마치고 한 번만 실행할 수 있을까?
    // DispatchQueue 내부에서 배열에 담으니 컴플리션이 먼저 동작하는 현상이 발생하는데, 어떻게 해결할 수 있을까?
    // ⭐️ 여러개의 비동기 작업을 요청하고, 모든 작업이 완료되면 컴플리션 핸들러를 실행 : "DispatchGroup 활용"
    // 그런데, DispatchGroup에 비동기 작업을 보냈기 때문에 채 실행이 다 되기 전에 completion이 실행됨. 즉, fetchPost 작업 요청이 다 끝난 후에 notify 가 되어 completion이 실행되긴 하지만 실제 posts 객체에 담기기 전에 실행되는 문제 발생
    // ⭐️⭐️ 비동기 함수 여러개를 DispatchGroup으로 보내고 완료 시점을 알고 싶을 때: DispatchGroup의 enter, leave 활용!

    /// 로그인 한 유저의 메인 피드 게시물 정보를 가져옴.
    // TODO: 지금으로부터 6시간 전 데이터만 가져오는 로직을 구현해야 할 듯 함.
    // TODO: user-feed 를 날짜별로 컬렉션 분리하는 방안? 앱이 상용화 돼서 firebase로 작동하기 위해 전체를 받아온다면 너무 동작이 방대해질 듯.
    static func fetchFeedPosts(completion: @escaping ([Post]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        var posts = [Post]()

        COLLECTION_USERS.document(uid).collection("user-feed").getDocuments { snapshot, _ in
            // DispatchGroup 객체 생성
            let fetchPostDispatchGroup = DispatchGroup()

            snapshot?.documents.forEach { document in
                // 작업을 시작할 때, DispatchGroup의 task reference count를 +1 해줌.
                fetchPostDispatchGroup.enter()

                fetchPost(withPostId: document.documentID) { post in
                    posts.append(post)
                    // 작업을 완료한 후, DispatchGroup의 task reference count를 -1 해줌.
                    fetchPostDispatchGroup.leave()
                }
            }

            // DispatchGroup의 task reference가 0이 된 시점에 실행함.
            fetchPostDispatchGroup.notify(queue: .main) {
                // post의 시간 순으로 posts 배열을 정렬 -> TODO: 고민. 이걸 프론트에서 정렬해서 뿌리는게 과연 좋은 로직일까? 아니면, 파이어베이스에 user-feed에 postId를 저장할 때, post의 timestamp 또한 함께 저장해서 sort를 한 채로 받아오는게 맞을까?
                posts.sort { first, second in
                    return first.timestamp.dateValue() > second.timestamp.dateValue()
                }
                completion(posts)
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
        COLLECTION_FOLLOWERS.document(uid).collection("user-follower").getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            
            // 각각의 팔로워들의 user-feed DB에 게시물id 추가.
            documents.forEach { document in
                COLLECTION_USERS.document(document.documentID).collection("user-feed").document(postId).setData([:])
            }

            // 내 피드 정보에도 추가
            COLLECTION_USERS.document(uid).collection("user-feed").document(postId).setData([:])
        }
    }


}

