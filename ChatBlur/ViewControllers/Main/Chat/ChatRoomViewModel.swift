//
//  ChatRoomViewModel.swift
//  ChatBlur
//
//  Created by HappyDuck on 1/5/24.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

final class ChatRoomViewModel: ViewModelType {
    
    private let supabaseManager: SupabaseManager = SupabaseManager.shared
    
    // User and Friend UUID
    var userId: UUID?
    private let friendId: UUID

    // Dispose bag
    private let disposeBag = DisposeBag()
    
    //MARK: - Init
    init(friendId: UUID) {
        self.friendId = friendId
        
        self.userId = self.retrieveUserId()
    }
    
    //MARK: - View Model Data
    struct Input {
       let keyboardReturnTrigger: Observable<String>
    }
    
    struct Output {
        let sectionData: Observable<[ChatMessageSectionData]>
        let saveNewMessage: Observable<Void>
        let errorTracker: PublishRelay<Error>
    }
    
    func transform(input: Input) -> Output {
        let messages: PublishRelay<[ChatMessage]> = PublishRelay<[ChatMessage]>()
        let errorTracker: PublishRelay<Error> = PublishRelay<Error>()
        
        let saveNewMessage = input.keyboardReturnTrigger
            .map { [weak self] text in
                guard let `self` = self,
                      let userId = self.userId else { return }
                Task {
                    do {
                        let message = ChatMessage(id: UUID(),
                                                  createdAt: .now,
                                                  sender: userId,
                                                  receiver: self.friendId,
                                                  message: text)
                        
                        try await self.saveMessage(message)
                    }
                    catch {
                        errorTracker.accept(error)
                    }
                }
            }
            .asObservable()
        
        // Create Realtime subscription for chat messages
        self.createRealtimeSubscription()
            .subscribe(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                Task {
                    do {
                        messages.accept(try await self.fetchChatMessage(to: self.friendId))
                    }
                    catch {
                        errorTracker.accept(error)
                    }
                }
                
            })
            .disposed(by: disposeBag)
        
        // Fetch initial message stored in db.
        Task {
            do {
                messages.accept(try await self.fetchChatMessage(to: friendId))
            }
            catch {
                errorTracker.accept(error)
            }
        }
        
        // Tableview data source observable
        let sectionData = messages.compactMap({ message in
            var data: [ChatMessageSectionData] = []
            data.append(ChatMessageSectionData(header: String(),
                                               items: message))
            return data
        })
        .asObservable()
        
        return Output(sectionData: sectionData,
                      saveNewMessage: saveNewMessage,
                      errorTracker: errorTracker)

    }
}

extension ChatRoomViewModel {
    
    /// Create Realtime listner for chat data.
    /// - Returns: PublishRelay<Bool>
    private func createRealtimeSubscription() -> PublishRelay<Bool> {
        let updateTracker = PublishRelay<Bool>()
        Task {
            let messageRelay = await self.supabaseManager.setUpRealtimeListener(on: "chat", schema: "public")
            messageRelay.subscribe(onNext: { message in
                
                #if DEBUG
                print(message)
                #endif
                
                updateTracker.accept(true)
            })
            .disposed(by: disposeBag)
        }
        return updateTracker
    }
    
    /// Fetch Chat data from database.
    /// - Parameter recipient: receiver
    /// - Returns: Array of ChatMessage
    private func fetchChatMessage(to recipient: UUID) async throws -> [ChatMessage] {
        guard let userId = self.userId else { return [] }
        
        return try await supabaseManager.fetchMessages(from: userId, to: recipient)
    }
    
    private func retrieveUserId() -> UUID? {
        guard let uuidString = UserDefaults.standard.string(forKey: UserDefaultsConstants.userId) else { return nil }
        
        return UUID(uuidString: uuidString)
    }
}

extension ChatRoomViewModel {
    private func saveMessage(_ message: ChatMessage) async throws {
        try await self.supabaseManager.saveMessage(message)
    }
}

struct ChatMessageSectionData {
    let header: String
    var items: [Item]
}

extension ChatMessageSectionData: SectionModelType {
    typealias Item = ChatMessage
    
    init(original: ChatMessageSectionData, items: [ChatMessage]) {
        self = original
        self.items = items
    }
}
