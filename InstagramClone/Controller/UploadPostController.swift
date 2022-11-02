//
//  UploadPostController.swift
//  InstagramClone
//
//  Created by Mason Kim on 2022/10/28.
//

import UIKit

protocol UploadPostControllerDelegate: AnyObject {
    func controllerDidFinishUploadingPost(_ controller: UploadPostController)
}

class UploadPostController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: UploadPostControllerDelegate?
    
    var currentUser: User?
    
    var selectedImage: UIImage? {
        didSet { photoImageView.image = selectedImage }
    }
    
    private let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    private lazy var captionTextView: InputTextView = {
        let tv = InputTextView()
        tv.placeholderText = "문구 입력..."
        tv.font = .systemFont(ofSize: 16)
        // ⭐️ lazy var 로 해줘야 해당 스코프 안에서 delegate 선언할 수 있음! (VC 가 먼저 생겨야 하므로..)
        tv.delegate = self
        tv.placeHolderShouldCenter = false
        return tv
    }()
    
    private let characterCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 14)
        label.text = "0/100"
        return label
    }()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Actions
    
    @objc func didTapCancel() {
        dismiss(animated: true)
    }
    
    @objc func didTapDone() {
        print("#### 업로드 공유 버튼 누름")
        
        guard let image = selectedImage else { return }
        guard let caption = captionTextView.text else { return }
        guard let user = currentUser else { return }
        
        showLoader(true)
        
        PostService.uploadPost(caption: caption, image: image, user: user) { error in
            self.showLoader(false)
            
            if let error = error {
                print("##### 이미지 업로드 에러: \(error.localizedDescription)")
                return
            }
            
            // ⭐️⭐️⭐️ 이와 같은 방식으로는 작동이 안됨. 이 vc는 tabBarController가 아니기 때문에. 그래서 delegate 패턴으로 구현해야 함.
//            self.tabBarController?.selectedIndex = 0
//            self.dismiss(animated: true)
            
            // ⭐️⭐️⭐️ so, delegate 패턴으로 구현!
            self.delegate?.controllerDidFinishUploadingPost(self)
            
        }
    }
    
    // MARK: - Helpers
    
    // text 길이가 maxLength를 넘어가지 않게 지우기
    func checkMaxLength(_ textView: UITextView, maxLength: Int) {
        if textView.text.count > maxLength {
            textView.deleteBackward()
        }
    }
    
    func configureUI() {
        view.backgroundColor = .white
        
        navigationItem.title = "새 게시물"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self,
                                                           action: #selector(didTapCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "공유", style: .done, target: self, action: #selector(didTapDone))
        
        view.addSubview(photoImageView)
        photoImageView.setDimensions(height: 180, width: 180)
        photoImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 8)
        photoImageView.centerX(inView: view)
        photoImageView.layer.cornerRadius = 5
        
        view.addSubview(captionTextView)
        captionTextView.anchor(top: photoImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor,
                               paddingTop: 16, paddingLeft: 12, paddingRight: 12, height: 64)
        
        view.addSubview(characterCountLabel)
        characterCountLabel.anchor(bottom: captionTextView.bottomAnchor, right: view.rightAnchor,
                                   paddingBottom: -8, paddingRight: 12)
    }
    
}

// MARK: - UITextFieldDelegate

extension UploadPostController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
        checkMaxLength(textView, maxLength: 100)
        let count = textView.text.count
        characterCountLabel.text = "\(count)/100"
    }
}
