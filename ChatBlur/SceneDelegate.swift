//
//  SceneDelegate.swift
//  ChatBlur
//
//  Created by HappyDuck on 12/27/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    private let supabaseManager = SupabaseManager.shared
    
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        Task {
            do {
                let session = try await supabaseManager.checkSession()
                self.saveToUserDefaults(userId: session.user.id)
                
                let vm = TabbarViewModel(session: session)
                let vc = MainTabbarViewController(vm: vm)
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    self.window?.rootViewController = UINavigationController(rootViewController: vc)
                    self.window?.makeKeyAndVisible()
                }
            }
            catch {
                let vm = LoginViewModel()
                let vc = LoginViewController(vm: vm)
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    self.window?.rootViewController = UINavigationController(rootViewController: vc)
                    self.window?.makeKeyAndVisible()
                }
            }
        }
        
      
    }

    func sceneDidDisconnect(_ scene: UIScene) {

    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

extension SceneDelegate {
    // Save session user id in UserDefaults
    private func saveToUserDefaults(userId: UUID) {
        UserDefaults.standard.setValue(userId.uuidString,
                                       forKey: UserDefaultsConstants.userId)
    }
}
