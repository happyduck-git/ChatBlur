//
//  ChatRoomViewModel.swift
//  ChatBlur
//
//  Created by HappyDuck on 1/5/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ChatRoomViewModel: ViewModelType {
    
    private let supabaseManager: SupabaseManager = SupabaseManager.shared
    
    private let currentUser: PublishRelay<ChatUser>
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Init
    init(currentUser: PublishRelay<ChatUser>) {
        self.currentUser = currentUser
    }
    
    //MARK: - View Model Data
    struct Input {
       
    }
    
    struct Output {

    }
    
    func transform(input: Input) -> Output {

        self.currentUser
            .subscribe(onNext: {
            print("User information from ChatListVM: \($0.username)")
        })
        .disposed(by: disposeBag)

        return Output()

    }
}
