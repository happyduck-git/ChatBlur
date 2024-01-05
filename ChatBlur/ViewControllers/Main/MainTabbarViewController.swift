//
//  MainTabbarViewController.swift
//  ChatBlur
//
//  Created by HappyDuck on 1/1/24.
//

import UIKit
import RxSwift
import RxCocoa

final class MainTabbarViewController: UITabBarController {

    private let vm: TabbarViewModel
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Init
    init(vm: TabbarViewModel) {
        self.vm = vm
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .background
        self.setupTabbar(Item.allCases)
        self.setNavigationBar()
    }

}

extension MainTabbarViewController {
    
    private func setNavigationBar() {
        self.navigationItem.hidesBackButton = true
    }
    
    //MARK: - Set Up Tabbar
    private func setupTabbar(_ tabbars: [Item]) {
        var title: String = ""
        var image: UIImage?
        var vc: UIViewController?
        var vcs: [UINavigationController] = []
        
        let output = self.vm.transform(input: TabbarViewModel.Input())
        
        for tabbar in tabbars {
            title = tabbar.rawValue
            image = UIImage(systemName: tabbar.image)
            
            switch tabbar {
            case .friends:
                let vm = FriendsListViewModel(currentUser: output.currentUser)
                vc = FriendsListViewController(vm: vm)
            case .chat:
                let vm = ChatListViewModel(currentUser: output.currentUser)
                vc = ChatListViewController(vm: vm)
            case .settings:
                vc = SettingsViewController()
            }
            guard let vc = vc else { return }
            
            vcs.append(
                self.createNav(title: title,
                               image: image,
                               vc: vc)
            )
        }
        
        self.setViewControllers(vcs,animated: true)
    }
    
    // Create NavigationController to be used tab bar elements.
    private func createNav(title: String, image: UIImage?, vc: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem.title = title
        nav.tabBarItem.image = image
        nav.viewControllers.first?.navigationItem.title = title
        return nav
    }
}

extension MainTabbarViewController {
    enum Item: String, CaseIterable {
        case friends = "Friends"
        case chat = "Chat"
        case settings = "Settings"
        
        var image: String {
            switch self {
            case .friends:
                return "person.3.fill"
            case .chat:
                return "text.bubble.fill"
            case .settings:
                return "gearshape.fill"
            }
        }
    }
}
