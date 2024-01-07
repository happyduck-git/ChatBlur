//
//  ChatMessage.swift
//  ChatBlur
//
//  Created by HappyDuck on 1/6/24.
//

import Foundation

struct ChatMessage: Codable {
    let id: UUID
    let createdAt: Date
    let sender: UUID
    let receiver: UUID
    let message: String
    var image: String? = nil
    var video: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case sender
        case receiver
        case message
        case image
        case video
    }
}
