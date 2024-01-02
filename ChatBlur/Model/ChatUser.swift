//
//  User.swift
//  ChatBlur
//
//  Created by HappyDuck on 1/1/24.
//

import Foundation

struct ChatUser: Codable {
    let updatedAt: Date
    let createdAt: Date
    let username: String
    let fullName: String? = nil
    var avatarUrl: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case updatedAt = "updated_at"
        case createdAt = "created_at"
        case username
        case fullName = "full_name"
        case avatarUrl = "avatar_url"
    }
}
