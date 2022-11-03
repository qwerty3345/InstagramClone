//
//  InputTextView.swift
//  InstagramClone
//
//  Created by Mason Kim on 2022/10/28.
//

import UIKit

class InputTextView: UITextView {
    
    // MARK: - Properties
    
    var placeholderText: String? {
        didSet { placeholderLabel.text = placeholderText }
    }
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        return label
    }()
    
    var placeHolderShouldCenter = true {
        didSet {
            if placeHolderShouldCenter {
                placeholderLabel.anchor(left: leftAnchor, right: rightAnchor, paddingLeft: 8)
                placeholderLabel.centerY(inView: self)
            } else {
                placeholderLabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 6, paddingLeft: 8)
            }
        }
    }
    
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        addSubview(placeholderLabel)
        
        // 텍스트 값 변경에 대한 NotificationCenter observer 등록
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextDidChange),
                                               name: UITextView.textDidChangeNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    // MARK: - Actions
    
    @objc func handleTextDidChange() {
        // 텍스트가 비어있지 않을 때는 placeholderLabel 숨기기
        placeholderLabel.isHidden = !text.isEmpty
    }
    
}
