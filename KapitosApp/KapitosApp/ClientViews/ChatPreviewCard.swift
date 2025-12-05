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
    
    let currentUserId: UUID
    
    init(currentUserId: UUID) {
        self.currentUserId = currentUserId
        _messagingService = StateObject(wrappedValue: MessagingService(currentUserId: currentUserId))
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
                ProgressView()
                    .padding()
                    .frame(maxWidth: .infinity)
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

            AsyncImageView(
                urlString: conversation.otherUser.photo_url,
                placeholderText: String(conversation.otherUser.full_name.prefix(1)).uppercased()
            )
            .frame(width: 44, height: 44)

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

            if conversation.unreadCount > 0 {
                Text("\(conversation.unreadCount)")
                    .font(.caption2.bold())
                    .foregroundColor(.white)
                    .padding(6)
                    .background(
                        Circle()
                            .fill(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                    )
            }

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
    }
}

// MARK: - AsyncImageView Helper
struct AsyncImageView: View {
    let urlString: String?
    let placeholderText: String
    
    @EnvironmentObject var theme: AppThemeManager
    @State private var loadedImage: UIImage?
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
            
            if let image = loadedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
            } else if isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            } else {
                Text(placeholderText)
                    .font(.headline)
                    .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        guard let urlString = urlString, !urlString.isEmpty else { return }
        guard let url = URL(string: urlString) else { return }
        
        isLoading = true
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    await MainActor.run {
                        self.loadedImage = image
                        self.isLoading = false
                    }
                } else {
                    await MainActor.run {
                        self.isLoading = false
                    }
                }
            } catch {
                print("❌ Error loading image: \(error.localizedDescription)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}
