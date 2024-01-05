//
//  TabbarViewModel.swift
//  ChatBlur
//
//  Created by HappyDuck on 1/1/24.
//

import Foundation
import Supabase
import RxCocoa

final class TabbarViewModel: ViewModelType {
    
    private let supabaseManager: SupabaseManager = SupabaseManager.shared
    let session: Session
 
    //MARK: - Init
    init(session: Session) {
        self.session = session
    }
    
    //MARK: - Data
    struct Input {
        
    }
    
    struct Output {
        let currentUser: PublishRelay<ChatUser>
        let errorTracker: PublishRelay<Error>
    }
    
    func transform(input: Input) -> Output {
        
        let currentUser = PublishRelay<ChatUser>()
        let errorTracker = PublishRelay<Error>()
        
        Task {
            do {
                currentUser.accept(try await self.getCurrentUserInfo())
            }
            catch {
                errorTracker.accept(error)
            }
        }
        
        return Output(currentUser: currentUser,
                      errorTracker: errorTracker)
    }
    
}

extension TabbarViewModel {
    private func getCurrentUserInfo() async throws -> ChatUser {
        return try await self.supabaseManager.fetchCurrentUserInfo()
    }
}
