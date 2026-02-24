//
//  CustomImageView.swift
//  ChatApp
//
//  Created by Berkay DEMİR on 7.01.2026.
//

import UIKit

class CustomImageView: UIImageView {
    
    init(image: UIImage? = nil, width: CGFloat? = nil, height: CGFloat? = nil, backgorundColor: UIColor? = nil , cornerRadius: CGFloat = 0) {
        super.init(frame: .zero)
        contentMode = .scaleAspectFit
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
        
        if let image = image { self.image = image }
        if let width = width { setWidth(width) }
        if let height = height { setHeight(height) }
        if let backgorundColor = backgorundColor { self.backgroundColor = backgorundColor }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

