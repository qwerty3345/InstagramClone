//
//  Constants.swift
//  InstagramClone
//
//  Created by Mason Kim on 2022/10/26.
//

import FirebaseCore
import FirebaseFirestore


let COLLECTION_USERS = Firestore.firestore().collection("users")
let COLLECTION_FOLLOWERS = Firestore.firestore().collection("followers")
let COLLECTION_FOLLOWING = Firestore.firestore().collection("following")
let COLLECTION_POSTS = Firestore.firestore().collection("posts")
let COLLECTION_NOTIFICATION = Firestore.firestore().collection("notifications")

