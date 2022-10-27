//
//  ProfileController.swift
//  InstagramClone
//
//  Created by Mason Kim on 2022/10/21.
//

import UIKit

private let cellIndentifier = "ProfileCell"
private let headerIdentifier = "ProfileHeader"

final class ProfileController: UICollectionViewController {
    
    // MARK: - Properties
    
    private var user: User
//    {
//        // (속성 감시자) user 데이터 할당 시,
//        didSet {
//            // ⭐️⭐️⭐️컬렉션뷰 데이터 리로드 해줌. (viewModel의 user 할당 구문이 실행될 것. _ datasource 메서드)
//            collectionView.reloadData()
//        }
//    }
    
    
    
    // MARK: - Lifecycle
    
    // DI - 의존성 주입. ProfileController가 생성될 때 마다 다른 user를 받아서 표시 해 주도록 함.
    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCollectionView()
        checkIfUserIsFollowed()
        fetchUserStats()
    }
    
    // MARK: - API
    
    func checkIfUserIsFollowed() {
        UserService.checkIfUserIsFollowed(uid: user.uid) { isFollowed in
            self.user.isFollwed = isFollowed
            self.collectionView.reloadData()
        }
    }
    
    func fetchUserStats() {
        UserService.fetchUserStats(uid: user.uid) { stats in
            self.user.stats = stats
            self.collectionView.reloadData()
        }
    }

    // MARK: - Actions
    
    // MARK: - Helpers
    
    func configureCollectionView() {
        navigationItem.title = user.username
        collectionView.backgroundColor = .white
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: cellIndentifier)
        collectionView.register(ProfileHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: headerIdentifier)
    }
}

// MARK: - UICollectionViewDataSource

extension ProfileController {
    // 컬렉션뷰 셀 갯수
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    // 컬렉션뷰 셀 지정
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIndentifier, for: indexPath) as! ProfileCell
        return cell
    }
    
    // "viewForSupplementaryElementOfKind" : 헤더를 지정하기 위한 펑션
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! ProfileHeader
        
        header.delegate = self
        
        // DI 방식으로 할 때는 user가 항상 존재함.
        header.viewModel = ProfileHeaderViewModel(user: user)
        
        return header
    }
}

// MARK: - UICollectionViewDelegate

extension ProfileController {
    
}


// MARK: - UICollectionViewDelegateFlowLayout

extension ProfileController: UICollectionViewDelegateFlowLayout {
    // collectionView 내부의 줄(행) 사이 간격의 최소 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    // collectionView 셀 사이의 최소 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 250)
    }
}

// MARK: - ProfileHeaderDelegate
extension ProfileController: ProfileHeaderDelegate {
    func header(_ profileHeader: ProfileHeader, didTapActionButtonFor user: User) {
        
        if user.isCurrentUser {
            
            print("#### 현재 유저 상태이므로 프로필 수정")
            
        } else if user.isFollwed {
            
            print("#### 언팔로우 처리")
            UserService.unfollow(uid: user.uid) { error in
                self.user.isFollwed = false
                // ⭐️ 이렇게 UserStat에 대한 API 호출을 또 해서 보여주는 것 보다, 당장 1만큼만 변경해서 보여주는 것이 좋은 로직.
                self.user.stats.followers -= 1
                self.collectionView.reloadData()
            }
            
        } else {
            
            print("#### 팔로우 처리")
            UserService.follow(uid: user.uid) { error in
                self.user.isFollwed = true
                // ⭐️ 이렇게 UserStat에 대한 API 호출을 또 해서 보여주는 것 보다, 당장 1만큼만 변경해서 보여주는 것이 좋은 로직.
                self.user.stats.followers += 1
                self.collectionView.reloadData()
            }
            
        }

    }
    
    
}
