//
//  ChatRow.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 03/12/25.
//

import SwiftUI

struct ChatRow: View {

    @EnvironmentObject var theme: AppThemeManager

    let name: String
    let lastMessage: String
    let time: String
    let unreadCount: Int
    let avatarUrl: String?
    
    @State private var avatarImage: UIImage?

    var body: some View {
        HStack(spacing: 14) {

            // ------- FOTO -------
            ZStack {
                Circle()
                    .fill(theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                    .frame(width: 52, height: 52)
                
                if let image = avatarImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 52, height: 52)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                }
            }
            .shadow(radius: 3)
            .task {
                if let urlString = avatarUrl, !urlString.isEmpty {
                    await loadAvatar(from: urlString)
                }
            }

            VStack(alignment: .leading, spacing: 4) {

                HStack {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(theme.isDarkMode ? .white : AppColors.textLight)

                    Spacer()

                    Text(time)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Text(lastMessage)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            // ------- NOTIFICACIONES -------
            if unreadCount > 0 {
                ZStack {
                    Circle()
                        .fill(theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                        .frame(width: 26, height: 26)

                    Text("\(unreadCount)")
                        .foregroundColor(.white)
                        .font(.caption.bold())
                }
                .transition(.scale)
                .animation(.spring(response: 0.25, dampingFraction: 0.8), value: unreadCount)
            }
        }
        .padding(.vertical, 10)
    }
    
    private func loadAvatar(from urlString: String) async {
        guard let url = URL(string: urlString) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                await MainActor.run {
                    self.avatarImage = image
                }
            }
        } catch {
            print("❌ Error loading avatar: \(error)")
        }
    }
}
