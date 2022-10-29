//
//  ProfileCell.swift
//  InstagramClone
//
//  Created by Mason Kim on 2022/10/24.
//

import UIKit

/// 프로필 화면의 피드 부분 CollectionView 에 들어 갈 Cell
class ProfileCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var viewModel: PostViewModel? {
        didSet {
            configure()
        }
    }
    
    private let postImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "venom-7")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .lightGray
        
        addSubview(postImageView)
        // 슈퍼뷰가 셀이기 때문에 이미지가 셀을 꽉 채움.
        postImageView.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let viewModel = viewModel else { return }
        postImageView.sd_setImage(with: viewModel.postImageUrl)
    }
    
}
