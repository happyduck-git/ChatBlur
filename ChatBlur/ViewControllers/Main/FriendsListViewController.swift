//
//  FriendsListViewController.swift
//  ChatBlur
//
//  Created by HappyDuck on 1/1/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class FriendsListViewController: BaseViewController {

    //MARK: - View Model
    private let vm: FriendsListViewModel
    
    private let disposeBag = DisposeBag()
    
    //MARK: - UI Elements
    private let flexContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private let addBtn = UIBarButtonItem(systemItem: .add)
    
    private let friendsTableView: UITableView = {
        let table = UITableView()
        table.register(FriendTableViewCell.self,
                       forCellReuseIdentifier: FriendTableViewCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
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
        
        self.setUI()
        self.setLayout()
        
        self.setNavigationItems()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setFlexContainer()
        
        
    }
}

extension FriendsListViewController {
    private func bind(with vm: FriendsListViewModel) {
        
        let dataSource = RxTableViewSectionedReloadDataSource<FriendViewSectionData> { datasrouce, table, indexPath, item in
            guard let cell = table.dequeueReusableCell(withIdentifier: FriendTableViewCell.identifier,
                                                       for: indexPath) as? FriendTableViewCell else {
                return UITableViewCell()
            }
            print("**Item: \(item)")
            cell.configure(with: item)
            
            return cell
        }
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].header
        }
        
        let emailTextInput = PublishRelay<String>()
        
        addBtn.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.showAddFriendAlert {
                    emailTextInput.accept($0)
                }
            })
            .disposed(by: disposeBag)
        
        let input = FriendsListViewModel.Input(addFriendEmail: emailTextInput)
        
        let output = vm.transform(input: input)
        
        output.sectionData
            .bind(to: self.friendsTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.addFriendRelay
            .subscribe()
            .disposed(by: disposeBag)
        
        output.errorTracker
            .subscribe(onNext: { [weak self] _ in
                
            })
            .disposed(by: disposeBag)
    }
}

extension FriendsListViewController {
    
    private func setNavigationItems() {
        self.navigationItem.rightBarButtonItem = self.addBtn
    }
    
    private func setUI() {
//        self.view.addSubview(self.flexContainer)
        self.view.addSubview(self.friendsTableView)
        
        NSLayoutConstraint.activate([
            self.friendsTableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.friendsTableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.friendsTableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.friendsTableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setFlexContainer() {
//        self.flexContainer.pin
//            .all(self.view.pin.safeArea)
//        self.friendsTableView.pin
//            .all(self.flexContainer.pin.safeArea)
//        self.flexContainer.flex.layout()
    }
    
    private func setLayout() {
//        self.flexContainer.flex
//            .direction(.column)
//            .define { flex in
//                flex.addItem(self.friendsTableView)
//                
//            }
    }
}

extension FriendsListViewController {
    private func showAddFriendAlert(action: @escaping (String) -> ()) {
        let alert = UIAlertController(title: FriendsViewConstants.addFriend,
                                      message: FriendsViewConstants.inputEmail,
                                      preferredStyle: .alert)
        alert.addTextField()
        alert.textFields?.first?.placeholder = "abcd@email.com"
        
        let action = UIAlertAction(title: FriendsViewConstants.add,
                                   style: .default) { [weak alert, weak self] _ in
            guard let `self` = self else { return }
            let email = alert?.textFields?[0].text ?? String()
            action(email)
        }
        alert.addAction(action)
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.present(alert, animated: true)
        }
    }
    
    
}
