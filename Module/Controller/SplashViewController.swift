//
//  SplashViewController.swift
//  ChatApp
//
//  Created by Berkay DEMİR on 14.01.2026.
//

import UIKit
import Firebase

class SplashViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser?.uid == nil {
            let controller = LoginViewController()
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        } else {
            guard let uid = Auth.auth().currentUser?.uid else {return}
            showLoader(true)
            UserService.fetchUser(uid: uid) {[self] user in
                showLoader(false)
                let controller = ConversationViewController(user: user)
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                present(nav, animated: true, completion: nil)
            }
        }
    }
}
