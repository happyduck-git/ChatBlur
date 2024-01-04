//
//  FriendsListViewModel.swift
//  ChatBlur
//
//  Created by HappyDuck on 1/1/24.
//

import Foundation
import Supabase
import RxSwift
import RxCocoa

final class FriendsListViewModel: ViewModelType {
    
    private let supabaseManager: SupabaseManager = SupabaseManager.shared
    
    private let session: Session
    
    //MARK: - Init
    init(session: Session) {
        self.session = session
        print("\(session.user)")
    }
    
    //MARK: - View Model Data
    struct Input {
        let viewDidLoad: Driver<Void>
    }
    
    struct Output {
        
    }
    
    func transform(input: Input) -> Output {
        input.viewDidLoad.map { [weak self] _ in
            //TODO: Call to fetch friends list
            
        }
        
        return Output()
    }
}

extension FriendsListViewModel {
    
    private func addFriendsToList(_ email: String) async throws {
        try await supabaseManager.saveFriend(with: email)
    }
    
    private func fetchFriendsList() async throws {
        
    }
}
