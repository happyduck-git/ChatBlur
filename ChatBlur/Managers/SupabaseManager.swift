//
//  SupabaseManager.swift
//  ChatBlur
//
//  Created by HappyDuck on 12/31/23.
//

import Foundation
import Supabase
import RxCocoa

protocol AuthClient {
    func signupWithEmailAndPassword(email: String, password: String, username: String) async throws
    func signinWithEmailAndPassword(email: String, password: String) async throws -> Session
}

protocol Repository {
    func saveUser(_ uid: UUID, user: ChatUser) async throws
    func saveFriend(with email: String) async throws
    func fetchFriends(of id: UUID) async throws -> [ChatUser]
}

final actor SupabaseManager {
    static let shared: SupabaseManager = SupabaseManager()
    private init() {}

    enum SupabaseFunction: String {
        case insertFriend = "insert_friend"
        case profileId = "profile_id"
        case friendName = "friend_name"
        case fetchMessages = "fetch_messages"
        case fetchMessages2 = "fetch_messages2"
        case sender = "message_sender"
        case receiver = "message_receiver"
    }
    
    enum Profiles: String {
        case id
        case profiles
        case email
        case friendsList = "friends_list"
    }
    
    enum Messages: String {
        case messages
    }
    
    private let supabase: SupabaseClient = SupabaseClient(supabaseURL: EnvironmentConfig.supabaseUrl,
                                                          supabaseKey: EnvironmentConfig.supabaseAnon)
}

extension SupabaseManager: AuthClient {
    
    
    /// Sign up with email and password
    /// - Parameters:
    ///   - email: email
    ///   - password: password
    ///   - username: username
    func signupWithEmailAndPassword(email: String, password: String, username: String) async throws {
        // Auth signup
        let response = try await supabase.auth.signUp(
            email: email,
            password: password
        )
        // Insert additional info to database.
        try await self.saveUser(response.user.id,
                                user: ChatUser(id: response.user.id,
                                               updatedAt: response.user.updatedAt,
                                               createdAt: response.user.createdAt,
                                               username: username,
                                               email: email,
                                               friendsList: []))
    }
    
    /// Sign in with email and password
    /// - Parameters:
    ///   - email: email
    ///   - password: password
    /// - Returns: Session information
    func signinWithEmailAndPassword(email: String, password: String) async throws -> Session {
        return try await supabase.auth.signIn(
            email: email,
            password: password
        )
    }
    
    /// Sign in with apple account.
    /// - Parameter token: Token from Apple credential.
    func signInWithApple(token: String) async throws -> Session {
        try await supabase.auth
            .signInWithIdToken(
                credentials: .init(provider: .apple,
                                   idToken: token)
            )
    }
    
    func signOut() async throws {
        try await supabase.auth.signOut()
    }
    
    /// Check if session is valid
    /// - Returns: User
    func checkSession() async throws -> Session {
        return try await supabase.auth.session
    }
}

//MARK: - Users
extension SupabaseManager: Repository {
    func saveUser(_ uid: UUID, user: ChatUser) async throws {
        try await supabase.database
            .from(Profiles.profiles.rawValue)
            .update(user)
            .eq(Profiles.id.rawValue, value: uid)
            .execute()
    }
    
    func saveFriend(with email: String) async throws {
        let user = try await supabase.auth.user()
        let friend = try await self.findUser(with: email)

        guard let friend else {
            #if DEBUG
            print("Friend with \(email) is not found in DB.")
            #endif
            return
        }
        
        try await supabase.database
            .rpc(
                SupabaseFunction.insertFriend.rawValue,
                params: [
                    SupabaseFunction.profileId.rawValue: "\(user.id)",
                    SupabaseFunction.friendName.rawValue: "\(friend.id)"
                ]
            )
            .execute()
    }
    
    func saveMessage(_ message: ChatMessage) async throws {
        try await supabase
            .database
            .from(Messages.messages.rawValue)
            .insert(message)
            .execute()
    }
    
    func findUser(with email: String) async throws -> ChatUser? {
        let result: [ChatUser] = try await supabase.database
            .from(Profiles.profiles.rawValue)
            .select()
            .eq(Profiles.email.rawValue, value: email)
            .execute()
            .value
        
        return result.first
    }
    
    func fetchFriends(of id: UUID) async throws -> [ChatUser] {
        let friendsList = try await self._fetchFriends(of: id)
        
        return try await withThrowingTaskGroup(of: ChatUser.self) { [weak self] group in
            guard let `self` = self else { return [] }
            for friend in friendsList.friendsList {
                group.addTask {
                    try await self.convertUUIDtoUser(friend)
                }
            }
            
            var users: [ChatUser] = []
            for try await result in group {
                users.append(result)
            }
            
            return users.sorted { $0.username < $1.username }
        }
        
    }

