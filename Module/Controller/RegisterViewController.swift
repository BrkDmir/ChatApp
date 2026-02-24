//
//  RegisterViewController.swift
//  ChatApp
//
//  Created by Berkay DEMİR on 30.12.2025.
//

import UIKit
import Firebase

protocol registerVC_Delegate: AnyObject {
    func didSuccessfullyCreateAccount(_ vc: RegisterViewController)
}

class RegisterViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: registerVC_Delegate?
    
    var viewModel = RegisterViewModel()
    
    private lazy var alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedText(firstString: "Already have an account?", secondString: "Login")
        button.setHeight(50)
        button.addTarget(self, action: #selector(handleAlreadyHaveAccountButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "plus_photo"), for: .normal)
        button.setDimensions(height: 140, width: 140)
        button.tintColor = .lightGray
        button.addTarget(self, action: #selector(handlePlusPhotoButton), for: .touchUpInside)
        return button
    }()
    
    private let emailTextField = CustomTextField(placeholderText: "Email", keyboardType: .emailAddress)
    private let passwordTextField = CustomTextField(placeholderText: "Password", isSecure: true)
    private let fullnameTextField = CustomTextField(placeholderText: "Fullname")
    private let usernameTextField = CustomTextField(placeholderText: "Username")
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleSignUpButton), for: .touchUpInside)
        button.blackButton(buttonText: "Sign Up")
        return button
    }()
    
    private var profileImage: UIImage?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureTextField()
        
    }
   
    
    // MARK: - Helpers
    
    private func configureUI() {
        view.backgroundColor = .white
        
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
        alreadyHaveAccountButton.centerX(inView: view)
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor, paddingTop: 30)
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, fullnameTextField, usernameTextField, signUpButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        
        view.addSubview(stackView)
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 30, paddingRight: 30)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            tapGesture.cancelsTouchesInView = false
            view.addGestureRecognizer(tapGesture)
    }
    
    private func configureTextField() {
        emailTextField.addTarget(self, action: #selector(handleTextField(sender:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(handleTextField(sender:)), for: .editingChanged)
        fullnameTextField.addTarget(self, action: #selector(handleTextField(sender:)), for: .editingChanged)
        usernameTextField.addTarget(self, action: #selector(handleTextField(sender:)), for: .editingChanged)
    }
    
    // MARK: - Actions
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func handleAlreadyHaveAccountButton() {
        navigationController?.popViewController(animated: true)
    }
    
    
    @objc func handlePlusPhotoButton() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    @objc func handleSignUpButton() {
        guard let email = emailTextField.text?.lowercased() else {return}
        guard let password = passwordTextField.text else {return}
        guard let username = usernameTextField.text?.lowercased() else {return}
        guard let fullname = fullnameTextField.text else {return}
        guard let profileImage = profileImage else {return}
        
        let credential = AuthCredential(email: email, password: password, username: username, fullname: fullname, profileImage: profileImage)
        
        showLoader(true)
        AuthServices.registerUser(credential: credential) { error in
           //self.showLoader(false)
            if let error = error {
                self.showMessage(title: "Error", message: error.localizedDescription)
                return
            }
            self.delegate?.didSuccessfullyCreateAccount(self)
        }
        
    }
    
    @objc func handleTextField(sender: UITextField) {
        
        if sender == emailTextField {
            viewModel.email = sender.text
        } else if sender == passwordTextField {
            viewModel.password = sender.text
        } else if sender == fullnameTextField {
            viewModel.fullname = sender.text
        } else if sender == usernameTextField {
            viewModel.username = sender.text
        }
        
        updateForm()
    }
    
    private func updateForm() {
        signUpButton.isEnabled = viewModel.formIsValid
        signUpButton.backgroundColor = viewModel.backgroundColor
        signUpButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.editedImage] as? UIImage else {return}
        
        self.profileImage = selectedImage
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 1.8
        plusPhotoButton.setImage(selectedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        dismiss(animated: true, completion: nil)
    }
}

