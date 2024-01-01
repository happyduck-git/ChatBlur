//
//  SupabaseManager.swift
//  ChatBlur
//
//  Created by HappyDuck on 12/31/23.
//

import Foundation
import Supabase

protocol AuthClient {
    func loginWithEmailAndPassword(email: String, password: String) async throws
}

final actor SupabaseManager {
    static let shared: SupabaseManager = SupabaseManager()
    private init() {}
    
    private let supabase: SupabaseClient = SupabaseClient(supabaseURL: EnvironmentConfig.supabaseUrl,
                                                          supabaseKey: EnvironmentConfig.supabaseAnon)
}

extension SupabaseManager: AuthClient {
    func loginWithEmailAndPassword(email: String, password: String) async throws {
        try await supabase.auth.signUp(email: email,
                                       password: password)
    }
}
