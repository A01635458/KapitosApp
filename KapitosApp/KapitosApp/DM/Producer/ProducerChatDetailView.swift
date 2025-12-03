//
//  ProducerChatDetailView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 03/12/25.
//


import SwiftUI

struct ProducerChatDetailView: View {

    @EnvironmentObject var theme: AppThemeManager

    @State private var messages: [Message] = [
        Message(text: "Hola, quería saber si ya enviaste mi pedido.", isMe: false),
        Message(text: "Sí claro! Sale hoy por la tarde 🙌", isMe: true)
    ]

    @State private var input = ""
    @State private var scrollID = UUID()

    var body: some View {
        VStack(spacing: 0) {

            headerView

            Divider()

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {

                        ForEach(messages) { msg in
                            ProducerMessageBubble(message: msg)
                                .environmentObject(theme)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: messages)
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
                .onChange(of: messages) { _ in
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
                Text("Cliente Ana López")
                    .font(.headline)
                    .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)

                Text("En línea ahora")
                    .font(.caption)
                    .foregroundColor(.green.opacity(0.85))
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

        messages.append(Message(text: input, isMe: true))
        input = ""
        scrollID = UUID()
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
