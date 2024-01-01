//
//  EnvironmentConfig.swift
//  ChatBlur
//
//  Created by HappyDuck on 12/31/23.
//

import Foundation

public enum EnvironmentConfig {
    enum Keys: String {
        case supabaseUrl = "SUPABASE_URL"
        case supabaseAnon = "SUPABASE_ANON"
    }
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist file not found")
        }
        return dict
    }()
    
    static let supabaseUrl: String = {
        guard let value = EnvironmentConfig.infoDictionary[Keys.supabaseUrl.rawValue] as? String else {
            fatalError("Alchemy API key not set in plist for this environment")
        }
        
        return value
    }()

    static let supabaseAnon: String = {
        guard let value = EnvironmentConfig.infoDictionary[Keys.supabaseAnon.rawValue] as? String else {
            fatalError("Alchemy API key not set in plist for this environment")
        }
        
        return value
    }()
    
}
