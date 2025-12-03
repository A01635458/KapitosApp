//
//  ProducerMessageBubble.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 03/12/25.
//

import SwiftUI

struct ProducerMessageBubble: View {

    @EnvironmentObject var theme: AppThemeManager
    let message: Message

    var body: some View {
        HStack {
            if !message.isMe { Spacer() }

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
                .frame(maxWidth: UIScreen.main.bounds.width * 0.68, alignment: message.isMe ? .leading : .trailing)

            if message.isMe { Spacer() }
        }
        .padding(.horizontal)
    }
}
