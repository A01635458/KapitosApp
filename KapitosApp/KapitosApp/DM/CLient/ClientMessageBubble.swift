//
//  ClientMessageBubble.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 03/12/25.
//

import SwiftUI

struct ClientMessageBubble: View {

    @EnvironmentObject var theme: AppThemeManager
    let message: Message

    var body: some View {
        HStack {
            if message.isMe { Spacer() }

            VStack(alignment: message.isMe ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .padding(12)
                    .foregroundColor(
                        message.isMe
                            ? .white
                            : (theme.isDarkMode ? .white : AppColors.textLight)
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                message.isMe
                                    ? (theme.isDarkMode ? AppColors.accentDark : AppColors.accentLight)
                                    : (theme.isDarkMode ? AppColors.cardDark : AppColors.cardLight)
                            )
                    )
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.68, alignment: message.isMe ? .trailing : .leading)
                
                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
            }

            if !message.isMe { Spacer() }
        }
        .padding(.horizontal)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}
