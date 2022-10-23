//
//  FeedController.swift
//  InstagramClone
//
//  Created by Mason Kim on 2022/10/21.
//

import UIKit

private let reuseIndentifier = "Cell"

final class FeedController: UICollectionViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        collectionView.backgroundColor = .white
        
        // Cell에 대한 클래스와 셀의 재사용을 위한 id값을 등록해줘야 함.
        collectionView.register(FeedCell.self, forCellWithReuseIdentifier: reuseIndentifier)
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
