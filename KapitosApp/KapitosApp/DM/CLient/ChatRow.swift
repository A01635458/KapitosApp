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
    let avatar: String

    var body: some View {
        HStack(spacing: 14) {

            // ------- FOTO -------
            Image(avatar)
                .resizable()
                .scaledToFill()
                .frame(width: 52, height: 52)
                .clipShape(Circle())
                .shadow(radius: 3)

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
}
