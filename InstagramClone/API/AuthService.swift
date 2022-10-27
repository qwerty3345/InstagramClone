//
//  AuthService.swift
//  InstagramClone
//
//  Created by Mason Kim on 2022/10/23.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

/// 사용자 인증 시 데이터를 담은 모델 역할을 하는 구조체
struct AuthCredentials {
    let email: String
    let password: String
    let fullname: String
    let username: String
    let profileImage: UIImage
}

struct AuthService {
    /// 유저 로그인
    static func loginUser(withEmail email: String, password: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("#### Firebase 로그인 에러: \(error.localizedDescription)")
                return
            }
            completion(nil)
        }
    }
    
    /// 유저 회원가입
    static func registerUser(withCredential credentials: AuthCredentials,
                             completion: @escaping (Error?) -> Void) {
        // 프로필 이미지를 먼저 업로드 하고,
        ImageUploader.uploadImage(image: credentials.profileImage) { imageUrl in
            // user 생성
            Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { result, error in
                if let error = error {
                    print("##### Firebase Auth 에러: \(error.localizedDescription)")
                    return
                }
                
                // 사용자 고유 아이디. unique ID
                guard let uid = result?.user.uid else { return }
                
                // Firestore DB에 업로드 하기 위한 데이터 (딕셔너리 형태)
                let data: [String: Any] = ["email": credentials.email,
                                           "fullname": credentials.fullname,
                                           "profileImageUrl": imageUrl,
                                           "uid": uid,
                                           "username": credentials.username]
                
                // Firestore에 사용자 정보 DB 저장 ("users_컬렉션 / uid_다큐멘트 / 데이터" 형태)
                COLLECTION_USERS.document(uid).setData(data, completion: completion)
            }
        }
    }
}
