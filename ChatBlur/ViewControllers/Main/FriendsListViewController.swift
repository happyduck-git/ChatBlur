//
//  FriendsListViewController.swift
//  ChatBlur
//
//  Created by HappyDuck on 1/1/24.
//

import UIKit

final class FriendsListViewController: BaseViewController {

    //MARK: - View Model
    private let vm: FriendsListViewModel
    
    //MARK: - UI Elements
    private let friendsTableView: UITableView = {
        let table = UITableView()
        table.register(FriendTableViewCell.self,
                       forCellReuseIdentifier: FriendTableViewCell.identifier)
        return table
    }()
    
    //MARK: - Init
    init(vm: FriendsListViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
        
        self.bind(with: self.vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .background
        
        self.setupDelegate()
    }

}

extension FriendsListViewController {
    private func bind(with vm: FriendsListViewModel) {
        let _ = vm.transform(input: FriendsListViewModel.Input())
        
    }
}

extension FriendsListViewController {
    private func setupDelegate() {
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
    }
}

extension FriendsListViewController: UITableViewDelegate, UITableViewDataSource {
    enum Section: String, CaseIterable {
        case me
        case friends
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FriendTableViewCell.identifier,
                                                       for: indexPath) as? FriendTableViewCell else {
            return UITableViewCell()
        }
        
        var user: ChatUser?
        
//        switch indexPath.section {
//        case 0:
//            
//        default:
//            
//        }
//        cell.configure(with: <#T##ChatUser#>)
        return cell
    }
}
