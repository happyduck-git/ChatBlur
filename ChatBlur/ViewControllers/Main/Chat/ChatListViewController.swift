//
//  ChatListViewController.swift
//  ChatBlur
//
//  Created by HappyDuck on 1/1/24.
//

import UIKit
import UIKitBooster

final class ChatListViewController: UIViewController {

    // TEMP
    private var testChatData: [String] = []
    
    private let vm: ChatListViewModel
    
    //MARK: - UI Elements
    private var keyboardHeight: CGFloat = 0
    
    private let baseContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        return view
    }()
    
    private let flexContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let chatTableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .systemOrange
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: UITableViewCell.identifier)
        return table
    }()
    
    private let chatTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .systemRed
        textField.placeholder = "Write Something"
        return textField
    }()
    
    init(vm: ChatListViewModel) {
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
        self.dismissKeyboard()
        
        for i in 0...100 {
            self.testChatData.append("\(i)")
        }

        self.setUI()
        self.setLayout()
        self.setDelegate()
        
        self.setNotification()
        
//        self.demoSaveFriend()
//        self.demo_fetchFriendsList()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setFlexContainer()
    }
    
}

extension ChatListViewController {
    private func bind(with vm: ChatListViewModel) {
        let _ = vm.transform(input: ChatListViewModel.Input())
    }
}

extension ChatListViewController {
    
    private func setDelegate() {
        self.chatTableView.delegate = self
        self.chatTableView.dataSource = self
        
        self.chatTextField.delegate = self
    }
    
    private func setFlexContainer() {
        if keyboardHeight != 0 {
            keyboardHeight -= 34
        }
        
        if (chatTableView.frame.height + chatTextField.frame.height + keyboardHeight) > self.view.frame.height {
            print("Exceeded")
            self.flexContainer.pin
                .top(self.view.pin.safeArea.top - keyboardHeight)
                .horizontally(self.view.pin.safeArea)
                .bottom(self.view.pin.safeArea.bottom + keyboardHeight)
        } else {
            print("NOT Exceeded")
            self.flexContainer.pin
                .top(self.view.pin.safeArea.top)
                .horizontally(self.view.pin.safeArea)
                .bottom(self.view.pin.safeArea.bottom + keyboardHeight)
        }


        self.flexContainer.flex.layout()
        
        self.chatTableView.pin
            .horizontally(self.flexContainer.pin.safeArea)
            .top(self.flexContainer.pin.safeArea.top)
            .bottom(self.chatTextField.pin.safeArea.top)
        
        self.chatTextField.pin
            .horizontally(self.flexContainer.pin.safeArea)
            .bottom(self.flexContainer.pin.safeArea.bottom)
        
    }
    
    private func setUI() {
        self.view.addSubview(self.flexContainer)
    }
    
    private func setLayout() {
        self.flexContainer.flex
            .direction(.column)
            .define { flex in
                flex.addItem(self.chatTableView)
                flex.addItem(self.chatTextField)
                    .height(50)
            }
    }
}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testChatData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.identifier,
                                      for: indexPath)
        
        var config = cell.defaultContentConfiguration()
        config.text = testChatData[indexPath.row]
        cell.contentConfiguration = config
        
        return cell
    }
}

extension ChatListViewController: UITextFieldDelegate {
    
    private func setNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        // Calculate keyboard height and adjust layout
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            updateLayoutForKeyboard(height: keyboardHeight)
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        // Reset layout when keyboard hides
        updateLayoutForKeyboard(height: 0)
    }
  

    private func updateLayoutForKeyboard(height: CGFloat) {
        keyboardHeight = height  // Update keyboard height

        self.flexContainer.flex.layout()
        
        self.view.setNeedsLayout()
    }

}

extension ChatListViewController {
    //test3@mail.com
    //test2@email.com
//    private func demoSaveFriend() {
//        Task {
//            do {
//                try await SupabaseManager.shared
//                    .saveFriend(with: "test3@mail.com")
//            }
//            catch {
//                print("Error saving friend. -- \(error)")
//            }
//        }
//        
//    }
    
//    private func demo_fetchFriendsList() {
//        let supabase = SupabaseManager.shared
//        
//        Task {
//            do {
//                let user = try await supabase.fetchUserInfo()
//                print("User: \(user.id)")
//                let list = try await supabase.fetchFriends(of: user.id)
//                print("Friends list: \(list)")
//            }
//            catch {
//                print("Error fetching friends list -- \(error)")
//            }
//        }
//    }
}

//@available(iOS 17, *)
//#Preview(traits: .defaultLayout, body: {
//    ChatListViewController(vm: <#T##ChatListViewModel#>)
//})
