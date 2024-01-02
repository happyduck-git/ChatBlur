//
//  FriendsListViewModel.swift
//  ChatBlur
//
//  Created by HappyDuck on 1/1/24.
//

import Foundation
import Supabase

final class FriendsListViewModel: ViewModelType {
    
    private let session: Session
    
    //MARK: - Init
    init(session: Session) {
        self.session = session
        print("\(session.user)")
    }
    
    //MARK: - View Model Data
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    func transform(input: Input) -> Output {
        return Output()
    }
}
