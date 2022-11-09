//
//  NotificationCell.swift
//  InstagramClone
//
//  Created by Mason Kim on 2022/11/05.
//

import UIKit

protocol NotificationCellDelegate: AnyObject {
    func cell(_ cell: NotificationCell, wantsToFollow uid: String)
    func cell(_ cell: NotificationCell, wantsToUnfollow uid: String)
    func cell(_ cell: NotificationCell, wantsToViewPost postId: String)
    func cell(_ cell: NotificationCell, wantsToShowUser userId: String)
}

class NotificationCell: UITableViewCell {
    
    // MARK: - Properties
    
    var viewModel: NotificationViewModel? {
        didSet { configure() }
    }
    
    weak var delegate: NotificationCellDelegate?
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.image = #imageLiteral(resourceName: "profile_selected")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleShowUser))
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(tap)
        
        return iv
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 14)
        label.text = "testname"
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var postImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handlePostTapped))
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(tap)
        
        return iv
    }()
    
    private let followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("팔로우", for: .normal)
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // 테이블뷰 셀 자체(전체)를 선택하지는 못하게 함.
        selectionStyle = .none
        
        backgroundColor = .white
        
        
        // ⭐️⭐️⭐️ TableViewCell 에서 delegate 지정 잘 했는데도 클릭 안되고 didSelectRowAt만 호출되는 문제 발생 시, contentView에 addSubView 하는 것으로 해결.
        // 참고: https://jiseok-zip.tistory.com/entry/SwiftTable-View-%EC%9D%B4%EC%8A%88
        
        contentView.addSubview(profileImageView)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
        profileImageView.setDimensions(height: 48, width: 48)
        profileImageView.layer.cornerRadius = 48 / 2
        
        contentView.addSubview(followButton)
        followButton.centerY(inView: self)
        followButton.anchor(right: rightAnchor, paddingRight: 12, width: 80, height: 32)
        
        contentView.addSubview(postImageView)
        postImageView.centerY(inView: self)
        postImageView.anchor(right: rightAnchor, paddingRight: 12, width: 40, height: 40)
        
        contentView.addSubview(infoLabel)
        infoLabel.centerY(inView: self, leftAnchor: profileImageView.rightAnchor, paddingLeft: 8)
        infoLabel.anchor(right: followButton.leftAnchor, paddingRight: 4)
        
        followButton.isHidden = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Actions
    
    /// 팔로우/언팔로우 버튼 누를 시 액션
    @objc func handleFollowTapped() {
        guard let viewModel else { return }
        
        if viewModel.notification.userIsFollowed {
            delegate?.cell(self, wantsToUnfollow: viewModel.notification.uid)
        } else {
            delegate?.cell(self, wantsToFollow: viewModel.notification.uid)
        }
    }
    
    /// 포스트 이미지 누를 시 액션
    @objc func handlePostTapped() {
        guard let postId = viewModel?.notification.postId else { return }
        delegate?.cell(self, wantsToViewPost: postId)
    }
    
    /// 사용자 프로필 이미지 누를 시 액션
    @objc func handleShowUser() {
        guard let viewModel else { return }
        delegate?.cell(self, wantsToShowUser: viewModel.notification.uid)
    }
    
    
    // MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel else { return }
        
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        
        if let postImageUrl = viewModel.postImageUrl {
            postImageView.sd_setImage(with: postImageUrl)
        }
        
        infoLabel.attributedText = viewModel.notificationMessage
        
        followButton.isHidden = viewModel.followButtonIsHidden
        postImageView.isHidden = viewModel.postImageIsHidden
        
        followButton.setTitle(viewModel.followButtonText, for: .normal)
        followButton.setTitleColor(viewModel.followButtonTextColor, for: .normal)
        followButton.backgroundColor = viewModel.followButtonColor
    }
    
}
