//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Berkay DEMİR on 17.01.2026.
//

import UIKit
import Firebase
import SwiftAudioPlayer

class ChatViewController: UICollectionViewController {
    
    // MARK: - Properties
    
    private let reuseIdentifier = "ChatCell"
    private let chatHeaderIdentifier = "ChatHeader"
    private var messages = [[Message]]() {
        didSet {
            self.emptyView.isHidden = !messages.isEmpty
        }
    }
    
    private let emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.5)
        view.layer.cornerRadius = 12
        view.isHidden = true
        return view
    }()
    
    private let emptyLAbel = CustomLabel(text: "This conversation is new and encrypted ", labelColor: .yellow)
    
    private lazy var customInputView: CustomInputView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let iv = CustomInputView(frame: frame)
        iv.delegate = self
        return iv
    }()
    
    lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        return picker
    }()
    
    private lazy var attachAlert: UIAlertController = {
        let alert = UIAlertController(title: "Attach File", message: "Select the button you want to attach from", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.handleCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.handleGallery()
        }))
        
        alert.addAction(UIAlertAction(title: "Location", style: .default, handler: { _ in
            self.present(self.locationAlert, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        return alert
    }()
    
    private lazy var locationAlert: UIAlertController = {
        let alert = UIAlertController(title: "Share Location", message: "Select the button you want to share location from", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Current Location", style: .default, handler: { _ in
            self.handleCurrentLocation()
        }))
        
        alert.addAction(UIAlertAction(title: "Google Maps", style: .default, handler: { _ in
            self.handleGoogleMaps()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        return alert
    }()
    
    var currentUser: User
    var otherUser: User
    
    // MARK: - Lifecycle
    
    init(currentUser: User, otherUser: User) {
        self.currentUser = currentUser
        self.otherUser = otherUser
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(ChatHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: chatHeaderIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchMessages()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.markReadAllMessages()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        markReadAllMessages()
    }
    
    override var inputAccessoryView: UIView? {
        get {return customInputView}
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        title = otherUser.fullname
        collectionView.backgroundColor = .white
        
        collectionView.register(ChatCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .onDrag
        
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        
        view.addSubview(emptyView)
        emptyView.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 25, paddingBottom: 70, paddingRight: 25, height: 50)
        
        emptyView.addSubview(emptyLAbel)
        emptyLAbel.anchor(top: emptyView.topAnchor, left: emptyView.leftAnchor, bottom: emptyView.bottomAnchor, right: emptyView.rightAnchor, paddingTop: 7, paddingLeft: 7, paddingBottom: 7, paddingRight: 7)
    }
    
    private func fetchMessages() {
        MessageService.fetchMessage(otherUser: otherUser) { messages in
            let groupMessages = Dictionary(grouping: messages) { (element) -> String in
                let dateValue = element.timestamp.dateValue()
                let stringDateValue = self.stringValue(forDate: dateValue)
                return stringDateValue ?? ""
            }
            
            self.messages.removeAll()
            
            let sortedKeys = groupMessages.keys.sorted(by: {$0 < $1})
            sortedKeys.forEach { key in
                let values = groupMessages[key]
                self.messages.append(values ?? [])
            }
            self.collectionView.reloadData()
            self.collectionView.scrollToLastItem()
        }
    }
    
    private func markReadAllMessages() {
        MessageService.markReadAllMessages(otherUser: otherUser)
    }
}

//MARK: - Extension

extension ChatViewController {
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            
            guard let firstMessage = messages[indexPath.section].first else {return UICollectionReusableView()}
            
            let dateValue = firstMessage.timestamp.dateValue()
            let stringValue = stringValue(forDate: dateValue)
            
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: chatHeaderIdentifier, for: indexPath) as! ChatHeader
            cell.dateValue = stringValue
            return cell
        }
        return UICollectionReusableView()
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return messages.count
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages[section].count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChatCell
        let message = messages[indexPath.section][indexPath.row]
        cell.viewModel = MessageViewModel(message: message)
        cell.delegate = self
        return cell
    }
}

//MARK: - Delegate Flow Layout

extension ChatViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 15, left: 0, bottom: 15, right: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let cell = ChatCell(frame: frame)
        let message = messages[indexPath.section][indexPath.row]
        cell.viewModel = MessageViewModel(message: message)
        cell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        let estimatedSize = cell.systemLayoutSizeFitting(targetSize)
        
        return .init(width: view.frame.width, height: estimatedSize.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
}

//MARK: - CustomInputViewDelegate

extension ChatViewController: CustomInputViewDelegate {
    
    func inputViewForAudio(_ view: CustomInputView, audioURL: URL) {
        self.showLoader(true)
        FileUploader.uploadAudio(audioURL: audioURL) { audioString in
            MessageService.fetchSingleRecentMessage(otherUser: self.otherUser) { unReadCount in
                MessageService.uploadMessage(audioURL: audioString, currentUser: self.currentUser, otherUser: self.otherUser, unReadCount: unReadCount + 1) { error in
                    self.showLoader(false)
                    
                    if let error = error {
                        print("\(error.localizedDescription)")
                        return
                    }
                }
            }
        }
    }
    
    func inputViewForAttach(_ view: CustomInputView) {
        present(attachAlert, animated: true)
    }
    
    func inputView(_ view: CustomInputView, withUploadMessage message: String) {
        MessageService.fetchSingleRecentMessage(otherUser: otherUser) { [self] unreadCount in
            MessageService.uploadMessage(message: message, currentUser: currentUser, otherUser: otherUser, unReadCount: unreadCount + 1) { _ in
                self.collectionView.reloadData()
            }
        }
        view.clearTextView()
    }
}


