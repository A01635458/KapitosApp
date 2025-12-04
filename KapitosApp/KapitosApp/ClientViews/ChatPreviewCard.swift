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

    struct PreviewChat: Identifiable {
        let id = UUID()
        let name: String
        let message: String
        let avatar: String
    }

    private let previews: [PreviewChat] = [
        PreviewChat(name: "Productor Juan", message: "Tu pedido sale mañana 🙌", avatar: "profile_sample"),
        PreviewChat(name: "Finca El Sol", message: "Gracias por tu compra 🌱", avatar: "profile_sample"),
        PreviewChat(name: "Café Montaña", message: "¿Te interesa nuestra nueva mezcla?", avatar: "profile_sample")
    ]

    var body: some View {
        NavigationLink {
            ClientChatListView()
                .environmentObject(theme)
                .background(theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight)

        } label: {
            VStack(alignment: .leading, spacing: 12) {

                Text("Mensajes recientes")
                    .font(.headline)
                    .foregroundColor(theme.isDarkMode ? AppColors.textDark : AppColors.textLight)

                ForEach(previews.prefix(3)) { chat in
                    HStack(spacing: 12) {

                        Image(chat.avatar)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text(chat.name)
                                .font(.subheadline.bold())
                                .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)

                            Text(chat.message)
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
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(theme.isDarkMode ? AppColors.cardDark : Color.white.opacity(0.95))
                    .shadow(color: .black.opacity(theme.isDarkMode ? 0.3 : 0.1), radius: 6, y: 3)
            )
        }
    }
}
