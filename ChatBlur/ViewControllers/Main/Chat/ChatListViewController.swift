//
//  ChatListViewController.swift
//  ChatBlur
//
//  Created by HappyDuck on 1/5/24.
//

import UIKit

final class ChatListViewController: BaseViewController {

    private let vm: ChatListViewModel
    
    //MARK: - Init
    init(vm: ChatListViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


}
