//
//  Message.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 03/12/25.
//

import Foundation

struct Message: Identifiable, Equatable {
    let id: UUID
    let text: String
    let isMe: Bool
    let timestamp: Date
    let messageType: String // 'text', 'image', 'system'
    let imageUrl: String?
    let isRead: Bool
    
    init(id: UUID = UUID(), text: String, isMe: Bool, timestamp: Date = Date(), messageType: String = "text", imageUrl: String? = nil, isRead: Bool = false) {
        self.id = id
        self.text = text
        self.isMe = isMe
        self.timestamp = timestamp
        self.messageType = messageType
        self.imageUrl = imageUrl
        self.isRead = isRead
    }
    
    // Convert from MessageData
    init(from messageData: MessageData, currentUserId: UUID) {
        self.id = messageData.id
        self.text = messageData.content
        self.isMe = messageData.sender_id == currentUserId
        self.timestamp = messageData.created_at
        self.messageType = messageData.message_type
        self.imageUrl = messageData.image_url
        self.isRead = messageData.is_read
    }
}
