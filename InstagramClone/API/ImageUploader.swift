//
//  imageUploader.swift
//  InstagramClone
//
//  Created by Mason Kim on 2022/10/23.
//

import UIKit
import FirebaseStorage

struct ImageUploader {
    static func uploadImage(image: UIImage, completion: @escaping (String) -> Void) {
        // UIImage jpeg으로 압축
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        let fileName = NSUUID().uuidString
        let ref = Storage.storage().reference(withPath: "/profile_images/\(fileName)")
        
        ref.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("##### FireStore 이미지 업로드 에러 발생: \(error.localizedDescription)")
                return
            }
            
            // 다운로드 가능한 url 주소를 다시 반환 해 completion을 실행 (업로드 한 이미지를 다시 다운받아 이미지뷰에 표시하기 위해)
            ref.downloadURL { url, error in
                guard let imageUrl = url?.absoluteString else { return }
                completion(imageUrl)
            }
        }
    }
}
