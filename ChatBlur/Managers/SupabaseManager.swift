//
//  SupabaseManager.swift
//  ChatBlur
//
//  Created by HappyDuck on 12/31/23.
//

import Foundation
import Supabase

protocol AuthClient {
    func signupWithEmailAndPassword(email: String, password: String, username: String) async throws
    func signinWithEmailAndPassword(email: String, password: String) async throws -> Session
}

protocol Repository {
    func saveUser(_ uid: UUID, user: ChatUser) async throws
}

final actor SupabaseManager {
    static let shared: SupabaseManager = SupabaseManager()
    private init() {}
    
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
                                user: ChatUser(updatedAt: response.user.updatedAt,
                                               createdAt: response.user.createdAt,
                                               username: username))
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
    
    func checkSession() async throws -> User {
        return try await supabase.auth.user()
    }
}

extension SupabaseManager: Repository {
    func saveUser(_ uid: UUID, user: ChatUser) async throws {
        try await supabase.database
            .from("profiles")
            .update(user)
            .eq("id", value: uid)
            .execute()
    }
}
