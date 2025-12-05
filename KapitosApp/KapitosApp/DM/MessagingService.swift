//
//  MessagingService.swift
//  KapitosApp
//
//  Real-time messaging service using Supabase
//

import Foundation
import Supabase
import Combine

// MARK: - Models

struct Conversation: Identifiable, Codable {
    let id: UUID
    let client_id: UUID
    let producer_id: UUID
    let created_at: Date
    var updated_at: Date
    var last_message_at: Date?
    var is_active: Bool
}

struct MessageData: Identifiable, Codable {
    let id: UUID
    let conversation_id: UUID
    let sender_id: UUID
    let content: String
    var created_at: Date
    var updated_at: Date
    var is_read: Bool
    var read_at: Date?
    var is_deleted: Bool
    var deleted_at: Date?
    var message_type: String // 'text', 'image', 'system'
    var image_url: String?
    var metadata: [String: String]?
    
    var isFromCurrentUser: Bool {
        // This will be set by the service
        false
    }
}

struct Profile: Codable {
    let id: UUID
    let full_name: String
    let email: String
    let role: String
}

struct ConversationWithDetails: Identifiable {
    let id: UUID
    let conversation: Conversation
    let otherUser: Profile
    var lastMessage: MessageData?
    var unreadCount: Int
}

@MainActor
class MessagingService: ObservableObject {
    private let supabase: SupabaseClient
    let currentUserId: UUID
    
