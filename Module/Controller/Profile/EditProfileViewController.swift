//
//  EditProfileViewController.swift
//  ChatApp
//
//  Created by Berkay DEMİR on 24.02.2026.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    private let user: User
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit Profile", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.tintColor = .white
        button.backgroundColor = .lightGray
        button.setDimensions(height: 50, width: 200)
        button.layer.cornerRadius = 12
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleSubmitProfile), for: .touchUpInside)
        return button
    }()
    
    private lazy var profileImageView: CustomImageView = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleImageTap))
        let iv = CustomImageView(width: 125, height: 125, backgorundColor: .lightGray, cornerRadius: 125 / 2)
        iv.addGestureRecognizer(tap)
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private let fullnameLabel = CustomLabel(text: "Fullname", labelColor: .red)
    private let fullnameText = CustomTextField(placeholderText: "fullname")
    
    private let usernameLabel = CustomLabel(text: "Username", labelColor: .red)
    private let usernameText = CustomTextField(placeholderText: "username")
    
    private lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        return picker
    }()
    
    var selectedImage: UIImage?
    
    // MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureProfileData()
    }
    
    // MARK: - Helpers
    
    @objc func handleImageTap() {
        present(imagePicker, animated: true)
    }
    
    @objc func handleSubmitProfile() {
        
        guard let fullname = fullnameText.text else {return}
        guard let username = usernameText.text else {return}
        
        showLoader(true)
        
        if selectedImage == nil {
            
            let params = ["fullname": fullname, "username": username]
            updateUser(params: params)
        } else {
            guard let selectedImage = selectedImage else {return}
            FileUploader.uploadImage(image: selectedImage) { imageURL in
                let params = ["fullname": fullname, "username": username, "profileImageURL": imageURL]
                
                self.updateUser(params: params)
            }
        }
    }
    
    private func updateUser(params: [String: Any]) {
        UserService.setNewUser(data: params) { _ in
            self.showLoader(false)
            NotificationCenter.default.post(name: .userProfile, object: nil )
        }
    }
    
    private func configureProfileData() {
        fullnameText.text = user.fullname
        usernameText.text = user.username
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        
        title = "Edit Profile"
        
        view.addSubview(editButton)
        editButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, right: view.rightAnchor, paddingRight: 12)
        
        view.addSubview(profileImageView)
        profileImageView.anchor(top: editButton.bottomAnchor, paddingTop: 10)
        profileImageView.centerX(inView: view)
        
        let stackView = UIStackView(arrangedSubviews: [fullnameLabel, fullnameText, usernameLabel, usernameText])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading
        
        view.addSubview(stackView)
        stackView.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 30, paddingRight: 30)
        
        fullnameText.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1).isActive = true
        usernameText.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1).isActive = true
    }
}

// MARK: - UIImagePickerController

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {return}
        
        self.selectedImage = image
        self.profileImageView.image = image
        
        dismiss(animated: true)
    }
}



