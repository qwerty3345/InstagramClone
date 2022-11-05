//
//  FeedCellViewModel.swift
//  InstagramClone
//
//  Created by Mason Kim on 2022/10/28.
//

import UIKit

struct PostViewModel {

    var post: Post

    var postImageUrl: URL? { return URL(string: post.imageUrl) }

    var caption: String { return post.caption }

    var likes: Int { return post.likes }
    
    var likesLabelText: String {
        if post.likes != 1 {
            return "\(post.likes) likes"
        } else {
            return "\(post.likes) like"
        }
    }
    
    var likeButtonTintColor: UIColor {
        return post.didLike ? .red : .black
    }
    
    var likeButtonImage: UIImage? {
        let imageName = post.didLike ? "like_selected" : "like_unselected"
        return UIImage(named: imageName)
    }
    
    var username: String { return post.ownerUsername }
    
    var profileImageUrl: URL? { return URL(string: post.ownerImageUrl) }
    
    var ownerUid: String { return post.ownerUid }

    init(post: Post) {
        self.post = post
    }


    //    let caption: String
    //    let timestamp: Timestamp
    //    let likes: Int
    //    let imageUrl: String
    //    let ownerUid: String
    //    let postId: String



}