    @Published var conversations: [ConversationWithDetails] = []
    @Published var messages: [MessageData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var messagePollingTask: Task<Void, Never>?
    
    init(currentUserId: UUID) {
        self.currentUserId = currentUserId
        
        self.supabase = SupabaseClient(
            supabaseURL: URL(string: "https://vhjxtygfviesnyepsujw.supabase.co")!,
            supabaseKey: "sb_publishable_JawMYouxwX8apRA2F2s_5w_xy1LbFDb"
        )
    }
    
    deinit {
        messagePollingTask?.cancel()
    }
    
    // MARK: - Fetch Conversations
    
    func fetchConversations() async {
        isLoading = true
        errorMessage = nil
        
        do {
            print("🔍 Fetching conversations for user: \(currentUserId.uuidString)")
            
            // Fetch conversations where user is either client or producer
            let response: [Conversation] = try await supabase
                .from("conversations")
                .select()
                .or("client_id.eq.\(currentUserId.uuidString),producer_id.eq.\(currentUserId.uuidString)")
                .eq("is_active", value: true)
                .order("last_message_at", ascending: false)
                .execute()
                .value
            
            print("✅ Found \(response.count) conversations")
            
            // Fetch details for each conversation
            var conversationsWithDetails: [ConversationWithDetails] = []
            
            for conversation in response {
                // Determine the other user's ID
                let otherUserId = conversation.client_id == currentUserId 
                    ? conversation.producer_id 
                    : conversation.client_id
                
                // Fetch other user's profile
                let profile: Profile = try await supabase
                    .from("profiles")
                    .select()
                    .eq("id", value: otherUserId.uuidString)
                    .single()
                    .execute()
                    .value
                
                // Fetch last message
                let lastMessageResponse: [MessageData]? = try? await supabase
                    .from("messages")
                    .select()
                    .eq("conversation_id", value: conversation.id.uuidString)
                    .eq("is_deleted", value: false)
                    .order("created_at", ascending: false)
                    .limit(1)
                    .execute()
                    .value
                
                let lastMessage = lastMessageResponse?.first
                
                // Fetch unread count
                let unreadMessages: [MessageData]? = try? await supabase
                    .from("messages")
                    .select()
                    .eq("conversation_id", value: conversation.id.uuidString)
                    .eq("is_read", value: false)
                    .neq("sender_id", value: currentUserId.uuidString)
                    .execute()
                    .value
                
                let unreadCount = unreadMessages?.count ?? 0
                
                print("📬 Conversation with \(profile.full_name): \(unreadCount) unread messages")
                
                conversationsWithDetails.append(ConversationWithDetails(
                    id: conversation.id,
                    conversation: conversation,
                    otherUser: profile,
                    lastMessage: lastMessage,
                    unreadCount: unreadCount
                ))
            }
            
            print("✅ Loaded \(conversationsWithDetails.count) conversations with details")
            self.conversations = conversationsWithDetails
            isLoading = false
        } catch {
            print("❌ Error loading conversations: \(error)")
            errorMessage = "Error al cargar conversaciones: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // MARK: - Fetch Messages for Conversation
    
    func fetchMessages(conversationId: UUID) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response: [MessageData] = try await supabase
                .from("messages")
                .select()
                .eq("conversation_id", value: conversationId.uuidString)
                .eq("is_deleted", value: false)
                .order("created_at", ascending: true)
                .execute()
                .value
            
            self.messages = response
            
            // Mark messages as read
            await markMessagesAsRead(conversationId: conversationId)
            
            isLoading = false
        } catch {
            errorMessage = "Error al cargar mensajes: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    // MARK: - Send Message
    
    func sendMessage(conversationId: UUID, content: String, messageType: String = "text", imageUrl: String? = nil) async {
        guard !content.isEmpty || imageUrl != nil else { return }
        
        print("📤 Attempting to send message...")
        print("   Conversation ID: \(conversationId.uuidString)")
        print("   Sender ID: \(currentUserId.uuidString)")
        print("   Content: \(content)")
        
        do {
            struct NewMessage: Encodable {
                let conversation_id: String
                let sender_id: String
                let content: String
                let message_type: String
                let image_url: String?
                let is_read: Bool
                let is_deleted: Bool
            }
            
            let newMessage = NewMessage(
                conversation_id: conversationId.uuidString,
                sender_id: currentUserId.uuidString,
                content: content,
                message_type: messageType,
                image_url: imageUrl,
                is_read: false,
                is_deleted: false
            )
            
            print("🔄 Inserting message into database...")
            
            // Insert without expecting a full response
            try await supabase
                .from("messages")
                .insert(newMessage)
                .execute()
            
            print("✅ Message inserted successfully!")
            
            // Update conversation's last_message_at
            struct ConversationUpdate: Encodable {
                let last_message_at: String
                let updated_at: String
            }
            try await supabase
                .from("conversations")
                .update(ConversationUpdate(
                    last_message_at: ISO8601DateFormatter().string(from: Date()),
                    updated_at: ISO8601DateFormatter().string(from: Date())
                ))
                .eq("id", value: conversationId.uuidString)
                .execute()
            
            print("✅ Conversation updated!")
            
            // Refresh messages to get the new one
            await fetchMessages(conversationId: conversationId)
            
            print("✅ Messages refreshed. Total messages: \(messages.count)")
            
        } catch {
            print("❌ Error sending message: \(error)")
            errorMessage = "Error al enviar mensaje: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Mark Messages as Read
    
    private func markMessagesAsRead(conversationId: UUID) async {
        do {
            struct ReadUpdate: Encodable {
                let is_read: Bool
                let read_at: String
            }
            try await supabase
                .from("messages")
                .update(ReadUpdate(
                    is_read: true,
                    read_at: ISO8601DateFormatter().string(from: Date())
                ))
                .eq("conversation_id", value: conversationId.uuidString)
                .neq("sender_id", value: currentUserId.uuidString)
                .eq("is_read", value: false)
                .execute()
        } catch {
            print("Error marking messages as read: \(error)")
        }
    }
    
    // MARK: - Create or Get Conversation
    
    func getOrCreateConversation(withUserId otherUserId: UUID) async -> UUID? {
        do {
            // Check if conversation exists
            let existingConversations: [Conversation] = try await supabase
                .from("conversations")
                .select()
                .or("and(client_id.eq.\(currentUserId.uuidString),producer_id.eq.\(otherUserId.uuidString)),and(client_id.eq.\(otherUserId.uuidString),producer_id.eq.\(currentUserId.uuidString))")
                .execute()
                .value
            
            if let existing = existingConversations.first {
                return existing.id
            }
            
            // Create new conversation
            // Determine roles (assume current user profile has role)
            let currentProfile: Profile = try await supabase
                .from("profiles")
                .select()
                .eq("id", value: currentUserId.uuidString)
                .single()
                .execute()
                .value
            
            let clientId = currentProfile.role == "user" ? currentUserId : otherUserId
            let producerId = currentProfile.role == "producer" ? currentUserId : otherUserId
            
            struct NewConversation: Encodable {
                let client_id: String
                let producer_id: String
                let is_active: Bool
            }
            
            let newConversation = NewConversation(
                client_id: clientId.uuidString,
                producer_id: producerId.uuidString,
                is_active: true
            )
            
            let response: Conversation = try await supabase
                .from("conversations")
                .insert(newConversation)
                .single()
                .execute()
                .value
            
            return response.id
        } catch {
            errorMessage = "Error al crear conversación: \(error.localizedDescription)"
            return nil
        }
    }
    
    // MARK: - Delete Message
    
    func deleteMessage(messageId: UUID) async {
        do {
            struct DeleteUpdate: Encodable {
                let is_deleted: Bool
                let deleted_at: String
            }
            try await supabase
                .from("messages")
                .update(DeleteUpdate(
                    is_deleted: true,
                    deleted_at: ISO8601DateFormatter().string(from: Date())
                ))
                .eq("id", value: messageId.uuidString)
                .execute()
            
            // Remove from local array
            messages.removeAll { $0.id == messageId }
        } catch {
            errorMessage = "Error al eliminar mensaje: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Real-time Subscription & Polling
    
    func startPollingMessages(conversationId: UUID, interval: TimeInterval = 3.0) {
        stopPollingMessages()
        
        messagePollingTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self = self else { return }
                
                // Fetch messages silently (without showing loading)
                await self.fetchMessagesQuietly(conversationId: conversationId)
                
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
    }
    
    func stopPollingMessages() {
        messagePollingTask?.cancel()
        messagePollingTask = nil
    }
    
    private func fetchMessagesQuietly(conversationId: UUID) async {
        do {
            let response: [MessageData] = try await supabase
                .from("messages")
                .select()
                .eq("conversation_id", value: conversationId.uuidString)
                .eq("is_deleted", value: false)
                .order("created_at", ascending: true)
                .execute()
                .value
            
            // Only update if there are new messages
            if response.count > self.messages.count {
                self.messages = response
                await markMessagesAsRead(conversationId: conversationId)
            }
        } catch {
            // Silently fail for background polling
            print("⚠️ Background polling error: \(error)")
        }
    }
}
