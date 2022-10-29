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
    
    private var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        fetchPosts()
    }
    
    
    // MARK: - Actions
    
    /// 리프레시 컨트롤에 대한 새로고침 액션
    @objc func handleRefresh() {
        print("###1 posts: \(posts.count)")
        posts.removeAll()
        print("###2 posts: \(posts.count)")
        fetchPosts()
    }
    
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
    
    
    // MARK: - API
    
    func fetchPosts() {
        print("###2.5 posts: \(posts.count)")
        PostService.fetchPosts { posts in
            print("###3 posts: \(posts.count)")
            self.posts = posts
            self.collectionView.refreshControl?.endRefreshing()
            
            self.collectionView.reloadData()
            
            
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
        
        navigationItem.title = "피드"
        
        // 리프레셔 (스크롤 아래로 당기면 새로고침) 추가
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refresher
    }
}


// MARK: - UICollectionViewDataSource

extension FeedController {
    // "numberOfItemsInSection": CollectionView에 생성 할 Cell의 수
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("### numberOfItemsInSection: \(posts.count)")
        return posts.count
    }
    
    // "cellForItemAt": CollectionView에 각 셀을 만드는 규칙
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIndentifier, for: indexPath) as! FeedCell
        
        // indexOutOfRange 에러 때문에 추가함. TODO: 정확한 이유에 대해서 더 알아보기.
        if posts.count > indexPath.row {
            cell.viewModel = PostViewModel(post: posts[indexPath.row])
        }
        
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
