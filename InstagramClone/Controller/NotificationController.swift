//
//  NotificationController.swift
//  InstagramClone
//
//  Created by Mason Kim on 2022/10/21.
//

import UIKit

private let reuseIdentifier = "NotificationCell"

final class NotificationController: UITableViewController {

    // MARK: - Properties
    var notifications = [Notification]() {
        didSet { tableView.reloadData() }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        fetchNotifications()
    }
    
    
    // MARK: - Actions

    /// 리프레시 컨트롤에 대한 새로고침 액션
    @objc func handleRefresh() {
        notifications.removeAll()
        fetchNotifications()
    }
    

    // MARK: - API

    // 알림들 DB에서 불러오기
    func fetchNotifications() {
        NotificationService.fetchNotifications { notifications in
            self.notifications = notifications
//            notifications.forEach { print("\($0.username), \($0.postId), \($0.type), \($0.postImageUrl)") }
            self.checkIfUserIsFollowed()
            
            self.tableView.refreshControl?.endRefreshing()
        }
    }

    /// 알림에서 알려주는, '나를 팔로우한 유저'를 내가 팔로우 하고 있는지 여부를 확인해서 notification 객체에 할당
    func checkIfUserIsFollowed() {
        print("checkIfUserIsFollowed")
        notifications.forEach { notification in
            guard notification.type == .follow else { return }
            print("check!")

            UserService.checkIfUserIsFollowed(uid: notification.uid) { isFollowed in
                if let index = self.notifications.firstIndex(where: { $0.id == notification.id }) {
                    print(isFollowed)
                    self.notifications[index].userIsFollowed = isFollowed
                }
            }
        }
    }

    // MARK: - Helpers

    func configureTableView() {
        view.backgroundColor = .white
        navigationItem.title = "알림"

        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
        
        // 리프레셔 (스크롤 아래로 당기면 새로고침) 추가
        let refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refresher
    }

}


// MARK: - UITableViewDataSource

extension NotificationController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
        cell.viewModel = NotificationViewModel(notification: notifications[indexPath.row])
        cell.delegate = self
        return cell
    }
}


// MARK: - UITableViewDelegate

extension NotificationController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 알람 셀 터치 시 동작
    }
}


// MARK: - NotificationCellDelegate

extension NotificationController: NotificationCellDelegate {
    // 팔로우
    func cell(_ cell: NotificationCell, wantsToFollow uid: String) {
        showLoader(true)
        print("NotificationCellDelegate wantsToFollow")
        UserService.follow(uid: uid) { _ in
            cell.viewModel?.notification.userIsFollowed = true
            self.showLoader(false)
        }
    }

    // 언팔로우
    func cell(_ cell: NotificationCell, wantsToUnfollow uid: String) {
        showLoader(true)
        print("NotificationCellDelegate wantsToUnfollow")
        UserService.unfollow(uid: uid) { _ in
            cell.viewModel?.notification.userIsFollowed = false
            self.showLoader(false)
        }
    }

    // 게시글 보기
    func cell(_ cell: NotificationCell, wantsToViewPost postId: String) {
        showLoader(true)
        PostService.fetchPost(withPostId: postId) { post in
            self.showLoader(false)
            let vc = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
            vc.post = post
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    // 유저 프로필 보기
    func cell(_ cell: NotificationCell, wantsToShowUser userId: String) {
        showLoader(true)
        UserService.fetchUser(withUid: userId) { user in
            self.showLoader(false)
            let vc = ProfileController(user: user)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
