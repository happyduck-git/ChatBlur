//
//  ChatRoomViewController.swift
//  ChatBlur
//
//  Created by HappyDuck on 1/1/24.
//

import UIKit
import UIKitBooster
import RxSwift
import RxCocoa
import RxDataSources

final class ChatRoomViewController: UIViewController {
    
    private let vm: ChatRoomViewModel
    
    private let disposeBag = DisposeBag()
    
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
        table.backgroundColor = .background
        table.register(MeTableViewCell.self,
                       forCellReuseIdentifier: MeTableViewCell.identifier)
        table.register(YouTableViewCell.self,
                       forCellReuseIdentifier: YouTableViewCell.identifier)
        return table
    }()
    
    private let chatTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .secondarySystemBackground
        textField.placeholder = ChatRoomConstants.textFieldPlaceholder
        return textField
    }()
    
    init(vm: ChatRoomViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dismissKeyboard()
        
        self.setUI()
        self.setLayout()
        self.setDelegate()
        
        self.setNotification()  
      
        self.bind(with: self.vm)
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setFlexContainer()
    }
    
}

extension ChatRoomViewController {
    private func bind(with vm: ChatRoomViewModel) {
        
        let keyboardReturnTrigger = self.chatTextField.rx
            .controlEvent(.editingDidEndOnExit)
            .map({ [weak self] _ in
                guard let `self` = self else { return String() }
                return self.chatTextField.text ?? String()
            })
            .asObservable()
        
        let input = ChatRoomViewModel.Input(
            keyboardReturnTrigger: keyboardReturnTrigger
        )
        
        let dataSource = self.createDataSource()
        
        let output = vm.transform(input: input)
        output.sectionData
            .bind(to: self.chatTableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        output.saveNewMessage
            .subscribe()
            .disposed(by: disposeBag)
        
        output.errorTracker
            .subscribe(onNext: {
                print("Error -- \($0)")
            })
            .disposed(by: disposeBag)
        
    }
}

extension ChatRoomViewController {
    
    private func setDelegate() {
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

extension ChatRoomViewController {
    /// Create data source for table view.
    /// - Returns: RxTableViewSectionedReloadDataSource
    private func createDataSource() -> RxTableViewSectionedReloadDataSource<ChatMessageSectionData> {
        let dataSource = RxTableViewSectionedReloadDataSource<ChatMessageSectionData> { datasource, table, indexPath, item in

            #if DEBUG
                print("Chat Item: \(item)")
            #endif
            
            guard let userId = self.vm.userId else {
                return UITableViewCell()
            }
            
            if item.sender == userId {
                guard let meCell = table.dequeueReusableCell(withIdentifier: MeTableViewCell.identifier,
                                                           for: indexPath) as? MeTableViewCell else {
                    return UITableViewCell()
                }
                meCell.configure(with: item)
                return meCell
                
            } else {
                guard let youCell = table.dequeueReusableCell(withIdentifier: YouTableViewCell.identifier,
                                                           for: indexPath) as? YouTableViewCell else {
                    return UITableViewCell()
                }
                youCell.configure(with: item)
                return youCell
            }

        }

        return dataSource
    }
}

extension ChatRoomViewController: UITextFieldDelegate {
    
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

//@available(iOS 17, *)
//#Preview(traits: .defaultLayout, body: {
//    ChatRoomViewController(vm: <#T##ChatListViewModel#>)
//})
