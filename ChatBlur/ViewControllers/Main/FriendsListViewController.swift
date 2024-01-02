//
//  FriendsListViewController.swift
//  ChatBlur
//
//  Created by HappyDuck on 1/1/24.
//

import UIKit

final class FriendsListViewController: BaseViewController {

    private let vm: FriendsListViewModel
    
    //MARK: - Init
    init(vm: FriendsListViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemOrange
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
