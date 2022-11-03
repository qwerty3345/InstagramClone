//
//  CommentController.swift
//  InstagramClone
//
//  Created by Mason Kim on 2022/10/30.
//

import UIKit

private let reuseIdentifier = "CommentCell"

class CommentController: UICollectionViewController {

    // MARK: - Propetries

    private let post: Post
    private var comments = [Comment]()

    private lazy var commentInputView: CommentInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let cv = CommentInputAccessoryView(frame: frame)
        cv.delegate = self
        return cv
    }()

    // MARK: - Lifecycle

    // 의존성 주입 (post 객체 받아와서 CommentController 생성)
    init(post: Post) {
        self.post = post
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        fetchComments()
    }


    // commentInputView 를 위한 override 설정.
    override var inputAccessoryView: UIView? {
        get { return commentInputView }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }


    // lifeCycle을 이용해서, 뷰가 나타나기 직전에 탭바를 숨겨주고,
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    // 뷰가 사라지기 직전에 탭바를 다시 나타내 줌.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Actions

    func fetchComments() {
        CommentService.fetchComments(forPost: post.postId) { comments in
            self.comments = comments
            print(comments.count)
            self.collectionView.reloadData()
        }
    }


    // MARK: - Helpers
    func configureCollectionView() {
        navigationItem.title = "댓글"

        collectionView.backgroundColor = .white
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // 컬렉션 뷰 스크롤 시 키보드 숨김.
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
    }

}


// MARK: - UICollectionViewDataSource

extension CommentController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
        cell.viewModel = CommentViewModel(comment: comments[indexPath.row])

        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CommentController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewModel = CommentViewModel(comment: comments[indexPath.row])
        let height = viewModel.size(forWidth: view.frame.width).height + 32
        return CGSize(width: view.frame.width, height: height)
    }
}

// MARK: - CommentInputAccessorViewDelegate

extension CommentController: CommentInputAccessorViewDelegate {
    func inputView(_ inputView: CommentInputAccessoryView, wantsToUploadComment comment: String) {

        // MainTabBarController 의 user 객체 가져옴. (TabBar 컨트롤러에서 navigationController 로 호출 되었기에 사용 가능)
        guard let tabVC = self.tabBarController as? MainTabController else { return } // downCastring
        guard let user = tabVC.user else { return }

        showLoader(true) // 로딩창 띄우기

        CommentService.uploadComment(comment: comment, postID: post.postId, user: user) { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }

            self.showLoader(false) // 로딩창 없애기 (클로저 내부이므로 self 키워드 필요)

            inputView.clearCommentTextView()
        }
    }
}
