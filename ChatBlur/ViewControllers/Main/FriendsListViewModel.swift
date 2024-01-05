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
import RxDataSources

final class FriendsListViewModel: ViewModelType {
    
    private let supabaseManager: SupabaseManager = SupabaseManager.shared
    
    private let currentUser: PublishRelay<ChatUser>
    let alertTracker = PublishRelay<String>()
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Init
    init(currentUser: PublishRelay<ChatUser>) {
        self.currentUser = currentUser
    }
    
    //MARK: - View Model Data
    struct Input {
        let addFriendEmail: PublishRelay<String>
    }
    
    struct Output {
        let sectionData: Observable<[FriendViewSectionData]>
        let addFriendRelay: Observable<Void>
        let errorTracker: PublishRelay<Error>
    }
    
    func transform(input: Input) -> Output {
        let errorTracker: PublishRelay<Error> = PublishRelay<Error>()
        let friendsList: PublishRelay<[ChatUser]> = PublishRelay<[ChatUser]>()
        
        self.currentUser.subscribe(onNext: { [weak self] user in
            guard let `self` = self else { return }
            Task {
                do {
                    friendsList.accept(try await self.fetchFriendsList(user.id))
                }
                catch {
                    errorTracker.accept(error)
                }
            }
        })
        .disposed(by: disposeBag)
        
        let sectionData = PublishRelay.combineLatest(self.currentUser, friendsList).map { currentUser, friendsList in
            var data: [FriendViewSectionData] = []
            // first section
            data.append(FriendViewSectionData(header: String(localized: "Me"),
                                    items: [currentUser]))
            
            // second section
            data.append(FriendViewSectionData(header: String(localized: "Friends"),
                                    items: friendsList))
            
            return data
        }
        .asObservable()
        
        // Add friend to friends list in data base.
        let friendAdded = input.addFriendEmail
            .map { [weak self] email in
                guard let `self` = self else { return }
                Task {
                    do {
                        try await self.addFriendsToList(email)
                    }
                    catch {
                        errorTracker.accept(error)
                    }
                }
            }
            .asObservable()
        
        return Output(sectionData: sectionData,
                      addFriendRelay: friendAdded,
                      errorTracker: errorTracker)
    }
}

extension FriendsListViewModel {
    
    private func addFriendsToList(_ email: String) async throws {
        try await supabaseManager.saveFriend(with: email)
    }
    
    private func fetchFriendsList(_ id: UUID) async throws -> [ChatUser] {
        return try await supabaseManager.fetchFriends(of: id)
    }
}

extension FriendsListViewModel {
    enum Section: String, CaseIterable {
        case me
        case friends
    }
}

struct FriendViewSectionData {
    let header: String
    var items: [Item]
}

extension FriendViewSectionData: SectionModelType {
    typealias Item = ChatUser
    
    init(original: FriendViewSectionData, items: [ChatUser]) {
        self = original
        self.items = items
    }
}
