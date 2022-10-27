//
//  FeedController.swift
//  InstagramClone
//
//  Created by Mason Kim on 2022/10/21.
//

import UIKit
import FirebaseAuth

private let reuseIndentifier = "Cell"

final class FeedController: UICollectionViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    
    // MARK: - Actions
    
    /// 로그아웃 버튼
    @objc func handleLogout() {
        do {
            try Auth.auth().signOut()
            let vc = LoginController()
            // ⭐️ delegate 지정 시 Delegate를 구현해놓은 MainTabController로 형변환 후 지정 해 줌.
            vc.delegate = self.tabBarController as? MainTabController
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        } catch {
            print("##### Firebase Auth 로그아웃 실패: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: - Helpers
    
    func configureUI() {
        collectionView.backgroundColor = .white
        
        // Cell에 대한 클래스와 셀의 재사용을 위한 id값을 등록해줘야 함.
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: reuseIndentifier)
        
        // 우측 상단 네비게이션 바 아이템 버튼 추가
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "로그아웃", style: .plain, target: self,
                                                            action: #selector(handleLogout))
    }
}


// MARK: - UICollectionViewDataSource

extension FeedController {
    // "numberOfItemsInSection": CollectionView에 생성 할 Cell의 수
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    // "cellForItemAt": CollectionView에 각 셀을 만드는 규칙
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // FeedCell로 typeCasting 해줌으로서 활용
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIndentifier, for: indexPath) as! FeedCell
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FeedController: UICollectionViewDelegateFlowLayout {
    // "sizeForItemAt": 각 셀의 크기를 정의하기 위함.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        var height = width + 8 + 40 + 8     // (이미지뷰 가로와 동일한 세로 + 패딩 + 프로필 이미지뷰 높이 + 패딩)
        height += 50                        // 버튼 3개 담은 스택뷰 높이
        height += 60                        // 좋아요수, 댓글 높이
        return CGSize(width: width, height: height) // 가로는 뷰 꽉차고, 세로는 200으로.
    }
}
