//
//  ProducerChatDetailView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 03/12/25.
//


import SwiftUI
import Combine 

struct ProducerChatDetailView: View {

    @EnvironmentObject var theme: AppThemeManager
    @StateObject private var messagingService: MessagingService
    
    let conversationId: UUID
    let otherUserName: String

    @State private var input = ""
    @State private var scrollID = UUID()
    
    init(conversationId: UUID, currentUserId: UUID, otherUserName: String) {
        self.conversationId = conversationId
        self.otherUserName = otherUserName
        _messagingService = StateObject(wrappedValue: MessagingService(currentUserId: currentUserId))
    }
    
    private var messages: [Message] {
        messagingService.messages.map { messageData in
            Message(from: messageData, currentUserId: messagingService.currentUserId)
        }
    }

    var body: some View {
        VStack(spacing: 0) {

            headerView

            Divider()

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if messagingService.isLoading && messages.isEmpty {
                            ProgressView("Cargando mensajes...")
                                .padding()
                        } else if messages.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.5))
                                Text("No hay mensajes aún")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text("Envía un mensaje para comenzar")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 40)
                        } else {
                            ForEach(messages) { msg in
                                ProducerMessageBubble(message: msg)
                                    .environmentObject(theme)
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: messages.count)
                            }
                        }

                        Color.clear
                            .frame(height: 1)
                            .id(scrollID)
                    }
                    .padding(.top, 10)
                }
                .background(
                    theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight
                )
                .onChange(of: messages.count) { _ in
                    scrollToBottom(proxy)
                }
                .task {
                    await messagingService.fetchMessages(conversationId: conversationId)
                    scrollToBottom(proxy)
                }
            }

            inputBar
        }
        .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension ProducerChatDetailView {
    var headerView: some View {
        HStack(spacing: 12) {

            Image("profile_sample")  // cambia cuando tengas avatar real
                .resizable()
                .scaledToFill()
                .frame(width: 42, height: 42)
                .clipShape(Circle())
                .shadow(radius: 3)

            VStack(alignment: .leading, spacing: 2) {
                Text(otherUserName)
                    .font(.headline)
                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)

                Text("Cliente")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
    }
}

extension ProducerChatDetailView {
    var inputBar: some View {
        HStack(spacing: 10) {

            TextField("Escribe un mensaje…", text: $input)
                .padding(12)
                .background(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                .cornerRadius(12)

            Button {
                sendMessage()
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
    }

    func sendMessage() {
        guard !input.isEmpty else { return }

        let messageContent = input
        input = ""
        
        Task {
            await messagingService.sendMessage(conversationId: conversationId, content: messageContent)
            scrollID = UUID()
        }
    }
}
extension ProducerChatDetailView {
    func scrollToBottom(_ proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.easeOut(duration: 0.25)) {
                proxy.scrollTo(scrollID, anchor: .bottom)
            }
        }
    }
}
