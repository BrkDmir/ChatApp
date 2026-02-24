//
//  CustomLabel.swift
//  ChatApp
//
//  Created by Berkay DEMİR on 7.01.2026.
//

import Foundation
import UIKit

class CustomLabel: UILabel {
    
    init(text: String, labelFont: UIFont = .systemFont(ofSize: 14), labelColor: UIColor = .black) {
        super.init(frame: .zero)
        self.text = text
        font = labelFont
        textColor = labelColor
        
        textAlignment = .center
        numberOfLines = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
