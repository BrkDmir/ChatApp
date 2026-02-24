//
//  InputTextView.swift
//  ChatApp
//
//  Created by Berkay DEMİR on 24.01.2026.
//

import UIKit

class InputTextView: UITextView {
    
    let placeholderLabel = CustomLabel(text: "  Type a message...", labelColor: .lightGray)
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        backgroundColor = #colorLiteral(red: 0.9656843543, green: 0.9657825828, blue: 0.9688259959, alpha: 1)
        layer.cornerRadius = 20
        isScrollEnabled = false
        font = .systemFont(ofSize: 16)
        
        addSubview(placeholderLabel)
        placeholderLabel.centerY(inView: self, leftAnchor: leftAnchor, rightAnchor: rightAnchor, paddingLeft: 8)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextDidChange), name: UITextView.textDidChangeNotification, object: nil)
        
        paddingView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleTextDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }
}

extension UITextView {
    func paddingView() {
        self.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
    }
    
}
