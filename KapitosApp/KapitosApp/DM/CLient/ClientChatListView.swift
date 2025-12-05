//
//  ClientChatListView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 03/12/25.
//

import SwiftUI

struct ClientChatListView: View {

    @EnvironmentObject var theme: AppThemeManager
    @StateObject private var messagingService: MessagingService
    
    init(currentUserId: UUID) {
        _messagingService = StateObject(wrappedValue: MessagingService(currentUserId: currentUserId))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if messagingService.isLoading && messagingService.conversations.isEmpty {
                    VStack {
                        ProgressView("Cargando conversaciones...")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if messagingService.conversations.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No hay conversaciones")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("Inicia una conversación con un productor")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(messagingService.conversations) { conversationDetail in
                                NavigationLink {
                                    ClientChatDetailView(
                                        conversationId: conversationDetail.conversation.id,
                                        currentUserId: messagingService.currentUserId,
                                        otherUserName: conversationDetail.otherUser.full_name,
                                        otherUserPhotoUrl: conversationDetail.otherUser.photo_url
                                    )
                                    .environmentObject(theme)
                                } label: {
                                    ChatRow(
                                        name: conversationDetail.otherUser.full_name,
                                        lastMessage: conversationDetail.lastMessage?.content ?? "Sin mensajes",
                                        time: formatTime(conversationDetail.lastMessage?.created_at),
                                        unreadCount: conversationDetail.unreadCount,
                                        avatarUrl: conversationDetail.otherUser.photo_url
                                    )
                                    .environmentObject(theme)
                                    .padding(.horizontal)
                                    .padding(.top, 6)
                                }
                                
                                if conversationDetail.id != messagingService.conversations.last?.id {
                                    Divider().padding(.leading, 80)
                                }
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(
                theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight
            )
            .navigationTitle("Mensajes con Vendedores")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await messagingService.fetchConversations()
            }
            .refreshable {
                await messagingService.fetchConversations()
            }
        }
        .background(
            theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight
        )
    }
    
    // MARK: - Helper Functions
    
    private func formatTime(_ date: Date?) -> String {
        guard let date = date else { return "" }
        
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Ayer"
        } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yy"
            return formatter.string(from: date)
        }
    }
}
