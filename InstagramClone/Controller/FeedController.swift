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

    var posts = [Post]() {
        didSet { collectionView.reloadData() }
    }

    // 프로필에서 게시물 클릭해서 들어갔을 때, 하나의 포스트만 보여주기 위한 필드
    var post: Post? {
        didSet { collectionView.reloadData() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        fetchPosts()
    }


    // MARK: - Actions

    /// 리프레시 컨트롤에 대한 새로고침 액션
    @objc func handleRefresh() {
        posts.removeAll()
        fetchPosts()
        // TODO: fetchPosts 로직 뜯어보기.
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
        // post 가 nil일 때만 받아옴. (프로필에서 넘어온 경우가 아닌, 피드에서 보일때만 fetch)
        guard post == nil else {
            self.checkIfUserLikedPosts()
            return
        }
        
        PostService.fetchFeedPosts { posts in
            self.posts = posts
            self.collectionView.refreshControl?.endRefreshing()

            self.checkIfUserLikedPosts()
        }

//        PostService.fetchPosts { posts in
//            self.posts = posts
//            self.collectionView.refreshControl?.endRefreshing()
//
//            self.checkIfUserLikedPosts()
//        }
    }

    func checkIfUserLikedPosts() {
        if let post = post {
            PostService.checkIfUserLikedPost(post: post) { didLike in
                self.post?.didLike = didLike
            }
        }
        
        self.posts.forEach { post in
            PostService.checkIfUserLikedPost(post: post) { didLike in
                if let index = self.posts.firstIndex(where: { $0.postId == post.postId }) {
                    self.posts[index].didLike = didLike
                }
            }
        }
    }


    // MARK: - Helpers

    func configureUI() {
        collectionView.backgroundColor = .white

        // Cell에 대한 클래스와 셀의 재사용을 위한 id값을 등록해줘야 함.
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: reuseIndentifier)

        if post == nil {
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
}


// MARK: - UICollectionViewDataSource

extension FeedController {
    // "numberOfItemsInSection": CollectionView에 생성 할 Cell의 수
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(post == nil ? posts.count : 1)
        return post == nil ? posts.count : 1
    }

    // "cellForItemAt": CollectionView에 각 셀을 만드는 규칙
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIndentifier, for: indexPath) as! FeedCell

        if let post = post {
            // post 가 존재할 때 (프로필에서 넘어와서 1개만 표시할 경우에)
            cell.viewModel = PostViewModel(post: post)
            cell.delegate = self
        } else {
            // 여러 post들이 존재할 때 (피드)
            cell.delegate = self
//            print("if문 밖:", indexPath.row)
            // indexOutOfRange 에러 때문에 추가함. TODO: 정확한 이유에 대해서 더 알아보기.
            if posts.count > indexPath.row {
//                print("if문:", indexPath.row)
                cell.viewModel = PostViewModel(post: posts[indexPath.row])
            }
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FeedController: UICollectionViewDelegateFlowLayout {
    // "sizeForItemAt": 각 셀의 크기를 정의하기 위함.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        var height = width + 8 + 40 + 8 // (이미지뷰 가로와 동일한 세로 + 패딩 + 프로필 이미지뷰 높이 + 패딩)
        height += 50 // 버튼 3개 담은 스택뷰 높이
        height += 60 // 좋아요수, 댓글 높이
        return CGSize(width: width, height: height) // 가로는 뷰 꽉차고, 세로는 200으로.
    }
}

// MARK: - FeedCellDelegate
extension FeedController: FeedCellDelegate {

    // 댓글 보기
    func cell(_ cell: FeedCell, wantsToShowCommentsFor post: Post) {
        let vc = CommentController(post: post)
        navigationController?.pushViewController(vc, animated: true)
    }

    // 게시물 좋아요, 좋아요 취소
    func cell(_ cell: FeedCell, didLike post: Post) {

        guard let tabVC = self.tabBarController as? MainTabController else { return } // downCastring
        guard let user = tabVC.user else { return }
        
        if post.didLike {
            // 좋아요 취소
            PostService.unLikePost(forPost: post) { error in
                cell.likeButton.setImage(UIImage(named: "like_unselected"), for: .normal)
                cell.likeButton.tintColor = .black
                cell.viewModel?.post.likes -= 1
            }
        } else {
            // 좋아요
            PostService.likePost(forPost: post) { error in
                // 좋아요 버튼
                cell.likeButton.setImage(UIImage(named: "like_selected"), for: .normal)
                cell.likeButton.tintColor = .red
                cell.viewModel?.post.likes += 1

                // 좋아요 했다고 알림 전송
                NotificationService.uploadNotification(fromUser: user, toUid: post.ownerUid, type: .like, post: post)
            }
        }

        // ⭐️⭐️⭐️ 파라미터로 받아온 post를 수정 해 봤자 의미가 없음.
        // 어차피 실제로 post 객체를 가지고 있고, 수정하는 역할은 viewModel에서 하기 때문에 cell 내부의 뷰모델의 post에 접근해서 역할을 수행함.
        cell.viewModel?.post.didLike.toggle()
    }

    // 유저 프로필 보기
    func cell(_ cell: FeedCell, wantToShowProfileFor uid: String) {
        UserService.fetchUser(withUid: uid) { user in
            let vc = ProfileController(user: user)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
