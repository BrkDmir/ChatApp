//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Berkay DEMİR on 30.12.2025.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    var viewModel = LoginViewModel()
    
    private let welcomeLabel: UILabel = CustomLabel(text: "HEY, WELCOME", labelFont: .boldSystemFont(ofSize: 20))
    
    private let profileImageView = CustomImageView(image: #imageLiteral(resourceName: "profile"), width: 50, height: 50)
    
    private let emailTextField = CustomTextField(placeholderText: "Email", keyboardType: .emailAddress)
    private let passwordTextField = CustomTextField(placeholderText: "Password", isSecure: true)
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(handleLoginVC), for: .touchUpInside)
        button.blackButton(buttonText: "Login")
        return button
    }()
    
    private lazy var forgetPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedText(firstString: "Forget your password?", secondString: "Get help signing in")
        button.setHeight(50)
        button.addTarget(self, action: #selector(handleForgetPassword), for: .touchUpInside)
        return button
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.attributedText(firstString: "Don't have an account?", secondString: "Sign up")
        button.setHeight(50)
        button.addTarget(self, action: #selector(handleSignUpButton), for: .touchUpInside)
        return button
    }()
    
    private let continueLabel = CustomLabel(text: "or continue with Google", labelColor: .lightGray)
    
    private lazy var googleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Google", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .black
        button.setDimensions(height: 50, width: 150)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = .boldSystemFont(ofSize: 19)
        button.addTarget(self, action: #selector(handleGoogleSignInVC), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureForTextField()
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        
        view.backgroundColor = .white
        
        view.addSubview(welcomeLabel)
        welcomeLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor)
        welcomeLabel.centerX(inView: view)
        
        view.addSubview(profileImageView)
        profileImageView.anchor(top: welcomeLabel.bottomAnchor, paddingTop: 15)
        profileImageView.centerX(inView: view)
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton, forgetPasswordButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        
        view.addSubview(stackView)
        stackView.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 30, paddingRight: 30)
        
        view.addSubview(signUpButton)
        signUpButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
        signUpButton.centerX(inView: view)
        
        view.addSubview(continueLabel)
        continueLabel.centerX(inView: view, topAnchor: forgetPasswordButton.bottomAnchor, paddingTop: 30)
        
        view.addSubview(googleButton)
        googleButton.centerX(inView: view, topAnchor: continueLabel.bottomAnchor, paddingTop: 12)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            tapGesture.cancelsTouchesInView = false
            view.addGestureRecognizer(tapGesture)
    }
    
    private func configureForTextField() {
        emailTextField.addTarget(self, action: #selector(handleTextChanged(sender: )), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(handleTextChanged(sender: )), for: .editingChanged)
    }
    
    
    //MARK: - Actions
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func handleLoginVC() {
        
        guard let email = emailTextField.text?.lowercased() else {return}
        guard let password = passwordTextField.text else {return}
        
        showLoader(true)
        AuthServices.loginUser(withEmail: email, withPassword: password) { result, error in
            self.showLoader(false)
            if let error = error {
                self.showMessage(title: "Error", message: error.localizedDescription)
                return
            }
            self.showLoader(false)
            self.navToConversationViewController()
        }
    }
    
    @objc func handleForgetPassword() {
        print("Forget password tapped")
    }
    
    @objc func handleSignUpButton() {
        let controller = RegisterViewController()
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func handleGoogleSignInVC() {
        showLoader(true)
        setupGoogle()
        
    }
    
    @objc func handleTextChanged(sender: UITextField) {
        sender == emailTextField ? (viewModel.email = sender.text) : (viewModel.password = sender.text)
        updateForm()
    }
    
    private func updateForm() {
        loginButton.isEnabled = viewModel.formIsValid
        loginButton.backgroundColor = viewModel.backgroundColor
        loginButton.setTitleColor(viewModel.buttonTitleColor, for: .normal)
    }
    
    func navToConversationViewController() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        showLoader(true)
        UserService.fetchUser(uid: uid) { user in
            self.showLoader(false)
            let controller = ConversationViewController(user: user)
            let nav = UINavigationController(rootViewController: controller)
            nav.navigationBar.isHidden = false
            nav.modalPresentationStyle = .fullScreen
           self.present(nav, animated: true, completion: nil)
        }
    }
}


// MARK: - Register Delegate

extension LoginViewController: registerVC_Delegate {
    func didSuccessfullyCreateAccount(_ vc: RegisterViewController) {
        vc.navigationController?.popViewController(animated: true)
        showLoader(false)
        navToConversationViewController()
    }
}
