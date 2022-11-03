//
//  CommentViewModel.swift
//  InstagramClone
//
//  Created by Mason Kim on 2022/11/04.
//

import UIKit

struct CommentViewModel {
    
    private let comment: Comment
    
    var profileImageUrl: URL? { return URL(string: comment.profileImageUrl) }
    
    init(comment: Comment) {
        self.comment = comment
    }
    
    func commentLabelText() -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: "\(comment.username) ", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedString.append(NSAttributedString(string: comment.commentText, attributes: [.font: UIFont.systemFont(ofSize: 14)]))
        return attributedString
    }
    
    /// 특정 width 크기를 준 UILabel 의 CGSize 를 리턴함 (여러줄이 될 때의 기본 높이를 구하기 위함)
    func size(forWidth width: CGFloat) -> CGSize {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = comment.commentText
        label.lineBreakMode = .byWordWrapping
        label.setWidth(width)
        return label.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
}
