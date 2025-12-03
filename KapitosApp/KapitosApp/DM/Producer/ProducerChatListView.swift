//
//  ProducerChatListView.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 03/12/25.
//

import SwiftUI

struct ProducerChatListView: View {

    @EnvironmentObject var theme: AppThemeManager

    var body: some View {
        NavigationStack {

            ScrollView {
                LazyVStack(spacing: 0) {

                    NavigationLink {
                        ProducerChatDetailView()
                            .environmentObject(theme)
                    } label: {
                        ChatRow(
                            name: "Cliente Ana López",
                            lastMessage: "¿Ya salió mi pedido?",
                            time: "9:20 AM",
                            unreadCount: 1,
                            avatar: "profile_sample"
                        )
                        .environmentObject(theme)
                        .padding(.horizontal)
                        .padding(.top, 6)
                    }

                    Divider().padding(.leading, 80)

                    NavigationLink {
                        ProducerChatDetailView()
                            .environmentObject(theme)
                    } label: {
                        ChatRow(
                            name: "Cliente Carlos Pérez",
                            lastMessage: "Perfecto, gracias!",
                            time: "Ayer",
                            unreadCount: 0,
                            avatar: "profile_sample"
                        )
                        .environmentObject(theme)
                        .padding(.horizontal)
                        .padding(.top, 6)
                    }
                }
                .background(
                    theme.isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight
                )
            }
            .navigationTitle("Mensajes con Clientes")
        }
    }
}

