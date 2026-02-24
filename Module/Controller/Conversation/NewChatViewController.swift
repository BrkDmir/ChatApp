//
//  NewChatViewController.swift
//  ChatApp
//
//  Created by Berkay DEMİR on 17.01.2026.
//

import UIKit
import Firebase

protocol NewChatViewControllerDelegate: AnyObject{
    func controller(_ vc: NewChatViewController, wantChatWithUser otherUser: User)
}

class NewChatViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: NewChatViewControllerDelegate?
    private var filterUsers: [User] = []
    private let searchController = UISearchController(searchResultsController: nil)
    
    private let tableView = UITableView()
    private let reuseIdentifierForUserCell = "UserCell"
    
    private var users: [User] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var inSearchMode: Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUITableView()
        configureUI()
        fetchUsers()
        configureSearchController()
    }
    
    // MARK: - Helpers
    
    private func fetchUsers() {
        showLoader(true)
        UserService.fetchUsers() { users in
            self.showLoader(false)
            self.users = users
            
            guard let uid = Auth.auth().currentUser?.uid else {return}
            guard let index = self.users.firstIndex(where: {$0.uid == uid}) else {return}
            self.users.remove(at: index)
            print("\(users)")
        }
    }
    
    private func configureUITableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
        tableView.backgroundColor = .white
        tableView.register(UserCell.self, forCellReuseIdentifier: reuseIdentifierForUserCell)
        tableView.tableFooterView = UIView()
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        title = "Search"
        
        view.addSubview(tableView)
        tableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 15, paddingRight: 15 )
    }
    
    private func configureSearchController() {
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
    }
}

// MARK: - TableView Extension

extension NewChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inSearchMode ? filterUsers.count : users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierForUserCell, for: indexPath) as! UserCell
        let user = inSearchMode ? filterUsers[indexPath.row] : users[indexPath.row]
        cell.viewModel = UserViewModel(user: user)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = inSearchMode ? filterUsers[indexPath.row] : users[indexPath.row]
        delegate?.controller(self, wantChatWithUser: user)
    }
}

// MARK: - UISearchResultsUpdating

extension NewChatViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {return}
        filterUsers = users.filter({$0.username.contains(searchText) || $0.fullname.lowercased().contains(searchText)})
        
        print(filterUsers)
        tableView.reloadData()
    }
}

// MARK: - UISearchBarDelegate

extension NewChatViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.text = nil
        searchBar.showsCancelButton = false
    }
}
