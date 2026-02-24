//
//  ConversationCell.swift
//  ChatApp
//
//  Created by Berkay DEMİR on 17.01.2026.
//

import UIKit
import SDWebImage

class ConversationCell: UITableViewCell {
    
    // MARK: - Properties
    
    var viewModel: MessageViewModel? {
        didSet {
            configure()
        }
    }
    
    private let profileImageView = CustomImageView(image: #imageLiteral(resourceName: "Google_Contacts_logo copy"), width: 60, height: 60, backgorundColor: .lightGray, cornerRadius: 30)
    
    private let fullname = CustomLabel(text: "Fullname")
    private let recentMessage = CustomLabel(text: "Recent Message", labelColor: .lightGray)
    private let dateLabel = CustomLabel(text: "17/01/2026", labelColor: .lightGray)
    
    private let unReadMessageLabel: UILabel = {
       let label = UILabel()
        label.text = "7"
        label.font = .boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.backgroundColor = .red
        label.setDimensions(height: 30, width: 30)
        label.layer.cornerRadius = 15
        label.textAlignment = .center
        label.clipsToBounds = true
        return label
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        addSubview(profileImageView)
        profileImageView.centerY(inView: self, leftAnchor: leftAnchor)
        
        let stackView = UIStackView(arrangedSubviews: [fullname, recentMessage])
        stackView.axis = .vertical
        stackView.spacing = 7
        stackView.alignment = .leading
        
        addSubview(stackView)
        stackView.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 15)
        
        let stackDate = UIStackView(arrangedSubviews: [dateLabel, unReadMessageLabel])
        stackDate.axis = .vertical
        stackDate.spacing = 7
        stackDate.alignment = .trailing
        
        addSubview(stackDate)
        stackDate.centerY(inView: profileImageView, rightAnchor: rightAnchor, paddingRight: 8)
        
        /*
        addSubview(dateLabel)
        dateLabel.centerY(inView: self, rightAnchor: rightAnchor, paddingRight: 10)
         */
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    private func configure() {
        guard let viewModel = viewModel else { return }
        
        self.profileImageView.sd_setImage(with: viewModel.profileImageURL)
        self.fullname.text = viewModel.fullname
        self.recentMessage.text = viewModel.messageText
        self.dateLabel.text = viewModel.timestampString
        
        self.unReadMessageLabel.text = "\(viewModel.unReadCount)"
        self.unReadMessageLabel.isHidden = viewModel.shouldHideUnReadLabel
    }
}

