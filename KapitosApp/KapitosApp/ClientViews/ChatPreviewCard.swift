//
//  ChatPreviewCard.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 03/12/25.
//


import SwiftUI
import Combine

struct ChatPreviewCard: View {

    @EnvironmentObject var theme: AppThemeManager
    @StateObject private var messagingService: MessagingService
    
    // TODO: Replace with actual authenticated user ID
    private let currentUserId = UUID(uuidString: "3ba73474-dc62-4c5a-86a3-d70069097d17")!
    
    init() {
        let uuid = UUID(uuidString: "3ba73474-dc62-4c5a-86a3-d70069097d17")!
        _messagingService = StateObject(wrappedValue: MessagingService(currentUserId: uuid))
    }
    
    var body: some View {
        NavigationLink {
            ClientChatListView(currentUserId: currentUserId)
                .environmentObject(theme)
                .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)

        } label: {
            labelContent
        }
        .task {
            await messagingService.fetchConversations()
        }
    }
    
    private var labelContent: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Mensajes recientes")
                .font(.headline)
                .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
            
            if messagingService.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding()
                    Spacer()
                }
            } else if messagingService.conversations.isEmpty {
                Text("No hay conversaciones")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.vertical, 8)
            } else {
                ForEach(Array(messagingService.conversations.prefix(3))) { conversation in
                    conversationRow(conversation)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.isDarkMode ? AppColors.cardDark : Color.white.opacity(0.95))
                .shadow(color: .black.opacity(theme.isDarkMode ? 0.3 : 0.1), radius: 6, y: 3)
        )
    }
    
    private func conversationRow(_ conversation: ConversationWithDetails) -> some View {
        HStack(spacing: 12) {

            Circle()
                .fill(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                .frame(width: 44, height: 44)
                .overlay(
                    Text(String(conversation.otherUser.full_name.prefix(1)).uppercased())
                        .font(.headline)
                        .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(conversation.otherUser.full_name)
                    .font(.subheadline.bold())
                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)

                Text(conversation.lastMessage?.content ?? "Sin mensajes")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
    }
}