    func fetchCurrentUserInfo() async throws -> ChatUser {
        let user = try await self._fetchCurrentUserInfo()
        return try await self.convertUUIDtoUser(user.id)
    }
    
}

//MARK: - Messages
extension SupabaseManager {

    func fetchMessages(from sender: UUID, to recepient: UUID) async throws -> [ChatMessage] {
        #if DEBUG
        print("Sender: \(sender) : Receipient: \(recepient)")
        #endif
        
        let messages: [ChatMessage] = try await supabase.database
            .rpc(
                SupabaseFunction.fetchMessages2.rawValue,
                params: [
                    SupabaseFunction.receiver.rawValue: recepient,
                    SupabaseFunction.sender.rawValue: sender
                ]
            )
            .execute()
            .value
       
        return messages
    }

}

//MARK: - Set up Realtime
extension SupabaseManager {
    func setUpRealtimeListener(on channel: String, schema: String) -> PublishRelay<Message> {
        supabase.realtime.connect()
        
        let messageRelay = PublishRelay<Message>()
        
        var publicSchema: RealtimeChannel?
        
        publicSchema = supabase.realtime.channel(channel)
            .on("postgres_changes", filter: ChannelFilter(event: "INSERT", schema: schema)) {
                messageRelay.accept($0)
            }
            .on("postgres_changes", filter: ChannelFilter(event: "UPDATE", schema: schema)) {
                messageRelay.accept($0)
            }

        publicSchema?.onError { err in
            print("ERROR -- \(err)")
        }
        publicSchema?.onClose { close in
            print("Closed gracefully")
        }
        publicSchema?
          .subscribe { state, _ in
            switch state {
            case .subscribed:
                print("Channel subscribed")
            case .closed:
                print("Channel closed")
            case .timedOut:
                print("Channel time out")
            case .channelError:
                print("Channel error")
            }
          }

        supabase.realtime.connect()
        supabase.realtime.onOpen {
            print("Channel socket open")
        }
        supabase.realtime.onClose {
            print("Channel socket closed")
        }
        supabase.realtime.onError { error, _ in
            print("Channel socket error: \(error.localizedDescription)")
        }
        
        return messageRelay
    }
    
    func setUpFriendsRealtimeListener() -> PublishRelay<Message> {
        supabase.realtime.connect()
        
        let messageRelay = PublishRelay<Message>()
        
        var publicSchema: RealtimeChannel?
        
        publicSchema = supabase.realtime.channel("public")
          .on("postgres_changes", filter: ChannelFilter(event: "UPDATE", schema: "public")) {
              messageRelay.accept($0)
          }

        publicSchema?.onError { err in
            print("ERROR -- \(err)")
        }
        publicSchema?.onClose { close in
            print("Closed gracefully")
        }
        publicSchema?
          .subscribe { state, _ in
            switch state {
            case .subscribed:
                print("Channel subscribed")
            case .closed:
                print("Channel closed")
            case .timedOut:
                print("Channel time out")
            case .channelError:
                print("Channel error")
            }
          }

        supabase.realtime.connect()
        supabase.realtime.onOpen {
            print("Channel socket open")
        }
        supabase.realtime.onClose {
            print("Channel socket closed")
        }
        supabase.realtime.onError { error, _ in
            print("Channel socket error: \(error.localizedDescription)")
        }
        
        return messageRelay
    }
}

//MARK: - Private
extension SupabaseManager {
    
    private func _fetchCurrentUserInfo() async throws -> User {
        return try await supabase.auth.user()
    }
    
    private func _fetchFriends(of id: UUID) async throws -> FriendsList {
        let result: [FriendsList] = try await supabase.database
            .from(Profiles.profiles.rawValue)
            .select(Profiles.friendsList.rawValue)
            .eq(Profiles.id.rawValue, value: id)
            .execute()
            .value
        
        return result.first ?? FriendsList(friendsList: [])
    }
    
    private func convertUUIDtoUser(_ uuid: UUID) async throws -> ChatUser {
        let result: [ChatUser] = try await supabase.database
            .from(Profiles.profiles.rawValue)
            .select()
            .eq(Profiles.id.rawValue, value: uuid)
            .execute()
            .value
        
        guard let user = result.first else { throw SupabaseError.userNotFound }
        
        return user
    }
}

enum SupabaseError: Error {
    case userNotFound
}
