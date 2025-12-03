//
//  ClientChatListView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 03/12/25.
//

import SwiftUI

struct ClientChatListView: View {

    @EnvironmentObject var theme: AppThemeManager

    var body: some View {
        NavigationStack {

            ScrollView {
                LazyVStack(spacing: 0) {

                    NavigationLink {
                        ClientChatDetailView()
                            .environmentObject(theme)
                    } label: {
                        ChatRow(
                            name: "Productor Juan",
                            lastMessage: "Perfecto, sale mañana.",
                            time: "10:45 AM",
                            unreadCount: 2,
                            avatar: "profile_sample"
                        )
                        .environmentObject(theme)
                        .padding(.horizontal)
                        .padding(.top, 6)
                    }

                    Divider().padding(.leading, 80)

                    NavigationLink {
                        ClientChatDetailView()
                            .environmentObject(theme)
                    } label: {
                        ChatRow(
                            name: "Finca El Sol",
                            lastMessage: "Gracias por tu compra! 🌱",
                            time: "Ayer",
                            unreadCount: 0,
                            avatar: "profile_sample"
                        )
                        .environmentObject(theme)
                        .padding(.horizontal)
                        .padding(.top, 6)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(
                theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight
            )
            .navigationTitle("Mensajes con Vendedores")
            .navigationBarTitleDisplayMode(.inline)
        }
        .background(
            theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight
        )
    }
}
