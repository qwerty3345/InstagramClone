//
//  SearchController.swift
//  InstagramClone
//
//  Created by Mason Kim on 2022/10/21.
//

import UIKit

private let reuseIdentifier = "UserCell"

final class SearchController: UITableViewController {
    
    // MARK: - Properties
    
    private var users = [User]()
    private var filteredUsers = [User]()
    
    private let searchController = UISearchController(searchResultsController: nil)
    // 검색 중인지 판별하는 Bool 계산 속성
    private var isSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureSearchController()
        fetchUsers()
    }
    
    
    // MARK: - API
    
    func fetchUsers() {
        UserService.fetchUsers { users in
            self.users = users
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Helpers
    func configureTableView() {
        view.backgroundColor = .white
        tableView.register(UserCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 64
    }
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "사용자 검색"
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }
}

// MARK: - UITableViewDatasource

extension SearchController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 검색 모드이면 filteredUser, 아니면 기본 users 로 갯수 반환
        return isSearchMode ? filteredUsers.count : users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! UserCell
        
        // 검색 모드이면 filteredUser, 아니면 기본 users 로 뷰모델 초기화
        let user = isSearchMode ? filteredUsers[indexPath.row] :users[indexPath.row]
        cell.viewModel = UserCellViewModel(user: user)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SearchController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = isSearchMode ? filteredUsers[indexPath.row] :users[indexPath.row]
        let vc = ProfileController(user: user)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UISearchResultsUpdating

extension SearchController: UISearchResultsUpdating {
    // 사용자 SearchController 텍스트 입력 시 결과 업뎃
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let searchText = searchController.searchBar.text?.lowercased() else { return }
        
        // 사용자 입력 텍스트를 바탕으로 필터링
        filteredUsers = users.filter {
            $0.username.lowercased().contains(searchText) ||
            $0.fullname.lowercased().contains(searchText)
        }
        
        // tableView 새로고침
        self.tableView.reloadData()
    }
}
