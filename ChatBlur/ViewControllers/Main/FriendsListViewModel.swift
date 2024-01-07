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
    let moveToChatTracker = PublishRelay<IndexPath>()
    
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
        let chatRoomTrigger: PublishRelay<ChatUser>
        let errorTracker: PublishRelay<Error>
    }
    
    func transform(input: Input) -> Output {
        let errorTracker: PublishRelay<Error> = PublishRelay<Error>()
        let chatRoomTrigger: PublishRelay<ChatUser> = PublishRelay<ChatUser>()
        let friendsList: PublishRelay<[ChatUser]> = PublishRelay<[ChatUser]>()
        var latestFriendsList: [ChatUser] = []
        var _userId: UUID?
        
        // Subscribe current user info
        self.currentUser.subscribe(onNext: { [weak self] user in
            guard let `self` = self else { return }
            _userId = user.id
            
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
        
        // Subscribe to selected table view indexPath
        self.moveToChatTracker
            .subscribe(onNext: {
                chatRoomTrigger.accept(latestFriendsList[$0.row])
            })
            .disposed(by: disposeBag)
        
        // Tableview data source relay
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
        
        let updateRelay = self.createRealtimeSubscription()
        updateRelay.subscribe(onNext: { [weak self] isUpdated in
            guard let `self` = self,
                  let userId = _userId else { return }
            if isUpdated {
                Task {
                    do {
                        friendsList.accept(try await self.fetchFriendsList(userId))
                    }
                    catch {
                        errorTracker.accept(error)
                    }
                }
                
            }
        })
        .disposed(by: disposeBag)
        
        // Subscribe to friendsList
        friendsList
            .subscribe(onNext: {
                latestFriendsList = $0
            })
            .disposed(by: disposeBag)
        
        return Output(sectionData: sectionData,
                      addFriendRelay: friendAdded,
                      chatRoomTrigger: chatRoomTrigger,
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

//MARK: - Set up realtime listener
extension FriendsListViewModel {
    func createRealtimeSubscription() -> PublishRelay<Bool> {
        let updateTracker = PublishRelay<Bool>()
        Task {
            let messageRelay = await self.supabaseManager.setUpFriendsRealtimeListener()
            messageRelay.subscribe(onNext: { message in
                
                #if DEBUG
                print(self.convertMessageToFriendsList(message))
                #endif
                
                updateTracker.accept(true)
            })
            .disposed(by: disposeBag)
        }
        return updateTracker
    }
    
    private func convertMessageToFriendsList(_ message: Message) -> [UUID] {
        let payload = message.payload
        guard let dataDic = payload["data"] as? Dictionary<String, Any>,
              let record = dataDic["record"] as? Dictionary<String, Any>,
              let friendsList = record["friends_list"] as? NSArray else {
            return []
        }
 
        let array = friendsList as? [String]
        let uuids = array?.compactMap({
            UUID(uuidString: $0)
        })
       
        return uuids ?? []
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
