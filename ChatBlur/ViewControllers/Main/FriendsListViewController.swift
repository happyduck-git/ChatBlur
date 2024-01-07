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
        
        let emailTextInput = PublishRelay<String>()
        
        self.addBtn.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.showAddFriendAlert {
                    emailTextInput.accept($0)
                }
            })
            .disposed(by: disposeBag)
        
        self.friendsTableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        let input = FriendsListViewModel.Input(addFriendEmail: emailTextInput)
        
        //MARK: - Output subscription
        let output = vm.transform(input: input)
        
        let dataSource = self.createDataSource()
        
        output.sectionData
            .bind(to: self.friendsTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.addFriendRelay
            .subscribe()
            .disposed(by: disposeBag)
        
        output.chatRoomTrigger
            .subscribe(onNext: { [weak self] friend in
                guard let `self` = self else { return }
          
                DispatchQueue.main.async {
                    let vm = ChatRoomViewModel(friendId: friend.id)
                    let vc = ChatRoomViewController(vm: vm)
                    self.show(vc, sender: self)
                }
            })
            .disposed(by: disposeBag)
        
        output.errorTracker
            .subscribe(onNext: { [weak self] err in
                guard let `self` = self else { return }
                let action = UIAlertAction(title: ErrorConstants.confirm, style: .cancel)
                self.showAlert(title: ErrorConstants.errorMsg,
                               msg: ErrorConstants.errorMsg + "\(err.localizedDescription)",
                               action1: action)
            })
            .disposed(by: disposeBag)
    }
}

extension FriendsListViewController {
    
    private func setNavigationItems() {
        self.navigationItem.rightBarButtonItem = self.addBtn
    }
    
    private func setUI() {
        self.view.addSubview(self.flexContainer)
    }
    
    private func setFlexContainer() {
        self.flexContainer.pin
            .all(self.view.pin.safeArea)

        self.flexContainer.flex.layout()
    }
    
    private func setLayout() {
        self.flexContainer.flex
            .direction(.column)
            .define { flex in
                flex.addItem(self.friendsTableView)
                    .grow(1)
            }
    }
}

extension FriendsListViewController: UITableViewDelegate {
    
    /// Create data source for table view.
    /// - Returns: RxTableViewSectionedReloadDataSource
    private func createDataSource() -> RxTableViewSectionedReloadDataSource<FriendViewSectionData> {
        let dataSource = RxTableViewSectionedReloadDataSource<FriendViewSectionData> { datasrouce, table, indexPath, item in
            guard let cell = table.dequeueReusableCell(withIdentifier: FriendTableViewCell.identifier,
                                                       for: indexPath) as? FriendTableViewCell else {
                return UITableViewCell()
            }
            #if DEBUG
            print("**Item: \(item)")
            #endif
            
            cell.configure(with: item)
            
            return cell
        }
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].header
        }
        return dataSource
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 0 { return nil }
        
        let goToChat = UIContextualAction(style: .normal, title: FriendsViewConstants.goToChat) { [weak self] _, _, _ in
            guard let `self` = self else { return }
            self.vm.moveToChatTracker.accept(indexPath)
        }
        
        return UISwipeActionsConfiguration(actions: [goToChat])
    }
    
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 0 { return nil }
        
        let delete = UIContextualAction(style: .destructive, title: FriendsViewConstants.remove) { action, _, completion in
            //TODO: Delete friend from friends_list
            print("Delete triggered.")
        }
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        return
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
                                   style: .default) { [weak alert] _ in
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
